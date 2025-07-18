import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expenses_control/models/nota_fiscal.dart';

class NotaFiscalRepository extends BaseRepository<NotaFiscal> {
  NotaFiscalRepository(Database db)
      : super(database: db, fromMap: NotaFiscal.fromMap);
}
