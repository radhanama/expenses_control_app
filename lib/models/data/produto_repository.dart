import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expenses_control/models/produto.dart';

class ProdutoRepository extends BaseRepository<Produto> {
  ProdutoRepository(Database db)
      : super(database: db, fromMap: Produto.fromMap);
}
