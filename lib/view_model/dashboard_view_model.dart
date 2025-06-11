import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/statistics/estatistica_dto.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/models/services/statistica_service.dart';
import 'package:expenses_control/models/gasto.dart';

class DashboardViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final EstatisticaService _stats;

  DashboardViewModel(this._repo, this._stats);

  EstatisticaDTO _resumo = EstatisticaDTO.vazio;
  bool _loading = false;
  int _transacoes = 0;
  Map<DateTime, double> _gastosPorMes = const {};

  EstatisticaDTO get resumo => _resumo;
  bool get loading => _loading;
  int get transacoes => _transacoes;
  Map<DateTime, double> get gastosPorMes => _gastosPorMes;

  Future<void> carregarResumo() async {
    _loading = true;
    notifyListeners();

    final gastos = await _repo.findAll();
    _transacoes = gastos.length;
    _resumo = _stats.gerarResumo(gastos);
    _gastosPorMes = _calcularGastosPorMes(gastos);

    _loading = false;
    notifyListeners();
  }

  Map<DateTime, double> _calcularGastosPorMes(List<Gasto> gastos) {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    final map = {for (final m in months) m: 0.0};
    for (final g in gastos) {
      final key = DateTime(g.data.year, g.data.month, 1);
      if (map.containsKey(key)) {
        map[key] = map[key]! + g.total;
      }
    }
    return map;
  }
}
