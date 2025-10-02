// lib/infra/database.dart
//
// Use:  final db = await openAppDatabase();
//       pass [db] to your repositories.
//
// Dependencies (already common in Flutter projects):
//   sqflite         ^2.5.0
//   path_provider   ^2.1.2
//   path            ^1.9.0

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../utils/string_normalizer.dart';

Future<Database> openAppDatabase() async {
  final dbName = dotenv.env['DB_FILENAME'] ?? 'finance.db';
  String path;
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    path = dbName; // stored in IndexedDB
  } else {
    // ───── resolve file location (~/Documents on iOS/Android) ─────
    final docsDir = await getApplicationDocumentsDirectory();
    path = p.join(docsDir.path, dbName);
  }

  // ───── Open and migrate ─────
  return openDatabase(
    path,
    version: 5,
    onCreate: _onCreate,
    onOpen: (db) async {
      await _seedData(db);
    },
    onUpgrade: _onUpgrade,
  );
}

/// Creates ALL tables for version 1.
Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE usuarios (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      nome        TEXT    NOT NULL,
      email       TEXT    NOT NULL UNIQUE,
      senha_hash  TEXT    NOT NULL,
      plano       TEXT    NOT NULL DEFAULT 'gratuito'
    );
  ''');

  await db.execute('''
    CREATE TABLE categorias (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo     TEXT NOT NULL,
      descricao  TEXT NOT NULL,
      parent_id  INTEGER,
      usuario_id INTEGER NOT NULL,
      FOREIGN KEY (parent_id) REFERENCES categorias(id),
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE produtos (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      nome        TEXT NOT NULL,
      preco       REAL NOT NULL,
      quantidade  INTEGER NOT NULL,
      usuario_id  INTEGER NOT NULL,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE gastos (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      total      REAL NOT NULL,
      data       TEXT NOT NULL,
      categoria_id INTEGER NOT NULL,
      local      TEXT,
      descricao_normalizada TEXT NOT NULL DEFAULT '',
      usuario_id INTEGER NOT NULL,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
      FOREIGN KEY (categoria_id) REFERENCES categorias(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE notas_fiscais (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      imagem_path    TEXT,
      texto_extraido TEXT NOT NULL,
      gasto_id       INTEGER,
      usuario_id     INTEGER NOT NULL,
      FOREIGN KEY (gasto_id) REFERENCES gastos(id),
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE categoria_cache (
      id                     INTEGER PRIMARY KEY AUTOINCREMENT,
      descricao_original     TEXT NOT NULL,
      descricao_normalizada  TEXT NOT NULL,
      categoria_id           INTEGER NOT NULL,
      usuario_id             INTEGER NOT NULL,
      UNIQUE(descricao_normalizada, usuario_id),
      FOREIGN KEY (categoria_id) REFERENCES categorias(id),
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE notificacoes (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo      TEXT NOT NULL,
      mensagem  TEXT NOT NULL,
      data      TEXT NOT NULL,
      lida      INTEGER NOT NULL DEFAULT 0,
      usuario_id INTEGER NOT NULL,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE metas (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      descricao     TEXT NOT NULL,
      valor_limite  REAL NOT NULL,
      mes_ano       TEXT NOT NULL,
      categoria_id  INTEGER,
      usuario_id    INTEGER NOT NULL,
      FOREIGN KEY (categoria_id) REFERENCES categorias(id),
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  ''');

  await _seedData(db);
}

/// Handle schema upgrades here (bump [version] ↑ then add cases).
Future<void> _onUpgrade(Database db, int oldV, int newV) async {
  if (oldV < 2) {
    await db.execute('''
      CREATE TABLE metas (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao     TEXT NOT NULL,
        valor_limite  REAL NOT NULL,
        mes_ano       TEXT NOT NULL,
        categoria_id  INTEGER,
        usuario_id    INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categorias(id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      );
    ''');
  }
  if (oldV < 3) {
    await db.execute("ALTER TABLE usuarios ADD COLUMN plano TEXT NOT NULL DEFAULT 'gratuito'");
  }
  if (oldV < 4) {
    await db.execute('''
      CREATE TABLE categoria_cache (
        id                     INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao_original     TEXT NOT NULL,
        descricao_normalizada  TEXT NOT NULL,
        categoria_id           INTEGER NOT NULL,
        usuario_id             INTEGER NOT NULL,
        UNIQUE(descricao_normalizada, usuario_id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      );
    ''');
  }
  if (oldV < 5) {
    await db.execute(
        "ALTER TABLE gastos ADD COLUMN descricao_normalizada TEXT");
    final rows = await db.query(
      'gastos',
      columns: ['id', 'local', 'descricao_normalizada', 'usuario_id'],
    );
    if (rows.isNotEmpty) {
      final cachesPorUsuario = <int, List<Map<String, dynamic>>>{};
      final batch = db.batch();
      for (final row in rows) {
        final atual = row['descricao_normalizada'] as String?;
        if (atual == null || atual.isEmpty) {
          final local = row['local'] as String? ?? '';
          final usuarioId = row['usuario_id'] as int? ?? 0;
          List<Map<String, dynamic>> cachesUsuario;
          if (cachesPorUsuario.containsKey(usuarioId)) {
            cachesUsuario = cachesPorUsuario[usuarioId]!;
          } else {
            cachesUsuario = await db.query(
              'categoria_cache',
              columns: ['descricao_normalizada'],
              where: 'usuario_id = ?',
              whereArgs: [usuarioId],
            );
            cachesPorUsuario[usuarioId] = cachesUsuario;
          }

          final normalizadoLocal = normalizeText(local);
          String novoValor = normalizadoLocal;
          for (final cache in cachesUsuario) {
            final cacheDesc = cache['descricao_normalizada'] as String? ?? '';
            if (cacheDesc == normalizadoLocal) {
              novoValor = cacheDesc;
              break;
            }
            if (cacheDesc.contains(normalizadoLocal) ||
                normalizadoLocal.contains(cacheDesc)) {
              novoValor = cacheDesc;
            }
          }

          batch.update(
            'gastos',
            {'descricao_normalizada': novoValor},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      }
      await batch.commit(noResult: true);
    }
  }
}

Future<void> _seedData(Database db) async {
  final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categorias'));
  final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM usuarios'));
  if (count == 0 && userCount != 0) {
    final batch = db.batch();
    const categorias = [
      {
        'titulo': 'Alimentação',
        'descricao': 'Gastos com comida',
        'usuario_id': 1
      },
      {'titulo': 'Transporte', 'descricao': 'Deslocamentos', 'usuario_id': 1},
      {'titulo': 'Lazer', 'descricao': 'Atividades de lazer', 'usuario_id': 1},
      {'titulo': 'Outros', 'descricao': 'Outras despesas', 'usuario_id': 1},
    ];
    for (final c in categorias) {
      batch.insert('categorias', c);
    }
    await batch.commit(noResult: true);
  }
}
