import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../notificacao.dart';

class NotificacaoRepository extends BaseRepository<Notificacao> {
  NotificacaoRepository(Database db)
      : super(database: db, fromMap: Notificacao.fromMap);
}
