import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_control_app/models/services/web_scrapping_service.dart';
import 'package:expenses_control_app/models/services/gemini_service.dart';

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

    final data = await scrapingService.scrapeNfceFromUrl(url);

    expect(data, isA<Map<String, dynamic>>());
    expect(data, contains('estabelecimento'));
    expect(data, contains('itens'));
    expect(data, contains('compra'));
  });
}
