import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control/models/gasto.dart';

import '../models/services/extrato_import_service.dart';

class ExtratoViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final ExtratoImportService _importService;
  ExtratoViewModel(this._repo, this._importService);

  List<Gasto> _gastos = [];
  bool _loading = false;
  bool _importing = false;
  String? _importError;
  int _ultimoImportados = 0;

  List<Gasto> get gastos => _gastos;
  bool get loading => _loading;
  bool get importando => _importing;
  String? get importError => _importError;
  int get ultimoImportados => _ultimoImportados;

  Future<void> carregarGastos() async {
    _loading = true;
    notifyListeners();
    _gastos = await _repo.findAll();
    _loading = false;
    notifyListeners();
  }

  Future<int> importarExtrato(String conteudo, int usuarioId) async {
    _importError = null;
    _importing = true;
    notifyListeners();
    try {
      final quantidade =
          await _importService.importarExtrato(conteudo, usuarioId);
      _ultimoImportados = quantidade;
      _importing = false;
      await carregarGastos();
      return quantidade;
    } catch (e) {
      _importError = e.toString();
      _importing = false;
      notifyListeners();
      rethrow;
    }
  }
}
