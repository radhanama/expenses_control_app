import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/gasto_view_model.dart';
import 'gasto_view.dart';

class GeminiTextView extends StatefulWidget {
  const GeminiTextView({super.key});

  @override
  State<GeminiTextView> createState() => _GeminiTextViewState();
}

class _GeminiTextViewState extends State<GeminiTextView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final vm = context.read<GastoViewModel>();
    final success = await vm.processarTexto(text);
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GastoView(dadosIniciais: vm.scrapedData),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Erro desconhecido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GastoViewModel>(
      builder: (context, vm, child) => Scaffold(
        appBar: AppBar(title: const Text('Adicionar via texto')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Descreva sua compra...',
                ),
              ),
              const SizedBox(height: 16),
              vm.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Enviar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
