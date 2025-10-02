import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

    final hoje = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final prompt =
        '''Converta a seguinte descricao de compra em JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero, "categoria": ""}],
  "compra": {"valor_a_pagar": numero}
}
$categoriasTexto
Considere que hoje é $hoje e utilize esta data caso nenhuma outra seja informada.
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
  Future<Map<String, dynamic>> parseExpenseFromHtml(String html,
      {List<String> categorias = const []}) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
            apiKey);

    final categoriasTexto = categorias.isNotEmpty
        ? '\nClassifique cada item na melhor categoria dentre: ${categorias.join(', ')}.'
        : '';

    final hoje = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final prompt =
        '''Extraia as informações da nota fiscal eletrônica abaixo e retorne apenas o JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero, "categoria": ""}],
  "compra": {"valor_a_pagar": numero}
}
$categoriasTexto
Considere que hoje é $hoje e utilize esta data caso nenhuma outra seja informada. Não mencione a data na resposta.
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
  /// Analisa uma imagem de nota fiscal e extrai os dados da compra.
  Future<Map<String, dynamic>> parseExpenseFromImage(Uint8List bytes,
      {List<String> categorias = const [], String mimeType = 'image/jpeg'}) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
            apiKey);

    final categoriasTexto = categorias.isNotEmpty
        ? '\nClassifique cada item na melhor categoria dentre: ${categorias.join(', ')}.'
        : '';

    final hoje = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final prompt = '''Extraia as informações da nota fiscal na imagem e retorne apenas o JSON no formato:
{
  "estabelecimento": {"nome": "", "endereco_completo": ""},
  "informacao_geral": {"data_hora_emissao": "dd/MM/yyyy HH:mm:ss"},
  "itens": [{"nome": "", "qtd": numero, "valor_unitario": numero, "valor_total_item": numero, "categoria": ""}],
  "compra": {"valor_a_pagar": numero}
}
${categoriasTexto}
Considere que hoje é $hoje e utilize esta data caso nenhuma outra seja informada.''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Encode(bytes)
              }
            }
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

  Future<String> classificarTransacao({
    required String descricao,
    required List<String> categorias,
    double? valor,
    DateTime? data,
    String? tipo,
  }) async {
    if (categorias.isEmpty) {
      throw Exception('Nenhuma categoria disponível para classificação.');
    }

    if (apiKey.isEmpty) {
      return categorias.first;
    }

    final buffer = StringBuffer()
      ..writeln('Descrição: $descricao');
    if (valor != null) {
      buffer.writeln('Valor: ${valor.toStringAsFixed(2)}');
    }
    if (tipo != null && tipo.isNotEmpty) {
      buffer.writeln('Tipo: $tipo');
    }
    if (data != null) {
      buffer.writeln('Data: ${DateFormat('dd/MM/yyyy').format(data)}');
    }

    final prompt = '''Selecione a categoria mais adequada para a transação a seguir.
Considere apenas as categorias listadas a seguir e retorne exatamente o nome de uma delas, sem texto adicional.
Categorias: ${categorias.join(', ')}

${buffer.toString()}''';

    final resposta = await _generateText(prompt);
    final primeiraLinha = resposta.split(RegExp(r'[\r\n]')).first.trim();
    return primeiraLinha.isEmpty ? categorias.first : primeiraLinha;
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
