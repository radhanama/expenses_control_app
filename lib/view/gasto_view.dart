import 'package:flutter/material.dart';

class GastoView extends StatefulWidget {
  @override
  _GastoViewState createState() => _GastoViewState();
}

class _GastoViewState extends State<GastoView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TextEditingController _estabelecimentoController = TextEditingController();
  TextEditingController _localidadeController = TextEditingController();
  List<Map<String, dynamic>> _produtos = [
    {'descricao': '', 'quantidade': '', 'preco': '', 'categoria': ''}
  ];
  TextEditingController _totalController = TextEditingController();

  @override
  void dispose() {
    _estabelecimentoController.dispose();
    _localidadeController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _produtos.add({'descricao': '', 'quantidade': '', 'preco': '', 'categoria': ''});
    });
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aqui você faria a lógica para salvar a despesa
      // Por exemplo, enviar para um banco de dados ou lista
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Despesa cadastrada com sucesso!')),
      );
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Despesa'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDatePicker(),
              _buildTextField(_estabelecimentoController, 'Estabelecimento', 'Nome do local'),
              _buildTextField(_localidadeController, 'Localidade', 'Cidade, Estado'),
              SizedBox(height: 12),
              _buildProductItems(),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: Icon(Icons.add),
                label: Text('Adicionar item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue, style: BorderStyle.solid),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 12),
              _buildTextField(_totalController, 'Total (R\$)', '0,00', keyboardType: TextInputType.number, isTotal: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text('Salvar Despesa', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data da Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _selectedDate == null
                      ? 'Selecione a data'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text, bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira $label';
            }
            return null;
          },
          onSaved: (value) {
            // Salvar o valor aqui
          },
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProductItems() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itens da Nota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          ..._produtos.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> produto = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Descrição do produto',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                    onChanged: (value) => produto['descricao'] = value,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Qtd',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                          onChanged: (value) => produto['quantidade'] = value,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Preço R\$',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                          onChanged: (value) => produto['preco'] = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    hint: Text('Categoria'),
                    value: produto['categoria'].isEmpty ? null : produto['categoria'],
                    items: ['Alimentação', 'Transporte', 'Lazer', 'Outros']
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        produto['categoria'] = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione uma categoria';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}