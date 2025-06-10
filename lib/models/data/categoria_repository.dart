import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../categoria.dart';

class CategoriaRepository extends BaseRepository<Categoria> {
  CategoriaRepository(Database db)
      : super(database: db, fromMap: Categoria.fromMap);
}
