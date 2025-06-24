import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/dashboard/dashboard_dto.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/models/services/dashboard_service.dart';
import 'package:expenses_control_app/models/services/notificacao_service.dart';

/// ViewModel responsável por gerir o estado e a lógica de negócio do Dashboard.
class DashboardViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final DashboardService _service;
  final NotificacaoService _notificacoes;

  DashboardViewModel(this._repo, this._service, this._notificacoes);

  bool _loading = false;
  DashboardDTO _resumo = DashboardDTO.vazio;
  String? _errorMessage;

  bool get loading => _loading;

  String? get errorMessage => _errorMessage;
  
  DashboardDTO get resumo => _resumo;
  
  int get transacoes => _resumo.transacoes;
  Map<DateTime, double> get gastosPorMes => _resumo.gastosPorMes;
  Map<int, double> get gastosPorDiaDaSemana => _resumo.gastosPorDiaDaSemana;
  Map<String, double> get top5Estabelecimentos => _resumo.top5Estabelecimentos;
  double get gastoMedioPorTransacao => _resumo.gastoMedioPorTransacao;
  double get comparativoMesAnterior => _resumo.comparativoMesAnterior;

  Future<void> carregarResumo() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gastos = await _repo.findAll();
      _resumo = await _service.geraDashboardCompleto(gastos);
      await _notificacoes.gerarSugestoes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
