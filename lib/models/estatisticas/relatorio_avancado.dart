// lib/models/statistics/relatorio_comum.dart
//
// Concrete strategy that performs a straightforward aggregation:
//   • soma total de gastos
//   • soma por categoria
//
// Ships with the framework as a <<frozenspot>> implementation.

import 'package:collection/collection.dart';
import 'package:expenses_control/models/dashboard/dashboard_dto.dart';
import 'package:expenses_control/models/dashboard/i_estrategia_dashboard.dart';
import 'package:expenses_control/models/gasto.dart';

class RelatorioAvancado implements IEstrategiaDashboard {
  @override
  DashboardDTO geraRelatorio(List<Gasto> gastos) {
    if (gastos.isEmpty) return DashboardDTO.vazio;

    return DashboardDTO(
      top5Estabelecimentos: _calcularTopEstabelecimentos(gastos),
      comparativoMesAnterior: _calcularComparativoMesAnterior(gastos),
    );
  }

  /// Identifica os 5 estabelecimentos com maiores gastos.
  Map<String, double> _calcularTopEstabelecimentos(List<Gasto> gastos) {
    final gastosPorEstabelecimento =
        groupBy<Gasto, String>(gastos, (gasto) => gasto.local);

    final totais = gastosPorEstabelecimento.map((key, value) {
      final total = value.isEmpty
          ? 0.0
          : value.map((g) => g.total).reduce((a, b) => a + b);
      final qtdItens = value.isEmpty
          ? 0
          : value
              .map((g) => g.quantidadeTotalProdutos())
              .reduce((a, b) => a + b);
      return MapEntry(key, {'total': total, 'qtdItens': qtdItens});
    });

    final sortedEntries = totais.entries.toList()
      ..sort((a, b) {
        final cmpTotal =
            (b.value['total'] as double).compareTo(a.value['total'] as double);
        if (cmpTotal != 0) return cmpTotal;
        return (b.value['qtdItens'] as int)
            .compareTo(a.value['qtdItens'] as int);
      });

    return Map.fromEntries(sortedEntries
        .take(5)
        .map((e) => MapEntry(e.key, e.value['total'] as double)));
  }

  /// Calcula o comparativo de gastos do mês atual com o mês anterior.
  double _calcularComparativoMesAnterior(List<Gasto> gastos) {
    final now = DateTime.now();
    final mesAtual = now.month;
    final anoAtual = now.year;
    final mesAnterior = now.month - 1 > 0 ? now.month - 1 : 12;
    final anoDoMesAnterior = now.month - 1 > 0 ? anoAtual : anoAtual - 1;

    final gastosMesAtual = gastos
        .where((g) => g.data.month == mesAtual && g.data.year == anoAtual)
        .fold<double>(0.0, (sum, g) => sum + g.total);

    final gastosMesAnterior = gastos
        .where((g) =>
            g.data.month == mesAnterior && g.data.year == anoDoMesAnterior)
        .fold<double>(0.0, (sum, g) => sum + g.total);

    if (gastosMesAnterior == 0) {
      return gastosMesAtual > 0 ? 100.0 : 0.0;
    }

    return ((gastosMesAtual - gastosMesAnterior) / gastosMesAnterior) * 100;
  }
}
