// lib/models/produto.dart
import 'base/base_user_entity.dart';

class Produto extends BaseUserEntity {
  // ─────────────────── Campos ───────────────────
  final String nome;
  final double preco;
  final int quantidade;

  // ───────────────── Construtor ─────────────────
  Produto({
    super.id,
    required super.usuarioId,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  // ─────── Nome da tabela exigido pelo EntityMapper ───────
  @override
  String get tableName => 'produtos';

  // ───────────── Map ⇄ Entidade (ORM manual) ─────────────
  factory Produto.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Produto(usuarioId: 0, nome: '', preco: 0.0, quantidade: 0);
    }
    return Produto(
      id: map['id'] as int?,
      usuarioId: (map['usuario_id'] as int?) ?? 0,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'nome': nome,
        'preco': preco,
        'quantidade': quantidade,
      };

  // ───────────────── Lógica de domínio ─────────────────
  /// preço * quantidade
  double calcularSubtotal() => preco * quantidade;

  /// Retorna uma nova instância com campos alterados (imutabilidade).
  Produto copyWith({
    int? id,
    int? usuarioId,
    String? nome,
    double? preco,
    int? quantidade,
  }) =>
      Produto(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        nome: nome ?? this.nome,
        preco: preco ?? this.preco,
        quantidade: quantidade ?? this.quantidade,
      );

  /// Atualiza todos os campos de uma vez.
  Produto reescreverInformacoes(
    String novoNome,
    double novoPreco,
    int novaQuantidade,
  ) =>
      copyWith(
        nome: novoNome,
        preco: novoPreco,
        quantidade: novaQuantidade,
      );
}
