// lib/view/dashboard_view.dart
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

class _DashboardViewState extends State<DashboardView> {
  // Dados para o Gráfico de Pizza e de Linha serão construídos dinamicamente

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
        children: [
          _buildStatsCards(context),
          _buildLineChart(),
          _buildPieChart(),
        ],
      ),
    );
  }

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
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: cards,
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
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
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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
        values.isEmpty ? 0.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      height: 300,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
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
        children: [
          const Text('Evolução de Gastos (Últimos 6 meses)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
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
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                minY: 0,
                maxY: maxY == 0 ? 1 : maxY,
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
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
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
        children: [
          const Text('Distribuição por Categoria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Consumer2<DashboardViewModel, CategoriaViewModel>(
              builder: (context, vm, catVm, _) {
                final catMap = {
                  for (final c in catVm.categorias) c.id: c.titulo
                };
                final entries = vm.resumo.totalPorCategoria.entries.toList();
                final sections = <PieChartSectionData>[];
                for (int i = 0; i < entries.length; i++) {
                  final e = entries[i];
                  sections.add(
                    PieChartSectionData(
                      color: Colors.primaries[i % Colors.primaries.length],
                      value: e.value,
                      title:
                          '${catMap[e.key] ?? 'Cat'}\nR\$${e.value.toStringAsFixed(0)}',
                      radius: 60,
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
      ),
    );
  }
}
