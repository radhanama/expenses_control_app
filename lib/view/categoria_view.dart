import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/categoria_view_model.dart';
import '../view_model/usuario_view_model.dart';
import 'package:expenses_control/models/categoria.dart';

class CategoriaView extends StatefulWidget {
  @override
  _CategoriaViewState createState() => _CategoriaViewState();
}

class _CategoriaViewState extends State<CategoriaView> {
  Categoria? _findCategoryById(List<Categoria> categorias, int? id) {
    if (id == null) return null;
    try {
      return categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _deleteCategory(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta categoria?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () async {
                await context.read<CategoriaViewModel>().deletarCategoria(id);
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int? parentId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Nova Categoria'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              final categorias = context.read<CategoriaViewModel>().categorias;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(hintText: 'Título'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(hintText: 'Descrição'),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: parentId,
                      decoration: InputDecoration(labelText: 'Categoria Pai'),
                      items: [
                        DropdownMenuItem<int?>(
                            value: null, child: Text('Nenhuma')),
                        ...categorias
                            .map((c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.titulo),
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => setState(() => parentId = v),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final usuarioId =
                    context.read<UsuarioViewModel>().usuarioLogado?.id ?? 0;
                await context.read<CategoriaViewModel>().adicionarCategoria(
                      tituloCtrl.text,
                      descCtrl.text,
                      usuarioId,
                      parentId: parentId,
                    );
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Categoria categoria) {
    final tituloCtrl = TextEditingController(text: categoria.titulo);
    final descCtrl = TextEditingController(text: categoria.descricao);
    int? parentId = categoria.parentId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Editar Categoria'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              final categorias = context
                  .read<CategoriaViewModel>()
                  .categorias
                  .where((c) => c.id != categoria.id)
                  .toList();
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(hintText: 'Título'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(hintText: 'Descrição'),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: parentId,
                      decoration: InputDecoration(labelText: 'Categoria Pai'),
                      items: [
                        DropdownMenuItem<int?>(
                            value: null, child: Text('Nenhuma')),
                        ...categorias
                            .map((c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.titulo),
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => setState(() => parentId = v),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<CategoriaViewModel>().atualizarCategoria(
                      categoria.copyWith(
                        titulo: tituloCtrl.text,
                        descricao: descCtrl.text,
                        parentId: parentId,
                      ),
                    );
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Categorias'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: Icon(Icons.add),
      ),
      body: Consumer<CategoriaViewModel>(
        builder: (context, vm, _) => ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: vm.categorias.length,
          itemBuilder: (context, index) {
            final category = vm.categorias[index];
            final parent = _findCategoryById(vm.categorias, category.parentId);
            final displayTitle = parent != null
                ? '${parent.titulo} > ${category.titulo}'
                : category.titulo;
            return Card(
              margin: EdgeInsets.only(bottom: 8.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(displayTitle, style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _showEditCategoryDialog(context, category),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          child: Text('Editar', style: TextStyle(fontSize: 12)),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () =>
                              _deleteCategory(context, category.id ?? 0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          child:
                              Text('Excluir', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
