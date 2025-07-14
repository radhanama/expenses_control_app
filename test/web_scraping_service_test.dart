import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_control_app/models/services/web_scrapping_service.dart';
import 'package:expenses_control_app/models/services/gemini_service.dart';
import 'dart:io';

class FakeGeminiService extends GeminiService {
  FakeGeminiService() : super(apiKey: 'fake');

  @override
  Future<Map<String, dynamic>> parseExpenseFromHtml(String html,
      {List<String> categorias = const []}) async {
    // Avoid network calls during the test.
    return {};
  }
}

void main() {
  test('scrape NFCe page data from URL', () async {
    final scrapingService =
        WebScrapingService(geminiService: FakeGeminiService());

    const url =
        'https://consultadfe.fazenda.rj.gov.br/consultaNFCe/QRCode?p=33240801438784002302650190001481261139805478|2|1|2|2ec33231f58883c2b33b054a7aee2a3a4f3790c7';

    final result =
        await scrapingService.scrapeNfceFromUrl(url, ignoreBadCertificate: true);
    expect(result['requiresRecaptcha'], true);
  });

  test('parse NFCe HTML after solving captcha', () async {
    final html = await File('assets/Consulta DF-e.html').readAsString();
    final scrapingService =
        WebScrapingService(geminiService: FakeGeminiService());

    final result = await scrapingService.parseNfceHtml(html);
    expect(result['itens'], isA<List>());
    expect((result['itens'] as List).isNotEmpty, true);
  });
}
