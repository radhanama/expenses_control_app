import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/services/smart_analysis_service.dart';
import 'package:expenses_control/models/data/gasto_repository.dart';
import '../models/data/categoria_repository.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:expenses_control/models/categoria.dart';

class SmartAnalysisViewModel extends ChangeNotifier {
  // O ViewModel agora depende de todos os repositórios necessários para montar os dados.
  final GastoRepository _gastoRepo;
  final CategoriaRepository _categoriaRepo;
  final SmartAnalysisService _analysisService;

  SmartAnalysisViewModel(
    this._gastoRepo,
    this._categoriaRepo,
    this._analysisService,
  );

  bool _isLoading = false;
  String? _analysisResult;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;

  /// Busca os dados completos, formata-os e solicita a análise da IA.
  Future<void> buscarAnalise() async {
    _isLoading = true;
    _errorMessage = null;
    _analysisResult = null;
    notifyListeners();

    try {
      final List<Gasto> gastosBase = await _gastoRepo.findAll();
      final List<Categoria> todasCategorias = await _categoriaRepo.findAll();
      
      // Cria um mapa para facilitar a busca do nome da categoria pelo ID.
      final Map<int, String> mapaCategorias = {
        for (var c in todasCategorias) (c.id ?? 0): c.titulo
      };

      if (gastosBase.isEmpty) {
        throw Exception('Não há gastos registrados para analisar.');
      }

      final List<Map<String, dynamic>> dadosParaIA = [];
      for (final gasto in gastosBase) {
        dadosParaIA.add({
          'local': gasto.local,
          'totalGasto': gasto.total,
          'data': gasto.data.toIso8601String().split('T').first,
          'categoria': mapaCategorias[gasto.categoriaId] ?? 'Sem Categoria',
          'itens': gasto.produtos.map((p) => {
            'nome': p.nome,
            'quantidade': p.quantidade,
            'precoUnitario': p.preco,
          }).toList(),
        });
      }

      final String dadosFormatados = json.encode(dadosParaIA);
      final result = await _analysisService.gerarAnalise(dadosFormatados);
      _analysisResult = result;

    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
