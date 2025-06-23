import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/dashboard_view_model.dart';
import '../view_model/categoria_view_model.dart';


class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

/// Widget que exibe o dashboard de gastos, incluindo gráficos e estatísticas.
///  Utiliza o [DashboardViewModel] para gerenciar o estado e carregar os dados.
///  Exibe gráficos de barras, linha e pizza, além de cards com estatísticas.
class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardViewModel>().carregarResumo());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    if (vm.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Gastos'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildStatsCards(context),
          _buildNewStatCards(context),
          _buildWeekdayBarChart(context),
          _buildTopEstablishmentsCard(context),
          _buildLineChart(),
          _buildPieChart(),
        ],
      ),
    );
  }

  /// Constrói os cards com as estatísticas calculadas.
  Widget _buildNewStatCards(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final comparativo = vm.comparativoMesAnterior;
    final isPositive = comparativo >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildStatCard(context, 'Gasto Médio / Transação',
              'R\$ ${vm.gastoMedioPorTransacao.toStringAsFixed(2)}'),
          _buildStatCard(
            context,
            'vs. Mês Anterior',
            '${isPositive ? '+' : ''}${comparativo.toStringAsFixed(1)}%',
            valueColor: isPositive ? Colors.red.shade700 : Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  /// Constrói um gráfico de barras para os gastos por dia da semana.
  Widget _buildWeekdayBarChart(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final weekdayData = vm.gastosPorDiaDaSemana;
    final labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    // Encontra o valor máximo para ajustar a escala do eixo Y
    final maxY = weekdayData.values.isEmpty
        ? 1.0 // Valor padrão se não houver dados
        : weekdayData.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Gastos por Dia da Semana',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4),
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxY / 4)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(labels[value.toInt() - 1]),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    final day = index + 1;
                    return BarChartGroupData(
                      x: day,
                      barRods: [
                        BarChartRodData(
                          toY: weekdayData[day] ?? 0,
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um card para listar os 5 estabelecimentos com mais gastos.
  Widget _buildTopEstablishmentsCard(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final topEstablishments = vm.top5Estabelecimentos.entries.toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Top 5 Estabelecimentos',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (topEstablishments.isEmpty)
              const Center(child: Text('Nenhum dado de estabelecimento.'))
            else
              ...topEstablishments.asMap().entries.map((entry) {
                final index = entry.key;
                final establishment = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(establishment.key),
                  trailing: Text(
                    'R\$ ${establishment.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // Constrói os cards com as estatísticas principais.
  Widget _buildStatsCards(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final categorias = context.watch<CategoriaViewModel>().categorias;
    final catMap = {for (final c in categorias) c.id: c.titulo};

    final cards = <Widget>[
      _buildStatCard(context, 'Total no Mês',
          'R\$ ${vm.resumo.totalGastos.toStringAsFixed(2)}'),
      _buildStatCard(context, 'Transações', vm.transacoes.toString()),
      ...vm.resumo.totalPorCategoria.entries.map(
        (e) => _buildStatCard(
          context,
          catMap[e.key] ?? 'Categoria ${e.key}',
          'R\$ ${e.value.toStringAsFixed(2)}',
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: cards,
      ),
    );
  }

  // Constrói um card genérico para exibir estatísticas.
  Widget _buildStatCard(BuildContext context, String title, String value,
      {Color? valueColor}) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              blurRadius: 2,
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.blue)),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ],
      ),
    );
  }

  // Constrói o gráfico de linha para evolução de gastos nos últimos 6 meses.
  Widget _buildLineChart() {
    final vm = context.watch<DashboardViewModel>();
    final months = vm.gastosPorMes.keys.toList();
    final values = vm.gastosPorMes.values.toList();

    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])
    ];

    final labels =
        months.map((d) => DateFormat('MMM', 'pt_BR').format(d)).toList();

    final maxY =
        values.isEmpty ? 1.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2);

    return Card(
        elevation: 2,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Evolução de Gastos (Últimos 6 meses)',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true, reservedSize: 40)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0)
                                return const SizedBox.shrink();
                              final idx = value.toInt();
                              if (idx < 0 || idx >= labels.length)
                                return const SizedBox.shrink();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(labels[idx]),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                            color: const Color(0xff37434d), width: 1),
                      ),
                      minX: 0,
                      maxX: (values.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  // Constrói o gráfico de pizza para distribuição por categoria.
  Widget _buildPieChart() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Distribuição por Categoria',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child:
                  Consumer2<DashboardViewModel, CategoriaViewModel>(
                builder: (context, vm, catVm, _) {
                  final catMap = {
                    for (final c in catVm.categorias) c.id: c.titulo
                  };
                  final entries =
                      vm.resumo.totalPorCategoria.entries.toList();
                  final sections = <PieChartSectionData>[];
                  for (int i = 0; i < entries.length; i++) {
                    final e = entries[i];
                    sections.add(
                      PieChartSectionData(
                        color: Colors.primaries[
                            i % Colors.primaries.length],
                        value: e.value,
                        title:
                            '${catMap[e.key] ?? 'Cat'}\nR\$${e.value.toStringAsFixed(0)}',
                        radius: 80,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        titlePositionPercentageOffset: 0.55,
                      ),
                    );
                  }
                  return PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  );
                },
              ),
            ),
          ],
        )));
  }
}
