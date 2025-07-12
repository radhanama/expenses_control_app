import 'package:expenses_control/models/categoria.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/models/databases/database.dart';
import '../lib/models/data/categoria_repository.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await openAppDatabase();
  final repo = CategoriaRepository(db);
  const userId = 1;
  await repo.create(
    Categoria(
      usuarioId: userId,
      titulo: 'Alimentação',
      descricao: 'Gastos com comida',
    ),
  );
  await repo.create(
    Categoria(
      usuarioId: userId,
      titulo: 'Transporte',
      descricao: 'Deslocamentos',
    ),
  );
  await repo.create(
    Categoria(
      usuarioId: userId,
      titulo: 'Lazer',
      descricao: 'Atividades de lazer',
    ),
  );
  await repo.create(
    Categoria(
      usuarioId: userId,
      titulo: 'Outros',
      descricao: 'Outras despesas',
    ),
  );
  await db.close();
}
