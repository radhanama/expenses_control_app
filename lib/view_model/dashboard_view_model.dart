import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/statistics/dashboard_dto.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/models/services/dashboard_service.dart';

/// ViewModel responsável por gerir o estado e a lógica de negócio do Dashboard.
class DashboardViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final DashboardService _stats;

  DashboardViewModel(this._repo, this._stats);

  bool _loading = false;
  DashboardDTO _resumo = DashboardDTO.vazio;

  // --- GETTERS DIRETOS DO DTO ---
  bool get loading => _loading;
  
  // O getter principal agora expõe o DTO completo, como a view espera.
  DashboardDTO get resumo => _resumo;
  
  // Getters individuais para conveniência (como no seu ViewModel original)
  int get transacoes => _resumo.transacoes;
  Map<DateTime, double> get gastosPorMes => _resumo.gastosPorMes;
  Map<int, double> get gastosPorDiaDaSemana => _resumo.gastosPorDiaDaSemana;
  Map<String, double> get top5Estabelecimentos => _resumo.top5Estabelecimentos;
  double get gastoMedioPorTransacao => _resumo.gastoMedioPorTransacao;
  double get comparativoMesAnterior => _resumo.comparativoMesAnterior;

  Future<void> carregarResumo() async {
    _loading = true;
    notifyListeners();

    final gastos = await _repo.findAll();
    _resumo = await _stats.geraDashboardCompleto(gastos);

    _loading = false;
    notifyListeners();
  }
}
