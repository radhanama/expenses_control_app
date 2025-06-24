import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../meta.dart';

class MetaRepository extends BaseRepository<Meta> {
  MetaRepository(Database db) : super(database: db, fromMap: Meta.fromMap);
}
