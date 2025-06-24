import 'package:flutter/material.dart';
import '../models/data/meta_repository.dart';
import '../models/meta.dart';

class MetaViewModel extends ChangeNotifier {
  final MetaRepository _repo;
  MetaViewModel(this._repo);

  List<Meta> _metas = [];
  bool _loading = false;

  List<Meta> get metas => _metas;
  bool get loading => _loading;

  Future<void> carregarMetas() async {
    _loading = true;
    notifyListeners();
    _metas = await _repo.findAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> adicionarMeta(Meta meta) async {
    await _repo.create(meta);
    await carregarMetas();
  }

  Future<void> atualizarMeta(Meta meta) async {
    await _repo.update(meta);
    await carregarMetas();
  }

  Future<void> deletarMeta(int id) async {
    await _repo.delete(id);
    await carregarMetas();
  }
}
