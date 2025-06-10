import 'package:sqflite/sqflite.dart';
import 'package:expenses_control/core/base/base_repository.dart';
import '../notificacao.dart';

class NotificacaoRepository extends BaseRepository<Notificacao> {
  NotificacaoRepository(Database db)
      : super(database: db, fromMap: Notificacao.fromMap);
}
