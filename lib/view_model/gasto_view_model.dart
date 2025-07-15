import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control_app/models/data/categoria_repository.dart';
import 'package:expenses_control_app/models/services/web_scrapping_service.dart';
import 'package:expenses_control_app/models/services/gemini_service.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:flutter/material.dart';
import '../models/strategies/gasto_input_strategy.dart';
import '../models/strategies/qr_code_input_strategy.dart';
import '../models/strategies/text_input_strategy.dart';
import '../models/strategies/image_input_strategy.dart';
import '../models/strategies/html_input_strategy.dart';

class GastoViewModel extends ChangeNotifier {
  final WebScrapingService _webScrapingService;
  final GeminiService _geminiService;
  final GastoRepository _repo;
  final CategoriaRepository _categoriaRepo;

  GastoViewModel({
    required WebScrapingService webScrapingService,
    required GeminiService geminiService,
    required GastoRepository repo,
    required CategoriaRepository categoriaRepo,
  })  : _webScrapingService = webScrapingService,
        _geminiService = geminiService,
        _repo = repo,
        _categoriaRepo = categoriaRepo;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _scrapedData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get scrapedData => _scrapedData;

  Future<Gasto> salvarGasto(Gasto gasto) async {
    return _repo.create(gasto);
  }

  Future<void> atualizarGasto(Gasto gasto) async {
    await _repo.update(gasto);
    notifyListeners();
  }

  Future<void> deletarGasto(int id) async {
    await _repo.delete(id);
    notifyListeners();
  }

  Future<List<Gasto>> listarGastos() => _repo.findAll();

  Future<bool> _processar(String entrada, GastoInputStrategy estrategia) async {
    _isLoading = true;
    _errorMessage = null;
    _scrapedData = null;
    notifyListeners();
    try {
      _scrapedData = await estrategia.process(entrada);
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

  Future<bool> processarTexto(String texto) async {
    final cats = await _categoriaRepo.findAll();
    final nomesCategorias = cats.map((c) => c.titulo).toList();
    final estrategia =
        TextInputStrategy(geminiService: _geminiService, categorias: nomesCategorias);
    return _processar(texto, estrategia);
  }

  Future<bool> processarQRCode(String url) async {
    if (!url.startsWith(
        'https://consultadfe.fazenda.rj.gov.br/consultaNFCe/QRCode')) {
      _errorMessage = "QR Code inválido. A URL não é de uma nota fiscal do RJ.";
      notifyListeners();
      return false;
    }

    final cats = await _categoriaRepo.findAll();
    final nomesCategorias = cats.map((c) => c.titulo).toList();
    final estrategia = QrCodeInputStrategy(
        scrapingService: _webScrapingService, categorias: nomesCategorias);
    return _processar(url, estrategia);
  }

  Future<bool> processarHtml(String html) async {
    final cats = await _categoriaRepo.findAll();
    final nomesCategorias = cats.map((c) => c.titulo).toList();
    final estrategia = HtmlInputStrategy(
        scrapingService: _webScrapingService, categorias: nomesCategorias);
    return _processar(html, estrategia);
  }

  Future<bool> processarImagem(String caminho) async {
    final cats = await _categoriaRepo.findAll();
    final nomesCategorias = cats.map((c) => c.titulo).toList();
    final estrategia = ImageInputStrategy(
        geminiService: _geminiService, categorias: nomesCategorias);
    return _processar(caminho, estrategia);
  }
}
