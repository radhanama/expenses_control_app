// lib/models/statistics/relatorio_comum.dart
//
// Concrete strategy that performs a straightforward aggregation:
//   • soma total de gastos
//   • soma por categoria
//
// Ships with the framework as a <<frozenspot>> implementation.

import '../gasto.dart';
import '../produto.dart';
import 'i_estrategia_dashboard.dart';
import 'dashboard_dto.dart';

class RelatorioComum implements IEstrategiaDashboard {
  @override
  DashboardDTO geraRelatorio(List<Gasto> gastos) {
    if (gastos.isEmpty) return DashboardDTO.vazio;

    final totalGastos = gastos.map((g) => g.total).fold(0.0, (a, b) => a + b);
    final transacoes = gastos.length;

    return DashboardDTO(
      totalGastos: totalGastos,
      transacoes: transacoes,
      totalPorCategoria: _calcularTotalPorCategoria(gastos),
      gastosPorMes: _calcularGastosPorMes(gastos),
      gastosPorDiaDaSemana: _calcularGastosPorDiaDaSemana(gastos),
      gastoMedioPorTransacao: transacoes > 0 ? totalGastos / transacoes : 0.0,
    );
  }

  // Calcula o total de gastos por categoria.
  Map<int, double> _calcularTotalPorCategoria(List<Gasto> gastos) {
    final map = <int, double>{};

      for (final gasto in gastos) {
      final subtotal = gasto.produtos.isEmpty
          ? gasto.total
          : gasto.produtos.fold<double>(
              0.0, (sum, Produto p) => sum + p.calcularSubtotal());

      map.update(
        gasto.categoriaId,
        (value) => value + subtotal,
        ifAbsent: () => subtotal,
      );
    }

    return map;
  }

  /// Calcula o total de gastos dos últimos 6 meses.
  Map<DateTime, double> _calcularGastosPorMes(List<Gasto> gastos) {
    final now = DateTime.now();
    final months =
        List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    final map = {for (final m in months) m: 0.0};

    for (final g in gastos) {
      final key = DateTime(g.data.year, g.data.month, 1);
      if (map.containsKey(key)) {
        map[key] = map[key]! + g.total;
      }
    }
    return map;
  }

  /// Calcula o total de gastos para cada dia da semana.
  Map<int, double> _calcularGastosPorDiaDaSemana(List<Gasto> gastos) {
    final map = <int, double>{};
    for (final gasto in gastos) {
      map.update(
        gasto.data.weekday,
        (value) => value + gasto.total,
        ifAbsent: () => gasto.total,
      );
    }
    return map;
  }
}
