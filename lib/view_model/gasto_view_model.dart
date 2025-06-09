import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control_app/models/services/web_scrapping_service.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:flutter/material.dart';

class GastoViewModel extends ChangeNotifier {
  final WebScrapingService _webScrapingService;
  final GastoRepository _repo;

  GastoViewModel({
    required WebScrapingService webScrapingService,
    required GastoRepository repo,
  })  : _webScrapingService = webScrapingService,
        _repo = repo;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _scrapedData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get scrapedData => _scrapedData;

  Future<Gasto> salvarGasto(Gasto gasto) async {
    return _repo.create(gasto);
  }

  Future<List<Gasto>> listarGastos() => _repo.findAll();

  Future<bool> processarQRCode(String url) async {
    // Validação básica da URL
    if (!url.startsWith(
        'https://consultadfe.fazenda.rj.gov.br/consultaNFCe/QRCode')) {
      _errorMessage = "QR Code inválido. A URL não é de uma nota fiscal do RJ.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _scrapedData = null;
    notifyListeners();

    try {
      _scrapedData = await _webScrapingService.scrapeNfceFromUrl(url);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
