import 'package:expenses_control/models/categoria.dart';
import 'package:flutter/material.dart';
import '../models/data/categoria_repository.dart';

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

  Future<void> adicionarCategoria(
      String titulo, String descricao, int usuarioId) async {
    await _repo.create(
      Categoria(titulo: titulo, descricao: descricao, usuarioId: usuarioId),
    );
    await carregarCategorias();
  }

  Future<void> atualizarCategoria(Categoria categoria) async {
    await _repo.update(categoria);
    await carregarCategorias();
  }

  Future<void> deletarCategoria(int id) async {
    await _repo.delete(id);
    await carregarCategorias();
  }
}
