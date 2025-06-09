import 'package:flutter/material.dart';
import '../data/categoria_repository.dart';
import '../models/categoria.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaRepository _repo;
  CategoriaViewModel(this._repo);

  List<Categoria> _categorias = [];
  bool _loading = false;
  List<Categoria> get categorias => _categorias;
  bool get loading => _loading;

  Future<void> carregarCategorias() async {
    _loading = true;
    notifyListeners();
    _categorias = await _repo.findAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> adicionarCategoria(String titulo, String descricao) async {
    await _repo.create(Categoria(titulo: titulo, descricao: descricao));
    await carregarCategorias();
  }
}

