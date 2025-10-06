import 'package:flutter/material.dart';
import 'package:expenses_control/models/categoria.dart';

import '../models/categoria_cache.dart';
import '../models/data/categoria_cache_repository.dart';
import '../models/data/categoria_repository.dart';

class CategoriaCacheViewModel extends ChangeNotifier {
  final CategoriaCacheRepository _cacheRepository;
  final CategoriaRepository _categoriaRepository;

  CategoriaCacheViewModel({
    required CategoriaCacheRepository cacheRepository,
    required CategoriaRepository categoriaRepository,
  })  : _cacheRepository = cacheRepository,
        _categoriaRepository = categoriaRepository;

  bool _loading = false;
  String? _error;
  int _usuarioId = 0;
  List<CategoriaCache> _caches = [];
  List<Categoria> _categorias = [];
  final Set<int> _atualizando = {};

  bool get loading => _loading;
  String? get error => _error;
  List<CategoriaCache> get caches => _caches;
  List<Categoria> get categorias => _categorias;
  bool estaAtualizando(int? id) => id != null && _atualizando.contains(id);

  Future<void> carregar(int usuarioId) async {
    _usuarioId = usuarioId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _categorias = await _categoriaRepository.findAll();
      if (usuarioId == 0) {
        _caches = [];
      } else {
        await _cacheRepository.garantirDescricoesNormalizadas(usuarioId);
        _caches = await _cacheRepository.findAllByUsuario(usuarioId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Categoria? obterCategoriaPorId(int? id) {
    if (id == null) return null;
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  Future<int> atualizarCategoria(CategoriaCache cache, int categoriaId) async {
    final cacheId = cache.id;
    if (cacheId == null) return 0;
    _atualizando.add(cacheId);
    notifyListeners();
    try {
      await _cacheRepository.atualizarCategoria(cacheId, categoriaId);
      final afetados = await _cacheRepository.aplicarCategoriaParaDescricao(
        usuarioId: _usuarioId,
        descricaoNormalizada: cache.descricaoNormalizada,
        categoriaId: categoriaId,
      );
      final idx = _caches.indexWhere((c) => c.id == cacheId);
      if (idx != -1) {
        _caches[idx] = cache.copyWith(categoriaId: categoriaId);
      }
      _error = null;
      notifyListeners();
      return afetados;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _atualizando.remove(cacheId);
      notifyListeners();
    }
  }
}
