// lib/models/gasto.dart
import 'base/base_user_entity.dart';
import 'produto.dart';

class Gasto extends BaseUserEntity {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------
  final double total; // cached total; you can recompute if you want
  final DateTime data;
  final int categoriaId;
  final String local;

  // Not persisted in the same “gastos” table. You’ll likely store produtos
  // in a separate table and join later, but we keep the field here for domain
  // logic and in-memory calculations.
  final List<Produto> produtos;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------
  Gasto({
    super.id,
    required super.usuarioId,
    required this.total,
    required this.data,
    required this.categoriaId,
    required this.local,
    this.produtos = const [],
  });

  // ---------------------------------------------------------------------------
  // Domain helpers (optional)
  // ---------------------------------------------------------------------------
  Gasto copyWith({
    int? id,
    int? usuarioId,
    double? total,
    DateTime? data,
    int? categoriaId,
    String? local,
    List<Produto>? produtos,
  }) =>
      Gasto(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        total: total ?? this.total,
        data: data ?? this.data,
        categoriaId: categoriaId ?? this.categoriaId,
        local: local ?? this.local,
        produtos: produtos ?? this.produtos,
      );

  // ---------------------------------------------------------------------------
  // EntityMapper implementation
  // ---------------------------------------------------------------------------

  /// Converts entity → DB row
  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'total': total,
        'data': data.toIso8601String(),
        'categoria_id': categoriaId,
        'local': local,
        'usuario_id': usuarioId,
      };

  /// Converts a DB row → entity
  factory Gasto.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Gasto(
        usuarioId: 0,
        total: 0.0,
        data: DateTime.now(),
        categoriaId: 0,
        local: '',
      );
    }
    return Gasto(
      id: map['id'] as int?,
      usuarioId: (map['usuario_id'] as int?) ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      data: map['data'] != null
          ? DateTime.parse(map['data'] as String)
          : DateTime.now(),
      categoriaId: map['categoria_id'] as int? ?? 0,
      local: map['local'] as String? ?? '',
    );
  }

  /// Recomputes total from the embedded list, if you opt to keep it in memory.
  double calcularTotal() => produtos.isEmpty
      ? total
      : produtos.fold<double>(0.0, (sum, p) => sum + p.calcularSubtotal());

  /// Retorna a quantidade total de produtos em uma lista de Gasto.
  int quantidadeTotalProdutos() {
    return produtos.length;
  }

  /// Returns a **new** Gasto with an extra product (immutability pattern).
  Gasto adicionarProduto(Produto p) {
    final novaLista = List<Produto>.from(produtos)..add(p);
    final novoTotal =
        novaLista.fold<double>(0.0, (s, p) => s + p.calcularSubtotal());
    return copyWith(produtos: novaLista, total: novoTotal);
  }

  @override
  String get tableName => "gastos";
}
