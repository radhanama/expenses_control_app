// lib/view/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Dados para o Gráfico de Pizza serão construídos dinamicamente

  // Dados para o Gráfico de Linha (FL_CHART)
  final List<FlSpot> _lineSpots = const [
    FlSpot(0, 900), // Mar
    FlSpot(1, 1100), // Abr
    FlSpot(2, 1250), // Mai
    FlSpot(3, 1000), // Jun
    FlSpot(4, 1350), // Jul
    FlSpot(5, 1250), // Ago
  ];

  // Labels para o eixo X do gráfico de linha
  final List<String> _lineLabels = const ['Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'];

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildStatCard(context, 'Total no Mês',
              'R\$ ${vm.resumo.totalGastos.toStringAsFixed(2)}'),
          _buildStatCard(context, 'Transações', vm.transacoes.toString()),
          _buildStatCard(
              context,
              'Alimentação',
              'R\$ ${vm.resumo.totalPorCategoria['Alimentação']?.toStringAsFixed(2) ?? '0.00'}'),
          _buildStatCard(
              context,
              'Transporte',
              'R\$ ${vm.resumo.totalPorCategoria['Transporte']?.toStringAsFixed(2) ?? '0.00'}'),
        ],
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
              blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.blue)),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: const Offset(0, 1))
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
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(_lineLabels[value.toInt()]),
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
                maxX: 5,
                minY: 0,
                maxY: 1500,
                lineBarsData: [
                  LineChartBarData(
                    spots: _lineSpots,
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
              blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          const Text('Distribuição por Categoria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Consumer<DashboardViewModel>(
              builder: (context, vm, _) {
                final sections = vm.resumo.totalPorCategoria.entries
                    .map(
                      (e) => PieChartSectionData(
                        color: Colors.blue,
                        value: e.value,
                        title: '${e.key}\nR\$${e.value.toStringAsFixed(0)}',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        titlePositionPercentageOffset: 0.55,
                      ),
                    )
                    .toList();
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