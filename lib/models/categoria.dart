class Categoria {
  final int? id;
  final String titulo;
  final String descricao;
  final int? parentId;

  Categoria({this.id, required this.titulo, required this.descricao, this.parentId});

  factory Categoria.fromMap(Map<String, Object?> map) => Categoria(
        id: map['id'] as int?,
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        parentId: map['parent_id'] as int?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'parent_id': parentId,
      };
}

