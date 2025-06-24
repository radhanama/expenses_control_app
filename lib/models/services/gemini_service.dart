import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final http.Client _client;

  GeminiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<String> _generateText(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
            apiKey);

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
      return answer;
    } else {
      throw Exception('Erro na API Gemini: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> parseExpense(String text,
      {List<String> categorias = const []}) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
            apiKey);

    final categoriasTexto = categorias.isNotEmpty
        ? '\nClassifique cada item na melhor categoria dentre: ${categorias.join(', ')}.'
        : '';

    final prompt =
        '''Converta a seguinte descricao de compra em JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero, "categoria": ""}],
  "compra": {"valor_a_pagar": numero}
}
$categoriasTexto
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

  /// Faz o parsing dos dados de uma NFC-e a partir de seu HTML bruto
  Future<Map<String, dynamic>> parseExpenseFromHtml(String html) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
            apiKey);

    final prompt =
        '''Extraia as informações da nota fiscal eletrônica abaixo e retorne apenas o JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero}],
  "compra": {"valor_a_pagar": numero}
}
HTML:
$html''';

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

      final match = RegExp(r'\{[\s\S]*\}').firstMatch(answer);
      final jsonString = match != null ? match.group(0) : answer;

      return json.decode(jsonString!);
    } else {
      throw Exception('Erro na API Gemini: ${response.body}');
    }
  }

  Future<String> sugestaoParaMeta(
      String descricao, double gastoAtual, double limite) async {
    final prompt =
        'Crie uma mensagem motivadora, em português, para um usuário que já gastou R\$ ${gastoAtual.toStringAsFixed(2)} de R\$ ${limite.toStringAsFixed(2)} na meta "$descricao" deste mês. Dê dicas curtas de como economizar.';
    return _generateText(prompt);
  }

  Future<String> parabensPorMeta(String descricao) async {
    final prompt =
        'O usuário cumpriu a meta "$descricao" neste mês. Escreva uma mensagem breve parabenizando e incentivando a continuar economizando, em português.';
    return _generateText(prompt);
  }
}
