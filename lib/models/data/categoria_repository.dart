import 'package:sqflite/sqflite.dart';
import '../categoria.dart';

class CategoriaRepository {
  final Database db;
  CategoriaRepository(this.db);

  Future<Categoria> create(Categoria categoria) async {
    final id = await db.insert('categorias', categoria.toMap());
    return Categoria(
      id: id,
      titulo: categoria.titulo,
      descricao: categoria.descricao,
      parentId: categoria.parentId,
    );
  }

  Future<List<Categoria>> findAll() async {
    final maps = await db.query('categorias');
    return maps.map((m) => Categoria.fromMap(m)).toList();
  }
}
