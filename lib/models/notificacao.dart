import 'package:expenses_control/models/base/entity_mapper.dart';

enum NotificationTipo { LEMBRETE, ALERTA_GASTO }

class Notificacao with EntityMapper {
  @override
  final String? id;
  final NotificationTipo tipo;
  final String mensagem;
  final DateTime data;
  final bool lida;

  const Notificacao({
    this.id,
    required this.tipo,
    required this.mensagem,
    required this.data,
    this.lida = false,
  });

  @override
  String get tableName => 'notificacoes';

  factory Notificacao.fromMap(Map<String, dynamic> map) => Notificacao(
        id: map['id']?.toString(),
        tipo: NotificationTipo.values.firstWhere(
          (e) => e.name == map['tipo'],
          orElse: () => NotificationTipo.LEMBRETE,
        ),
        mensagem: map['mensagem'] as String? ?? '',
        data: DateTime.parse(map['data'] as String),
        lida: (map['lida'] as int?) == 1,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo.name,
        'mensagem': mensagem,
        'data': data.toIso8601String(),
        'lida': lida ? 1 : 0,
      };

  Notificacao marcarComoLida() => copyWith(lida: true);

  Notificacao copyWith({
    String? id,
    NotificationTipo? tipo,
    String? mensagem,
    DateTime? data,
    bool? lida,
  }) =>
      Notificacao(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        mensagem: mensagem ?? this.mensagem,
        data: data ?? this.data,
        lida: lida ?? this.lida,
      );
}
