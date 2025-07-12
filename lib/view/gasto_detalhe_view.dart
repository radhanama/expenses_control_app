import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expenses_control/models/gasto.dart';
import '../view_model/categoria_view_model.dart';
import '../view_model/gasto_view_model.dart';
import '../view_model/extrato_view_model.dart';

class GastoDetalheView extends StatefulWidget {
  final Gasto gasto;
  const GastoDetalheView({super.key, required this.gasto});

  @override
  State<GastoDetalheView> createState() => _GastoDetalheViewState();
}

class _GastoDetalheViewState extends State<GastoDetalheView> {
  late DateTime _data;
  late TextEditingController _localController;
  late TextEditingController _totalController;
  int? _categoriaId;

  @override
  void initState() {
    super.initState();
    _data = widget.gasto.data;
    _localController = TextEditingController(text: widget.gasto.local);
    _totalController =
        TextEditingController(text: widget.gasto.total.toStringAsFixed(2));
    _categoriaId = widget.gasto.categoriaId;
  }

  @override
  void dispose() {
    _localController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  Future<void> _salvar() async {
    final atualizado = widget.gasto.copyWith(
      data: _data,
      local: _localController.text,
      total: double.tryParse(_totalController.text.replaceAll(',', '.')) ??
          widget.gasto.total,
      categoriaId: _categoriaId ?? widget.gasto.categoriaId,
    );
    await context.read<GastoViewModel>().atualizarGasto(atualizado);
    await context.read<ExtratoViewModel>().carregarGastos();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deletar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir gasto'),
        content: const Text('Tem certeza que deseja excluir este gasto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true) {
      final id = widget.gasto.id;
      if (id != null) {
        await context.read<GastoViewModel>().deletarGasto(id);
        await context.read<ExtratoViewModel>().carregarGastos();
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoriaViewModel>().categorias;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Data: '),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _selecionarData,
                  child: Text(DateFormat('dd/MM/yyyy').format(_data)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _categoriaId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: categorias
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.titulo)))
                  .toList(),
              onChanged: (v) => setState(() => _categoriaId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Total R\$'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localController,
              decoration: const InputDecoration(labelText: 'Local'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
                ElevatedButton(
                  onPressed: _deletar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
