import 'dart:io';
import '../services/gemini_service.dart';
import 'gasto_input_strategy.dart';

class ImageInputStrategy implements GastoInputStrategy {
  final GeminiService _geminiService;
  final List<String> _categorias;

  ImageInputStrategy({required GeminiService geminiService, List<String> categorias = const []})
      : _geminiService = geminiService,
        _categorias = categorias;

  @override
  Future<Map<String, dynamic>> process(String input) async {
    final bytes = await File(input).readAsBytes();
    return _geminiService.parseExpenseFromImage(bytes, categorias: _categorias);
  }
}
