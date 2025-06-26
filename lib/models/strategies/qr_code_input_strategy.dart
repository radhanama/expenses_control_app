import '../services/web_scrapping_service.dart';
import 'gasto_input_strategy.dart';

class QrCodeInputStrategy implements GastoInputStrategy {
  final WebScrapingService _scrapingService;
  final List<String> _categorias;

  QrCodeInputStrategy(
      {required WebScrapingService scrapingService, List<String> categorias = const []})
      : _scrapingService = scrapingService,
        _categorias = categorias;

  @override
  Future<Map<String, dynamic>> process(String input) {
    return _scrapingService.scrapeNfceFromUrl(input, categorias: _categorias);
  }
}
