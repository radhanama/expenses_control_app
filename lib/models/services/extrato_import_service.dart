import 'package:expenses_control/models/categoria.dart';
import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:intl/intl.dart';

import '../../utils/string_normalizer.dart';
import '../categoria_cache.dart';
import '../data/categoria_cache_repository.dart';
import '../data/categoria_repository.dart';
import 'gemini_service.dart';

class ExtratoImportService {
  final GastoRepository _gastoRepository;
  final CategoriaRepository _categoriaRepository;
  final CategoriaCacheRepository _cacheRepository;
  final GeminiService _geminiService;

  ExtratoImportService({
    required GastoRepository gastoRepository,
    required CategoriaRepository categoriaRepository,
    required CategoriaCacheRepository cacheRepository,
    required GeminiService geminiService,
  })  : _gastoRepository = gastoRepository,
        _categoriaRepository = categoriaRepository,
        _cacheRepository = cacheRepository,
        _geminiService = geminiService;

  Future<int> importarExtrato(String conteudo, int usuarioId) async {
    final linhas = conteudo.trim();
    if (linhas.isEmpty) {
      throw Exception('O extrato está vazio.');
    }

    final categorias = await _categoriaRepository.findAll();
    if (categorias.isEmpty) {
      throw Exception('Nenhuma categoria cadastrada para o usuário.');
    }

    final registros = _detectarParser(linhas);
    if (registros == null) {
      throw Exception('Formato de extrato não reconhecido.');
    }

    final itens = registros(linhas);
    if (itens.isEmpty) {
      throw Exception('Nenhum lançamento encontrado no extrato informado.');
    }

    int importados = 0;
    for (final item in itens) {
      if (item.valor <= 0) continue;
      final descricao = item.descricao;
      final descricaoNormalizada = normalizeText(descricao);
      final categoriaId = await _obterCategoriaId(
        descricao,
        categorias,
        usuarioId,
        valor: item.valor,
        data: item.data,
        tipo: item.tipo,
      );
      final gasto = Gasto(
        usuarioId: usuarioId,
        categoriaId: categoriaId,
        total: item.valor,
        data: item.data,
        local: item.local,
        descricaoNormalizada: descricaoNormalizada,
      );
      await _gastoRepository.create(gasto);
      importados++;
    }
    return importados;
  }

  Future<int> _obterCategoriaId(
    String descricao,
    List<Categoria> categorias,
    int usuarioId, {
    double? valor,
    DateTime? data,
    String? tipo,
  }) async {
    final cache = await _cacheRepository.findByDescricao(descricao, usuarioId);
    if (cache != null) {
      return cache.categoriaId;
    }

    final nomesCategorias = categorias.map((c) => c.titulo).toList();
    String resposta;
    try {
      resposta = await _geminiService.classificarTransacao(
        descricao: descricao,
        categorias: nomesCategorias,
        valor: valor,
        data: data,
        tipo: tipo,
      );
    } catch (_) {
      resposta = categorias.first.titulo;
    }

    final categoria = _matchCategoria(resposta, categorias);
    final fallback = categorias.firstWhere(
      (c) => c.id != null,
      orElse: () => categorias.first,
    );
    final categoriaEscolhida = categoria.id != null ? categoria : fallback;
    final normalizada = normalizeText(descricao);

    await _cacheRepository.create(
      CategoriaCache(
        usuarioId: usuarioId,
        descricaoOriginal: descricao,
        descricaoNormalizada: normalizada,
        categoriaId: categoriaEscolhida.id ?? fallback.id ?? 0,
      ),
    );

    return categoriaEscolhida.id ?? fallback.id ?? 0;
  }

  Categoria _matchCategoria(String resposta, List<Categoria> categorias) {
    final alvo = normalizeText(resposta);
    for (final categoria in categorias) {
      if (normalizeText(categoria.titulo) == alvo) {
        return categoria;
      }
    }
    for (final categoria in categorias) {
      if (alvo.contains(normalizeText(categoria.titulo)) ||
          normalizeText(categoria.titulo).contains(alvo)) {
        return categoria;
      }
    }
    return categorias.first;
  }

  List<_ExtratoItem> Function(String)? _detectarParser(String conteudo) {
    if (conteudo.contains('Extrato Conta Corrente')) {
      return _parseContaCorrente;
    }
    if (conteudo.contains('"Data","Lançamento"')) {
      return _parseCartao;
    }
    return null;
  }

  List<_ExtratoItem> _parseContaCorrente(String conteudo) {
    final linhas = conteudo.replaceAll('\r', '').split('\n');
    final inicio =
        linhas.indexWhere((l) => l.trim().startsWith('Data Lançamento'));
    if (inicio == -1) return [];
    final dataFormat = DateFormat('dd/MM/yyyy');
    final itens = <_ExtratoItem>[];
    for (var i = inicio + 1; i < linhas.length; i++) {
      final linha = linhas[i].trim();
      if (linha.isEmpty) continue;
      final partes = linha.split(';');
      if (partes.length < 4) continue;
      try {
        final data = dataFormat.parse(partes[0].trim());
        final historico = partes[1].trim();
        final descricao = partes.length > 2 ? partes[2].trim() : '';
        final valorBruto = partes[3].trim();
        final valor = _parseValor(valorBruto).abs();
        final texto = [historico, descricao].where((p) => p.isNotEmpty).join(' - ');
        itens.add(
          _ExtratoItem(
            data: data,
            descricao: texto.isEmpty ? historico : texto,
            local: descricao.isEmpty ? historico : descricao,
            valor: valor,
            tipo: historico,
          ),
        );
      } catch (_) {
        continue;
      }
    }
    return itens;
  }

  List<_ExtratoItem> _parseCartao(String conteudo) {
    final linhas = conteudo.replaceAll('\r', '').split('\n');
    if (linhas.length <= 1) return [];
    final dataFormat = DateFormat('dd/MM/yyyy');
    final itens = <_ExtratoItem>[];
    for (var i = 1; i < linhas.length; i++) {
      var linha = linhas[i].trim();
      if (linha.isEmpty) continue;
      if (linha.startsWith('"')) {
        linha = linha.substring(1);
      }
      if (linha.endsWith('"')) {
        linha = linha.substring(0, linha.length - 1);
      }
      final partes = linha.split('","');
      if (partes.length < 5) continue;
      try {
        final data = dataFormat.parse(partes[0].trim());
        final lancamento = partes[1].trim();
        final tipo = partes[3].trim();
        final valorBruto = partes[4].trim();
        final valor = _parseValor(valorBruto);
        final categoriaInformada = partes[2].trim();
        final descricao =
            '$lancamento ($categoriaInformada) - $tipo'.replaceAll(RegExp(r'\s+'), ' ').trim();
        itens.add(
          _ExtratoItem(
            data: data,
            descricao: descricao,
            local: lancamento,
            valor: valor.abs(),
            tipo: tipo.isEmpty ? categoriaInformada : tipo,
          ),
        );
      } catch (_) {
        continue;
      }
    }
    return itens;
  }

  double _parseValor(String valor) {
    final cleaned = valor
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}

class _ExtratoItem {
  final DateTime data;
  final String descricao;
  final String local;
  final double valor;
  final String? tipo;

  _ExtratoItem({
    required this.data,
    required this.descricao,
    required this.local,
    required this.valor,
    this.tipo,
  });
}
