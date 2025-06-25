import '../services/web_scrapping_service.dart';
import 'gasto_input_strategy.dart';

class QrCodeInputStrategy implements GastoInputStrategy {
  final WebScrapingService _scrapingService;

  QrCodeInputStrategy({required WebScrapingService scrapingService})
      : _scrapingService = scrapingService;

  @override
  Future<Map<String, dynamic>> process(String input) {
    return _scrapingService.scrapeNfceFromUrl(input);
  }
}
