import 'package:expenses_control/models/base/entity_mapper.dart';

class Categoria with EntityMapper {
  @override
  final String? id;
  final String titulo;
  final String descricao;
  final String? parentId;

  Categoria(
      {this.id, required this.titulo, required this.descricao, this.parentId});

  @override
  String get tableName => 'categorias';

  factory Categoria.fromMap(Map<String, Object?> map) => Categoria(
        id: map['id']?.toString(),
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        parentId: map['parent_id']?.toString(),
      );

  @override
  Map<String, Object?> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'parent_id': parentId,
      };

  Categoria copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? parentId,
  }) =>
      Categoria(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        descricao: descricao ?? this.descricao,
        parentId: parentId ?? this.parentId,
      );
}
