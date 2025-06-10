import 'package:expenses_control/models/base/base_repository.dart';
import 'package:expenses_control/models/categoria.dart';
import 'package:sqflite/sqflite.dart';

class CategoriaRepository extends BaseRepository<Categoria> {
  CategoriaRepository(Database db)
      : super(database: db, fromMap: Categoria.fromMap);
}
