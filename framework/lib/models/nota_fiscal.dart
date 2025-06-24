// lib/models/nota_fiscal.dart
import 'dart:io'; // File for the image path
import 'base/base_user_entity.dart';
import 'produto.dart';

class NotaFiscal extends BaseUserEntity {
  // ─────────────────── Campos ───────────────────
  final File? imagem; // imagem no storage local (opcional)
  final String textoExtraido; // OCR completo já limpo

  // ───────────────── Construtor ─────────────────
  NotaFiscal({
    super.id,
    required super.usuarioId,
    this.imagem,
    required this.textoExtraido,
  });

  // ─────── Nome da tabela exigido pelo EntityMapper ───────
  @override
  String get tableName => 'notas_fiscais';

  // ───────────── Map ⇄ Entidade ─────────────
  factory NotaFiscal.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return NotaFiscal(usuarioId: 0, textoExtraido: '');
    }
    return NotaFiscal(
      id: map['id'] as int?,
      usuarioId: (map['usuario_id'] as int?) ?? 0,
      imagem: map['imagem_path'] != null &&
              (map['imagem_path'] as String).isNotEmpty
          ? File(map['imagem_path'] as String)
          : null,
      textoExtraido: map['texto_extraido'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        // gravamos apenas o path para não armazenar binário no SQLite
        'imagem_path': imagem?.path,
        'texto_extraido': textoExtraido,
      };

  // ───────────── Lógica de domínio ─────────────
  /// **Stub** – aqui você chamaria um serviço de OCR
  Future<NotaFiscal> processarOCR() async {
    // TODO: integrar com o pacote de OCR e popular textoExtraido
    return this;
  }

  /// **Stub** – parseia `textoExtraido` e cria lista de produtos
  List<Produto> extrairProdutos() {
    // TODO: regex/IA para encontrar nome, preço, etc.
    return <Produto>[];
  }

  // ---------- helpers ----------
  NotaFiscal copyWith({
    int? id,
    int? usuarioId,
    File? imagem,
    String? textoExtraido,
  }) =>
      NotaFiscal(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        imagem: imagem ?? this.imagem,
        textoExtraido: textoExtraido ?? this.textoExtraido,
      );
}
