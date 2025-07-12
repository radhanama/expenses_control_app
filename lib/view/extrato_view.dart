import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../view_model/extrato_view_model.dart';
import '../view_model/categoria_view_model.dart';
import 'package:expenses_control/models/gasto.dart';
import 'gasto_detalhe_view.dart';

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
    final categorias = context.watch<CategoriaViewModel>().categorias;
    final catMap = {for (final c in categorias) c.id: c.titulo};

    final filtered = vm.gastos.where((Gasto g) {
      final catTitulo = catMap[g.categoriaId] ?? '';
      return g.data.year == _selectedMonth.year &&
          g.data.month == _selectedMonth.month &&
          (_selectedCategory == 'Todas' || catTitulo == _selectedCategory);
    }).toList();

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
              child: _buildGastosTable(filtered, catMap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedMonth,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('pt', 'BR'),
        );
        if (picked != null) {
          setState(() => _selectedMonth = DateTime(picked.year, picked.month));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(DateFormat('MMMM y', 'pt_BR').format(_selectedMonth)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
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

  Widget _buildGastosTable(List<Gasto> gastos, Map<int?, String> catMap) {
    if (gastos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Nenhum gasto encontrado'),
      );
    }

    final rows = gastos
        .map(
          (g) => DataRow(
            cells: [
              DataCell(Text(DateFormat('yyyy-MM-dd').format(g.data))),
              DataCell(Text(catMap[g.categoriaId] ?? '')),
              DataCell(Text('R\$ ${g.total.toStringAsFixed(2)}')),
              DataCell(Text(g.local)),
            ],
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GastoDetalheView(gasto: g),
                ),
              );
            },
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Local')),
          ],
          rows: rows,
        ),
      ),
    );
  }

}
