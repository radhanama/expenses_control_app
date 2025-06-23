import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Serviço que utiliza a API Gemini para gerar análises inteligentes dos gastos do usuário.
class SmartAnalysisService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  static const String _url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  /// Envia uma string JSON de dados de gastos para a IA e retorna uma análise em texto.
  /// A formatação dos dados é de responsabilidade de quem chama o serviço (ex: ViewModel).
  Future<String> gerarAnalise(String dadosJsonFormatados) async {
    if (_apiKey == null) {
      throw Exception('Chave da API do Gemini não encontrada. Verifique seu arquivo .env');
    }

    final prompt = """
    Você é um assistente financeiro especialista.
    Analise os seguintes dados de gastos de um usuário, que estão em formato JSON.
    Com base nesses dados, forneça uma análise em português do Brasil com:
    1.  **Resumo Geral:** Um parágrafo curto sobre o comportamento de gastos do usuário no período.
    2.  **Principais Descobertas:** Uma lista de 3 a 5 pontos (bullet points) destacando os insights mais importantes (ex: maior gasto, categoria dominante, dia da semana com mais compras).
    3.  **Sugestão Prática:** Uma dica acionável e personalizada para o usuário economizar ou otimizar seus gastos no próximo mês.

    Use um tom amigável e encorajador. Formate a resposta usando Markdown para melhor visualização (títulos com ##, listas com *).

    Dados dos Gastos:
    $dadosJsonFormatados
    """;

    try {
      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        // Tenta decodificar a mensagem de erro da API
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('Falha na API da IA: ${error['error']?['message'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      throw Exception('Erro ao gerar análise: $e');
    }
  }
}
