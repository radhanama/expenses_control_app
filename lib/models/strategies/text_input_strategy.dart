import '../services/gemini_service.dart';
import 'gasto_input_strategy.dart';

class TextInputStrategy implements GastoInputStrategy {
  final GeminiService _geminiService;
  final List<String> _categorias;

  TextInputStrategy({required GeminiService geminiService, List<String> categorias = const []})
      : _geminiService = geminiService,
        _categorias = categorias;

  @override
  Future<Map<String, dynamic>> process(String input) {
    return _geminiService.parseExpense(input, categorias: _categorias);
  }
}
