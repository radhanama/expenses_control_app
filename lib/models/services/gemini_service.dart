import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final http.Client _client;

  GeminiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> parseExpense(String text) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=' + apiKey);

    final prompt = '''Converta a seguinte descricao de compra em JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero}],
  "compra": {"valor_a_pagar": numero}
}
Retorne apenas o JSON sem explicacoes.
$text''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    });

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String? answer =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (answer == null) {
        throw Exception('Resposta invalida do Gemini');
      }

      // Alguns modelos podem retornar texto extra; isola apenas o JSON
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(answer);
      final jsonString = match != null ? match.group(0) : answer;

      return json.decode(jsonString!);
    } else {
      throw Exception('Erro na API Gemini: ${response.body}');
    }
  }
}
