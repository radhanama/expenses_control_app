import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/extrato_view_model.dart';
import '../view_model/usuario_view_model.dart';

class ExtratoImportView extends StatefulWidget {
  const ExtratoImportView({super.key});

  @override
  State<ExtratoImportView> createState() => _ExtratoImportViewState();
}

class _ExtratoImportViewState extends State<ExtratoImportView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _importar() async {
    final extrato = _controller.text.trim();
    if (extrato.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cole o conteúdo do extrato antes de importar.')),
      );
      return;
    }

    final usuario = context.read<UsuarioViewModel>().usuarioLogado;
    if (usuario == null || usuario.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para importar um extrato.')),
      );
      return;
    }

    final vm = context.read<ExtratoViewModel>();
    try {
      final quantidade =
          await vm.importarExtrato(extrato, usuario.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$quantidade lançamento(s) importado(s) com sucesso.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao importar extrato: ${vm.importError ?? e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtratoViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Importar extrato'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Cole aqui o conteúdo CSV do extrato...',
                  ),
                ),
                const SizedBox(height: 16),
                vm.importando
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _importar,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Importar extrato'),
                        ),
                      ),
                if (vm.importError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    vm.importError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
