import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleTextService {
  final String endpoint;
  final http.Client _client;

  SimpleTextService({this.endpoint = 'https://meuservidor/model-simple/addproduto', http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> parseExpense(String texto) async {
    final url = Uri.parse(endpoint);
    final response = await _client.post(url, body: texto);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Falha ao processar texto simples');
    }
  }
}
