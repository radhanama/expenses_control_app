import 'package:expenses_control/models/base/base_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../categoria_cache.dart';
import '../../utils/string_normalizer.dart';

class CategoriaCacheRepository extends BaseRepository<CategoriaCache> {
  CategoriaCacheRepository(Database db)
      : super(database: db, fromMap: CategoriaCache.fromMap);

  Future<CategoriaCache?> findByDescricao(
      String descricao, int usuarioId) async {
    final normalizada = normalizeText(descricao);
    final rows = await db.query(
      'categoria_cache',
      where: 'descricao_normalizada = ? AND usuario_id = ?',
      whereArgs: [normalizada, usuarioId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CategoriaCache.fromMap(rows.first);
  }

  Future<List<CategoriaCache>> findAllByUsuario(int usuarioId) async {
    final rows = await db.query(
      'categoria_cache',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'descricao_original COLLATE NOCASE',
    );
    return rows.map(CategoriaCache.fromMap).toList();
  }

  Future<void> atualizarCategoria(int cacheId, int categoriaId) async {
    await db.update(
      'categoria_cache',
      {'categoria_id': categoriaId},
      where: 'id = ?',
      whereArgs: [cacheId],
    );
  }

  Future<int> aplicarCategoriaParaDescricao({
    required int usuarioId,
    required String descricaoNormalizada,
    required int categoriaId,
  }) {
    final alvo = normalizeText(descricaoNormalizada);
    return db.update(
      'gastos',
      {'categoria_id': categoriaId},
      where: 'usuario_id = ? AND descricao_normalizada = ?',
      whereArgs: [usuarioId, alvo],
    );
  }

  Future<void> garantirDescricoesNormalizadas(int usuarioId) async {
    final rows = await db.query(
      'gastos',
      columns: ['id', 'local', 'descricao_normalizada'],
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    if (rows.isEmpty) return;

    final caches = await findAllByUsuario(usuarioId);
    final batch = db.batch();
    for (final row in rows) {
      final atual = row['descricao_normalizada'] as String?;
      if (atual == null || atual.isEmpty) {
        final local = row['local'] as String? ?? '';
        final normalizadoLocal = normalizeText(local);
        String novoValor = normalizadoLocal;
        for (final cache in caches) {
          final cacheDesc = cache.descricaoNormalizada;
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
