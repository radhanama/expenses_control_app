import 'package:flutter/material.dart';

class CategoriaView extends StatefulWidget {
  @override
  _CategoriaViewState createState() => _CategoriaViewState();
}

class _CategoriaViewState extends State<CategoriaView> {
  List<String> _categories = ['Alimentação', 'Transporte', 'Lazer', 'Outros'];

  void _addCategory(String newCategory) {
    setState(() {
      _categories.add(newCategory);
    });
  }

  void _editCategory(int index, String newName) {
    setState(() {
      _categories[index] = newName;
    });
  }

  void _deleteCategory(int index) {
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
                setState(() {
                  _categories.removeAt(index);
                });
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
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8.0),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category, style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController _editController = TextEditingController(text: category);
                              return AlertDialog(
                                title: Text('Renomear Categoria'),
                                content: TextField(
                                  controller: _editController,
                                  decoration: InputDecoration(hintText: 'Novo nome da categoria'),
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
                                      if (_editController.text.isNotEmpty) {
                                        _editCategory(index, _editController.text);
                                      }
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: Text('Editar', style: TextStyle(fontSize: 12)),
                      ),
                      SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () => _deleteCategory(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: Text('Excluir', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}