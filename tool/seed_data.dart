import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/databases/database.dart';
import '../lib/data/categoria_repository.dart';
import '../lib/models/categoria.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await openAppDatabase();
  final repo = CategoriaRepository(db);
  await repo.create(Categoria(titulo: 'Alimentação', descricao: 'Gastos com comida'));
  await repo.create(Categoria(titulo: 'Transporte', descricao: 'Deslocamentos'));
  await repo.create(Categoria(titulo: 'Lazer', descricao: 'Atividades de lazer'));
  await repo.create(Categoria(titulo: 'Outros', descricao: 'Outras despesas'));
  await db.close();
}

