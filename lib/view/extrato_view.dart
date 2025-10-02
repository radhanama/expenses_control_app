import 'package:expenses_control/models/categoria.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import '../view_model/categoria_view_model.dart';
import '../view_model/extrato_view_model.dart';
import 'categoria_cache_view.dart';
import 'extrato_import_view.dart';
import 'gasto_detalhe_view.dart';

class ExtratoView extends StatefulWidget {
  @override
  _ExtratoViewState createState() => _ExtratoViewState();
}

class _ExtratoViewState extends State<ExtratoView> {
  DateTime _selectedMonth = DateTime.now();
  int? _selectedCategoryId;
  final NumberFormat _currencyFormatter =
      NumberFormat.simpleCurrency(locale: 'pt_BR');
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExtratoViewModel>().carregarGastos());
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extratoViewModel = context.watch<ExtratoViewModel>();
    final categoriaViewModel = context.watch<CategoriaViewModel>();
    final categorias = categoriaViewModel.categorias;
    final categoriaMap = _createCategoriaMap(categorias);
    final filteredGastos = _applyFilters(extratoViewModel.gastos);
    final totalGasto = _calculateTotal(filteredGastos);

    return Scaffold(
      appBar: AppBar(
        title: Text('Extrato de Gastos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Ajustar categorias sugeridas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriaCacheView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(categorias),
          _buildSummaryCard(totalGasto),
          Expanded(
            child: _buildGastosTable(filteredGastos, categoriaMap),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExtratoImportView(),
            ),
          );
        },
        icon: const Icon(Icons.file_upload),
        label: const Text('Importar extrato'),
      ),
    );
  }

  Map<int?, String> _createCategoriaMap(List<Categoria> categorias) {
    return {for (final categoria in categorias) categoria.id: categoria.titulo};
  }

  List<Gasto> _applyFilters(List<Gasto> gastos) {
    return gastos.where((gasto) {
      final sameYear = gasto.data.year == _selectedMonth.year;
      final sameMonth = gasto.data.month == _selectedMonth.month;
      final matchesCategory =
          _selectedCategoryId == null || gasto.categoriaId == _selectedCategoryId;
      return sameYear && sameMonth && matchesCategory;
    }).toList();
  }

  double _calculateTotal(List<Gasto> gastos) {
    return gastos.fold<double>(0, (sum, gasto) => sum + gasto.total);
  }

  Widget _buildFilters(List<Categoria> categorias) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Mês:'),
          _buildMonthPicker(context),
          const Text('Categoria:'),
          _buildCategoryDropdown(categorias),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    final monthLabel = toBeginningOfSentenceCase(
          DateFormat('MMMM y', 'pt_BR').format(_selectedMonth),
        ) ??
        '';

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showMonthPicker(
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
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(monthLabel),
    );
  }

  Widget _buildCategoryDropdown(List<Categoria> categorias) {
    final dropdownItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
      ...categorias.map(
        (categoria) => DropdownMenuItem<int?>(
          value: categoria.id,
          child: Text(categoria.titulo),
        ),
      ),
    ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<int?>(
        value: _selectedCategoryId,
        items: dropdownItems,
        onChanged: (value) {
          setState(() => _selectedCategoryId = value);
        },
      ),
    );
  }

  Widget _buildSummaryCard(double totalGasto) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total no mês',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              _currencyFormatter.format(totalGasto),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGastosTable(List<Gasto> gastos, Map<int?, String> catMap) {
    if (gastos.isEmpty) {
      return const Center(
        child: Text('Nenhum gasto encontrado'),
      );
    }

    final sortedGastos = [...gastos]
      ..sort((a, b) => b.data.compareTo(a.data));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  notificationPredicate: (notification) => notification.depth == 1,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.grey.shade200,
                        ),
                        columns: const [
                          DataColumn(label: Text('Data')),
                          DataColumn(label: Text('Categoria')),
                          DataColumn(label: Text('Total'), numeric: true),
                          DataColumn(label: Text('Local')),
                        ],
                        rows: sortedGastos
                            .map(
                              (gasto) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(DateFormat('dd/MM/yyyy').format(gasto.data)),
                                  ),
                                  DataCell(Text(catMap[gasto.categoriaId] ?? '-')),
                                  DataCell(Text(_currencyFormatter.format(gasto.total))),
                                  DataCell(Text(gasto.local.isEmpty ? '-' : gasto.local)),
                                ],
                                onSelectChanged: (_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GastoDetalheView(gasto: gasto),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
