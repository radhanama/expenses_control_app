import 'package:expenses_control/models/base/base_user_entity.dart';

class CategoriaCache extends BaseUserEntity {
  final String descricaoOriginal;
  final String descricaoNormalizada;
  final int categoriaId;

  CategoriaCache({
    super.id,
    required super.usuarioId,
    required this.descricaoOriginal,
    required this.descricaoNormalizada,
    required this.categoriaId,
  });

  CategoriaCache copyWith({
    int? id,
    int? usuarioId,
    String? descricaoOriginal,
    String? descricaoNormalizada,
    int? categoriaId,
  }) {
    return CategoriaCache(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      descricaoOriginal: descricaoOriginal ?? this.descricaoOriginal,
      descricaoNormalizada: descricaoNormalizada ?? this.descricaoNormalizada,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  @override
  String get tableName => 'categoria_cache';

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'descricao_original': descricaoOriginal,
        'descricao_normalizada': descricaoNormalizada,
        'categoria_id': categoriaId,
        'usuario_id': usuarioId,
      };

  factory CategoriaCache.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return CategoriaCache(
        usuarioId: 0,
        descricaoOriginal: '',
        descricaoNormalizada: '',
        categoriaId: 0,
      );
    }

    return CategoriaCache(
      id: map['id'] as int?,
      usuarioId: (map['usuario_id'] as int?) ?? 0,
      descricaoOriginal: map['descricao_original'] as String? ?? '',
      descricaoNormalizada: map['descricao_normalizada'] as String? ?? '',
      categoriaId: map['categoria_id'] as int? ?? 0,
    );
  }
}
