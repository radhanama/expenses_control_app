import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control/models/gasto.dart';

class ExtratoViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  ExtratoViewModel(this._repo);

  List<Gasto> _gastos = [];
  bool _loading = false;

  List<Gasto> get gastos => _gastos;
  bool get loading => _loading;

  Future<void> carregarGastos() async {
    _loading = true;
    notifyListeners();
    _gastos = await _repo.findAll();
    _loading = false;
    notifyListeners();
  }
}
