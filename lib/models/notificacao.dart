import 'package:expenses_control/models/base/entity_mapper.dart';

enum NotificationTipo { LEMBRETE, ALERTA_GASTO }

class Notificacao with EntityMapper {
  @override
  final int? id;
  final NotificationTipo tipo;
  final String mensagem;
  final DateTime data;
  final bool lida;
  final int usuarioId;

  const Notificacao({
    this.id,
    required this.tipo,
    required this.mensagem,
    required this.data,
    this.lida = false,
    required this.usuarioId,
  });

  @override
  String get tableName => 'notificacoes';

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Notificacao(
        tipo: NotificationTipo.LEMBRETE,
        mensagem: '',
        data: DateTime.now(),
        usuarioId: 0,
      );
    }
    return Notificacao(
      id: map['id'] as int?,
      tipo: NotificationTipo.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => NotificationTipo.LEMBRETE,
      ),
      mensagem: map['mensagem'] as String? ?? '',
      data: map['data'] != null
          ? DateTime.parse(map['data'] as String)
          : DateTime.now(),
      lida: (map['lida'] as int?) == 1,
      usuarioId: (map['usuario_id'] as int?) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo.name,
        'mensagem': mensagem,
        'data': data.toIso8601String(),
        'lida': lida ? 1 : 0,
        'usuario_id': usuarioId,
      };

  Notificacao marcarComoLida() => copyWith(lida: true);

  Notificacao copyWith({
    int? id,
    NotificationTipo? tipo,
    String? mensagem,
    DateTime? data,
    bool? lida,
    int? usuarioId,
  }) =>
      Notificacao(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        mensagem: mensagem ?? this.mensagem,
        data: data ?? this.data,
        lida: lida ?? this.lida,
        usuarioId: usuarioId ?? this.usuarioId,
      );
}
