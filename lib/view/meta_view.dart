import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/meta_view_model.dart';
import '../view_model/categoria_view_model.dart';
import '../models/meta.dart';
import '../view_model/usuario_view_model.dart';

class MetaView extends StatefulWidget {
  @override
  _MetaViewState createState() => _MetaViewState();
}

class _MetaViewState extends State<MetaView> {
  void _showAddMetaDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    DateTime mesAno = DateTime(DateTime.now().year, DateTime.now().month);
    int? categoriaId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nova Meta'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              final categorias =
                  context.read<CategoriaViewModel>().categorias;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(hintText: 'Descrição'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: valorCtrl,
                      decoration: const InputDecoration(hintText: 'Valor Limite'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: mesAno,
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 1),
                          helpText: 'Selecione o mês',
                          fieldLabelText: 'Mês',
                          fieldHintText: 'Mês/ano',
                        );
                        if (picked != null) {
                          setState(() => mesAno = picked);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('MM/yyyy').format(mesAno)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: categoriaId,
                      decoration:
                          const InputDecoration(labelText: 'Categoria (opcional)'),
                      items: [
                        const DropdownMenuItem<int?>(
                            value: null, child: Text('Geral')),
                        ...categorias
                            .map((c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.titulo),
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => setState(() => categoriaId = v),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final usuarioId =
                    context.read<UsuarioViewModel>().usuarioLogado?.id ?? 1;
                await context.read<MetaViewModel>().adicionarMeta(
                      Meta(
                        descricao: descCtrl.text,
                        valorLimite: double.tryParse(valorCtrl.text) ?? 0,
                        mesAno: mesAno,
                        categoriaId: categoriaId,
                        usuarioId: usuarioId,
                      ),
                    );
                if (mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MetaViewModel>().carregarMetas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Mensais'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetaDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<MetaViewModel>(
        builder: (context, vm, _) => ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: vm.metas.length,
          itemBuilder: (context, index) {
            final meta = vm.metas[index];
            final mes = DateFormat('MM/yyyy').format(meta.mesAno);
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text('${meta.descricao} - $mes'),
                subtitle: Text('Limite: R\$ ${meta.valorLimite.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => vm.deletarMeta(meta.id ?? 0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
