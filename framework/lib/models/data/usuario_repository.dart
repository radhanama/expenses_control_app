// lib/data/usuario_repository.dart
//
// Extends BaseRepository<Usuario>.  Adds a helper to find a user by e-mail,
// which AuthenticationService will use for login.

import 'package:sqflite/sqflite.dart';
import '../base/base_repository.dart';
import '../usuario.dart';

class UsuarioRepository extends BaseRepository<Usuario> {
  UsuarioRepository(Database db)
      : super(
          database: db,
          fromMap: Usuario.fromMap,
        );

  /// Returns the user whose e-mail matches [email] or `null` if none.
  Future<Usuario?> findByEmail(String email) async {
    final rows = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : Usuario.fromMap(rows.first);
  }

  /// Optional convenience: checks if an e-mail is already registered.
  Future<bool> emailExists(String email) async => (await db.query('usuarios',
          columns: const ['id'],
          where: 'email = ?',
          whereArgs: [email],
          limit: 1))
      .isNotEmpty;
}
