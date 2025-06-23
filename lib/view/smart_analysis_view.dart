import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../view_model/smart_analysis_view_model.dart';

class SmartAnalysisView extends StatefulWidget {
  const SmartAnalysisView({super.key});

  @override
  State<SmartAnalysisView> createState() => _SmartAnalysisViewState();
}

class _SmartAnalysisViewState extends State<SmartAnalysisView> {
  @override
  void initState() {
    super.initState();
    // Inicia a busca pela análise assim que a tela é construída pela primeira vez.
    // Isso pode ser ativado ou desativado conforme a sua preferência.
    // Se preferir que o usuário sempre clique, comente a linha abaixo.
    Future.microtask(() => context.read<SmartAnalysisViewModel>().buscarAnalise());
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um Consumer para reagir às mudanças do ViewModel
    return Consumer<SmartAnalysisViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100], // Cor de fundo suave
          appBar: AppBar(
            title: const Text('Análise Inteligente ✨'),
            centerTitle: true,
            elevation: 1,
          ),
          body: Center(
            child: _buildContent(context, viewModel),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: viewModel.isLoading ? null : () => viewModel.buscarAnalise(),
            label: const Text('Gerar Nova Análise'),
            icon: const Icon(Icons.auto_awesome),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SmartAnalysisViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Nossa IA está analisando seus dados...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      );
    }

    if (viewModel.errorMessage != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Text(
                'Ocorreu um erro',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.analysisResult != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            // Usamos o pacote flutter_markdown para renderizar a resposta da IA
            child: MarkdownBody(
              data: viewModel.analysisResult!,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 16, height: 1.5),
                h2: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue[800]),
              ),
            ),
          ),
        ),
      );
    }

    // Estado inicial
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insights, size: 80, color: Colors.blue),
        SizedBox(height: 16),
        Text(
          'Receba insights sobre seus hábitos financeiros.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Clique no botão abaixo para começar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
