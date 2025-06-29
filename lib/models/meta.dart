import 'package:expenses_control/models/base/entity_mapper.dart';

class Meta with EntityMapper {
  @override
  final int? id;
  final String descricao;
  final double valorLimite;
  final DateTime mesAno;
  final int? categoriaId;
  final int usuarioId;

  const Meta({
    this.id,
    required this.descricao,
    required this.valorLimite,
    required this.mesAno,
    required this.usuarioId,
    this.categoriaId,
  });

  @override
  String get tableName => 'metas';

  factory Meta.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Meta(
        descricao: '',
        valorLimite: 0.0,
        mesAno: DateTime.now(),
        usuarioId: 0,
      );
    }
    return Meta(
      id: map['id'] as int?,
      descricao: map['descricao'] as String? ?? '',
      valorLimite: (map['valor_limite'] as num?)?.toDouble() ?? 0.0,
      mesAno: map['mes_ano'] != null
          ? DateTime.parse(map['mes_ano'] as String)
          : DateTime.now(),
      usuarioId: (map['usuario_id'] as int?) ?? 0,
      categoriaId: map['categoria_id'] as int?,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'descricao': descricao,
        'valor_limite': valorLimite,
        'mes_ano': mesAno.toIso8601String(),
        'categoria_id': categoriaId,
        'usuario_id': usuarioId,
      };

  Meta copyWith({
    int? id,
    String? descricao,
    double? valorLimite,
    DateTime? mesAno,
    int? categoriaId,
    int? usuarioId,
  }) =>
      Meta(
        id: id ?? this.id,
        descricao: descricao ?? this.descricao,
        valorLimite: valorLimite ?? this.valorLimite,
        mesAno: mesAno ?? this.mesAno,
        categoriaId: categoriaId ?? this.categoriaId,
        usuarioId: usuarioId ?? this.usuarioId,
      );
}
