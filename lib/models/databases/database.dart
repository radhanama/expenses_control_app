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

Future<Database> openAppDatabase() async {
  // ───── resolve file location (~/Documents on iOS/Android) ─────
  final docsDir = await getApplicationDocumentsDirectory();
  final dbName = dotenv.env['DB_FILENAME'] ?? 'finance.db';
  final path = p.join(docsDir.path, dbName);

  // ───── Open and migrate ─────
  return openDatabase(
    path,
    version: 2,
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
      senha_hash  TEXT    NOT NULL
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
}

Future<void> _seedData(Database db) async {
  final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categorias'));
  if (count == 0) {
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
