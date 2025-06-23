import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  Future<Map<String, dynamic>> analisarTextoGasto(String texto) async {
    final prompt = '''Extraia os dados de gasto descritos abaixo e responda apenas em JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "itens": [{"nome": "", "qtd": 1, "valor_unitario": 0.0}],
  "compra": {"valor_a_pagar": 0.0},
  "informacao_geral": {"data_hora_emissao": ""}
}
Frase: "$texto"''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final jsonString = response.text ?? '{}';
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
