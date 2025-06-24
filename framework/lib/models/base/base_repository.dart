// lib/modelsbase/base_repository.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'entity_mapper.dart';

/// Generic repository – high-level CRUD already implemented.
/// Subclasses may call the protected `db` getter for custom queries.
///
/// T must mix-in `EntityMapper` and implement:
///   • String get tableName;
///   • String? get id;
///   • Map<String, dynamic> toMap();
abstract class BaseRepository<T extends EntityMapper> {
  final Database _db;
  final T Function(Map<String, dynamic>) _fromMap;

  BaseRepository({
    required Database database,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _db = database,
        _fromMap = fromMap;

  /// Gives subclasses (but not external callers) direct DB access.
  @protected
  Database get db => _db;

  // “Dummy” instance to read `tableName`
  late final T _dummy = _fromMap(const {});

  // ─────────────────── Public CRUD ───────────────────
  Future<T?> findById(int id) async {
    final rows =
        await _db.query(_dummy.tableName, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromMap(rows.first);
  }

  Future<List<T>> findAll() async {
    final rows = await _db.query(_dummy.tableName);
    return rows.map(_fromMap).toList();
  }

  Future<T> create(T entity) async {
    final newId =
        await _db.insert(_dummy.tableName, entity.toMap()).then((i) => i);
    return _fromMap({...entity.toMap(), 'id': newId});
  }

  Future<T> update(T entity) async {
    if (entity.id == null) throw ArgumentError('id is null');
    await _db.update(
      _dummy.tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
    return entity;
  }

  Future<void> delete(int id) =>
      _db.delete(_dummy.tableName, where: 'id = ?', whereArgs: [id]);
}
