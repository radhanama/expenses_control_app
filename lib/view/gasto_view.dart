import 'package:expenses_control_app/view_model/usuario_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/gasto_view_model.dart';
import '../view_model/categoria_view_model.dart';
import 'package:expenses_control/models/gasto.dart';

class GastoView extends StatefulWidget {
  final Map<String, dynamic>? dadosIniciais;

  const GastoView({super.key, this.dadosIniciais});

  @override
  _GastoViewState createState() => _GastoViewState();
}

class _GastoViewState extends State<GastoView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _estabelecimentoController =
      TextEditingController();
  final TextEditingController _localidadeController = TextEditingController();
  List<Map<String, dynamic>> _produtos = [
    {'descricao': '', 'quantidade': '', 'preco': '', 'categoria': ''}
  ];
  final TextEditingController _totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.dadosIniciais != null) {
      _preencherDadosIniciais(widget.dadosIniciais!);
    }
  }

  void _preencherDadosIniciais(Map<String, dynamic> dados) {
    _estabelecimentoController.text = dados['estabelecimento']?['nome'] ?? '';
    _localidadeController.text =
        dados['estabelecimento']?['endereco_completo'] ?? '';

    final dataString = dados['informacao_geral']?['data_hora_emissao'];
    if (dataString != null) {
      try {
        final format = DateFormat("dd/MM/yyyy HH:mm:ss");
        _selectedDate = format.parse(dataString.split('-')[0].trim());
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }

    final List<dynamic> itens = dados['itens'] ?? [];
    if (itens.isNotEmpty) {
      final categorias = context.read<CategoriaViewModel>().categorias;
      final cat = categorias.isNotEmpty ? categorias.first.titulo : 'Outros';
      _produtos = itens.map((item) {
        return {
          'descricao': item['nome'] ?? '',
          'quantidade': item['qtd']?.toString() ?? '1',
          'preco': item['valor_unitario']?.toStringAsFixed(2) ?? '0.00',
          'categoria': cat
        };
      }).toList();
    }

    _totalController.text =
        dados['compra']?['valor_a_pagar']?.toStringAsFixed(2) ?? '0.00';
  }

  @override
  void dispose() {
    _estabelecimentoController.dispose();
    _localidadeController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _addItem() {
    final categorias = context.read<CategoriaViewModel>().categorias;
    final cat = categorias.isNotEmpty ? categorias.first.titulo : 'Outros';
    setState(() {
      _produtos.add(
          {'descricao': '', 'quantidade': '', 'preco': '', 'categoria': cat});
    });
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<GastoViewModel>();
      final usuarioId = context.read<UsuarioViewModel>().usuarioLogado?.id ?? 0;
      final categorias = context.read<CategoriaViewModel>().categorias;
      final catTitulo = _produtos.isNotEmpty
          ? _produtos.first['categoria'] ?? 'Outros'
          : 'Outros';
      final categoria = categorias.firstWhere(
        (c) => c.titulo == catTitulo,
        orElse: () => categorias.first,
      );

      final gasto = Gasto(
        usuarioId: usuarioId,
        categoriaId: categoria.id ?? 0,
        total: double.tryParse(_totalController.text.replaceAll(',', '.')) ?? 0,
        data: _selectedDate ?? DateTime.now(),
        local: _localidadeController.text,
      );
      await vm.salvarGasto(gasto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa cadastrada com sucesso!')),
        );
        Navigator.pop(context);
      }
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
              _buildTextField(_estabelecimentoController, 'Estabelecimento',
                  'Nome do local'),
              _buildTextField(
                  _localidadeController, 'Localidade', 'Cidade, Estado'),
              SizedBox(height: 12),
              _buildProductItems(),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: Icon(Icons.add),
                label: Text('Adicionar item'),
              ),
              SizedBox(height: 12),
              _buildTextField(_totalController, 'Total (R\$)', '0,00',
                  keyboardType: TextInputType.number, isTotal: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Salvar Despesa', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Seus métodos de build (_buildDatePicker, _buildTextField, _buildProductItems)
  // podem ser mantidos como estão no seu arquivo original `gasto_view.dart`.
  // Apenas certifique-se de que eles usem os controllers e a lista `_produtos`
  // que agora são preenchidos dinamicamente.
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data da Compra',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _selectedDate == null
                      ? 'Selecione a data'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
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

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {TextInputType keyboardType = TextInputType.text, bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
          Text('Itens da Nota',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          ..._produtos.asMap().entries.map((entry) {
            Map<String, dynamic> produto = entry.value;
            // Cria controllers para cada campo de produto para poder preenchê-los
            final descController =
                TextEditingController(text: produto['descricao']);
            final qtdController =
                TextEditingController(text: produto['quantidade']);
            final precoController =
                TextEditingController(text: produto['preco']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: descController,
                    decoration:
                        InputDecoration(hintText: 'Descrição do produto'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null,
                    onChanged: (value) => produto['descricao'] = value,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qtdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Qtd'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obrigatório' : null,
                          onChanged: (value) => produto['quantidade'] = value,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: precoController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(hintText: 'Preço R\$'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obrigatório' : null,
                          onChanged: (value) => produto['preco'] = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Consumer<CategoriaViewModel>(
                    builder: (context, vm, _) =>
                        DropdownButtonFormField<String>(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      hint: Text('Categoria'),
                      value: produto['categoria'].isEmpty
                          ? null
                          : produto['categoria'],
                      items: vm.categorias
                          .map((c) => DropdownMenuItem(
                              value: c.titulo, child: Text(c.titulo)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => produto['categoria'] = value!),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obrigatório' : null,
                    ),
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
