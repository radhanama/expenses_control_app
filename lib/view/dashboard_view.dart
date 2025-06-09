// lib/view/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardView extends StatelessWidget {

  // Dados para o Gráfico de Pizza serão construídos dinamicamente

  // Dados para o Gráfico de Linha (FL_CHART)
  final List<FlSpot> _lineSpots = [
    FlSpot(0, 900), // Mar
    FlSpot(1, 1100), // Abr
    FlSpot(2, 1250), // Mai
    FlSpot(3, 1000), // Jun
    FlSpot(4, 1350), // Jul
    FlSpot(5, 1250), // Ago
  ];

  // Labels para o eixo X do gráfico de linha
  final List<String> _lineLabels = ['Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de Gastos'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildStatsCards(context), // Passe o contexto explicitamente aqui
          _buildLineChart(),
          _buildPieChart(),
        ],
      ),
    );
  }

  // O método _buildStatCard precisa receber o contexto, já que DashboardView é StatelessWidget
  Widget _buildStatsCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildStatCard(context, 'Total no Mês', 'R\$ ${context.watch<DashboardViewModel>().resumo.totalGastos.toStringAsFixed(2)}'),
          _buildStatCard(context, 'Transações', context.watch<DashboardViewModel>().transacoes.toString()),
          _buildStatCard(context, 'Alimentação', 'R\$ ${context.watch<DashboardViewModel>().resumo.totalPorCategoria['Alimentação']?.toStringAsFixed(2) ?? '0.00'}'),
          _buildStatCard(context, 'Transporte', 'R\$ ${context.watch<DashboardViewModel>().resumo.totalPorCategoria['Transporte']?.toStringAsFixed(2) ?? '0.00'}'),
        ],
      ),
    );
  }

  // Este método já recebe o contexto, está correto
  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: Offset(0, 1))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.blue)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 300,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          Text('Evolução de Gastos (Últimos 6 meses)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true), // Mostrar grade
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40), // Eixo Y
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Converte o valor numérico do eixo X para a label do mês
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(_lineLabels[value.toInt()]),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Não mostrar títulos em cima
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Não mostrar títulos na direita
                ),
                borderData: FlBorderData( // Bordas do gráfico
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                minX: 0,
                maxX: 5, // 6 meses (índices de 0 a 5)
                minY: 0,
                maxY: 1500, // Ajuste este valor conforme o máximo esperado dos seus gastos
                lineBarsData: [
                  LineChartBarData(
                    spots: _lineSpots, // Seus pontos de dados
                    isCurved: true, // Curva suave
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true), // Mostrar pontos nos dados
                    belowBarData: BarAreaData(show: false), // Não preencher área abaixo da linha
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
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          Text('Distribuição por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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