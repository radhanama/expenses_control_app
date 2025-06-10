import 'package:sqflite/sqflite.dart';
import 'package:expenses_control/core/base/base_repository.dart';
import '../categoria.dart';

class CategoriaRepository extends BaseRepository<Categoria> {
  CategoriaRepository(Database db)
      : super(database: db, fromMap: Categoria.fromMap);
}
