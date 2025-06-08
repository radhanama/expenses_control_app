// lib/view/extrato_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
// Importe diretamente a função showMonthPicker do pacote
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ExtratoView extends StatefulWidget {
  @override
  _ExtratoViewState createState() => _ExtratoViewState();
}

class _ExtratoViewState extends State<ExtratoView> {
  DateTime _selectedMonth = DateTime.now();
  String _selectedCategory = 'Todas';

  // Dados fictícios (substitua com sua lógica de dados)
  final List<Map<String, dynamic>> _gastos = [
    {'data': DateTime(2025, 5, 2), 'desc': 'Almoço Restaurante', 'cat': 'Alimentação', 'qtd': 1, 'preco': 45.50, 'local': 'Rio de Janeiro'},
    {'data': DateTime(2025, 5, 5), 'desc': 'Uber', 'cat': 'Transporte', 'qtd': 1, 'preco': 32.80, 'local': 'Rio de Janeiro'},
    {'data': DateTime(2025, 5, 10), 'desc': 'Cinema', 'cat': 'Lazer', 'qtd': 2, 'preco': 25.00, 'local': 'Niterói'},
    {'data': DateTime(2025, 4, 28), 'desc': 'Supermercado', 'cat': 'Alimentação', 'qtd': 5, 'preco': 12.00, 'local': 'São Paulo'},
    {'data': DateTime(2025, 5, 15), 'desc': 'Café', 'cat': 'Outros', 'qtd': 1, 'preco': 8.00, 'local': 'Rio de Janeiro'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredGastos = _gastos.where((gasto) =>
        gasto['data'].year == _selectedMonth.year &&
        gasto['data'].month == _selectedMonth.month &&
        (_selectedCategory == 'Todas' || gasto['cat'] == _selectedCategory))
        .toList();

    final totalGasto = filteredGastos.fold<double>(0, (sum, gasto) => sum + (gasto['qtd'] * gasto['preco']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Extrato de Gastos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mês:'),
                _buildMonthPicker(context),
                Text('Categoria:'),
                _buildCategoryDropdown(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: Offset(0, 1))],
            ),
            child: Center(
              child: Text('Total no mês: R\$ ${totalGasto.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildGastosTable(filteredGastos),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return InkWell(
      onTap: () {
        // Chame showMonthPicker diretamente, não como um método de 'this'
        showMonthPicker(
          context: context,
          initialDate: _selectedMonth,
          firstDate: DateTime(2000), // Adicione um range para evitar erros
          lastDate: DateTime(2100),  // Adicione um range para evitar erros
        ).then((date) {
          if (date != null) {
            setState(() {
              _selectedMonth = date;
            });
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(DateFormat('MMMM y', 'pt_BR').format(_selectedMonth)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      items: ['Todas', 'Alimentação', 'Transporte', 'Lazer', 'Outros']
          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildGastosTable(List<Map<String, dynamic>> gastos) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: Offset(0, 1))],
      ),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(0.8),
          4: FlexColumnWidth(1.0),
          5: FlexColumnWidth(1.0),
          6: FlexColumnWidth(1.5),
        },
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              _buildTableCell('Data', isHeader: true),
              _buildTableCell('Descrição', isHeader: true),
              _buildTableCell('Categoria', isHeader: true),
              _buildTableCell('Qtd', isHeader: true),
              _buildTableCell('Preço', isHeader: true),
              _buildTableCell('Total', isHeader: true),
              _buildTableCell('Local', isHeader: true),
            ],
          ),
          ...gastos.map((gasto) => TableRow(children: [
            _buildTableCell(DateFormat('yyyy-MM-dd').format(gasto['data'])),
            _buildTableCell(gasto['desc']),
            _buildTableCell(gasto['cat']),
            _buildTableCell(gasto['qtd'].toString()),
            _buildTableCell('R\$ ${gasto['preco'].toStringAsFixed(2)}'),
            _buildTableCell('R\$ ${(gasto['qtd'] * gasto['preco']).toStringAsFixed(2)}'),
            _buildTableCell(gasto['local']),
          ])).toList(),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 12,
        ),
      ),
    );
  }
}