// lib/view/extrato_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/extrato_view_model.dart';
import '../view_model/categoria_view_model.dart';
import 'package:expenses_control/models/gasto.dart';

class ExtratoView extends StatefulWidget {
  @override
  _ExtratoViewState createState() => _ExtratoViewState();
}

class _ExtratoViewState extends State<ExtratoView> {
  DateTime _selectedMonth = DateTime.now();
  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExtratoViewModel>().carregarGastos());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExtratoViewModel>();
    final filtered = vm.gastos.where((Gasto g) =>
        g.data.year == _selectedMonth.year &&
        g.data.month == _selectedMonth.month &&
        (_selectedCategory == 'Todas' || g.categoria == _selectedCategory));

    final totalGasto = filtered.fold<double>(0, (sum, g) => sum + g.total);

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
              boxShadow: [
                BoxShadow(
                    blurRadius: 2,
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(0, 1))
              ],
            ),
            child: Center(
              child: Text('Total no mês: R\$ ${totalGasto.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildGastosTable(filtered.toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(DateFormat('MMMM y', 'pt_BR').format(_selectedMonth)),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoriaViewModel>(
      builder: (context, vm, _) {
        final items = ['Todas', ...vm.categorias.map((c) => c.titulo)];
        return DropdownButton<String>(
          value: _selectedCategory,
          items: items
              .map((category) =>
                  DropdownMenuItem(value: category, child: Text(category)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        );
      },
    );
  }

  Widget _buildGastosTable(List<Gasto> gastos) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              blurRadius: 2,
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(0, 1))
        ],
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
          ...gastos
              .map((g) => TableRow(children: [
                    _buildTableCell(DateFormat('yyyy-MM-dd').format(g.data)),
                    _buildTableCell('-'),
                    _buildTableCell(g.categoria),
                    _buildTableCell('-'),
                    _buildTableCell('-'),
                    _buildTableCell('R\$ ${g.total.toStringAsFixed(2)}'),
                    _buildTableCell(g.local),
                  ]))
              .toList(),
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
