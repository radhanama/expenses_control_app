import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/categoria_view_model.dart';

class CategoriaView extends StatefulWidget {
  @override
  _CategoriaViewState createState() => _CategoriaViewState();
}

class _CategoriaViewState extends State<CategoriaView> {
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
              onPressed: () {
                // Não implementado: lógica de exclusão
                Navigator.of(context).pop();
              },
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.add),
        //     onPressed: () async {
        //       final newCategory = await Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => NovaCategoriaScreen()),
        //       );
        //       if (newCategory != null && newCategory.isNotEmpty) {
        //         _addCategory(newCategory);
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Consumer<CategoriaViewModel>(
        builder: (context, vm, _) => ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: vm.categorias.length,
          itemBuilder: (context, index) {
            final category = vm.categorias[index];
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
                    Text(category.titulo, style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController _editController =
                                    TextEditingController(
                                        text: category.titulo);
                                return AlertDialog(
                                  title: Text('Renomear Categoria'),
                                  content: TextField(
                                    controller: _editController,
                                    decoration: InputDecoration(
                                        hintText: 'Novo nome da categoria'),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancelar'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Salvar'),
                                      onPressed: () {
                                        // Não implementado: edição de categoria
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
