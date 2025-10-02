import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/categoria_cache_view_model.dart';
import '../view_model/extrato_view_model.dart';
import '../view_model/usuario_view_model.dart';

class CategoriaCacheView extends StatefulWidget {
  const CategoriaCacheView({super.key});

  @override
  State<CategoriaCacheView> createState() => _CategoriaCacheViewState();
}

class _CategoriaCacheViewState extends State<CategoriaCacheView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final usuarioId =
          context.read<UsuarioViewModel>().usuarioLogado?.id ?? 0;
      context.read<CategoriaCacheViewModel>().carregar(usuarioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriaCacheViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar categorias sugeridas'),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, CategoriaCacheViewModel vm) {
    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }
    if (vm.caches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nenhum mapeamento salvo até o momento. '
            'Importe um extrato para que as sugestões apareçam aqui.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final categorias = vm.categorias;
    if (categorias.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Cadastre categorias antes de ajustar os mapeamentos.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final cache = vm.caches[index];
        final possuiCategoria = categorias.any((c) => c.id == cache.categoriaId);
        final fallbackId = categorias.first.id ?? cache.categoriaId;
        final valorSelecionado =
            possuiCategoria ? cache.categoriaId : fallbackId;
        final categoriaAtual =
            vm.obterCategoriaPorId(valorSelecionado)?.titulo ?? 'Sem categoria';
        return Card(
          child: ListTile(
            title: Text(cache.descricaoOriginal),
            subtitle: Text('Categoria atual: $categoriaAtual'),
            trailing: DropdownButton<int>(
              value: valorSelecionado,
              items: categorias
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.titulo),
                    ),
                  )
                  .toList(),
              onChanged: vm.estaAtualizando(cache.id)
                  ? null
                  : (value) async {
                      if (value == null) return;
                      final scaffold = ScaffoldMessenger.of(context);
                      try {
                        final afetados = await vm.atualizarCategoria(
                          cache.copyWith(categoriaId: valorSelecionado),
                          value,
                        );
                        if (!mounted) return;
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text(
                              afetados > 0
                                  ? 'Categoria atualizada em $afetados lançamentos.'
                                  : 'Categoria atualizada para novos lançamentos.',
                            ),
                          ),
                        );
                        await context
                            .read<ExtratoViewModel>()
                            .carregarGastos();
                      } catch (_) {
                        if (!mounted) return;
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Não foi possível atualizar a categoria. Tente novamente.',
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: vm.caches.length,
    );
  }
}
