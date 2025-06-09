import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/statistics/estatistica_dto.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/models/services/statistica_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final EstatisticaService _stats;

  DashboardViewModel(this._repo, this._stats);

  EstatisticaDTO _resumo = EstatisticaDTO.vazio;
  bool _loading = false;
  int _transacoes = 0;

  EstatisticaDTO get resumo => _resumo;
  bool get loading => _loading;
  int get transacoes => _transacoes;

  Future<void> carregarResumo() async {
    _loading = true;
    notifyListeners();
    final gastos = await _repo.findAll();
    _transacoes = gastos.length;
    _resumo = _stats.gerarResumo(gastos);
    _loading = false;
    notifyListeners();
  }
}
