import '../services/simple_text_service.dart';
import 'gasto_input_strategy.dart';

class SimpleTextInputStrategy implements GastoInputStrategy {
  final SimpleTextService service;
  SimpleTextInputStrategy(this.service);

  @override
  Future<Map<String, dynamic>> process(String input) {
    return service.parseExpense(input);
  }
}
