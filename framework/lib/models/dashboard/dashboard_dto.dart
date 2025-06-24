import '../gasto.dart';

class DashboardDTO {
  final double totalGastos;
  final Map<int, double> totalPorCategoria;
  final int transacoes;
  final Map<DateTime, double> gastosPorMes;
  final Map<int, double> gastosPorDiaDaSemana;
  final Map<String, double> top5Estabelecimentos;
  final double gastoMedioPorTransacao;
  final double comparativoMesAnterior;

  DashboardDTO({
    this.totalGastos = 0.0,
    this.totalPorCategoria = const {},
    this.transacoes = 0,
    this.gastosPorMes = const {},
    this.gastosPorDiaDaSemana = const {},
    this.top5Estabelecimentos = const {},
    this.gastoMedioPorTransacao = 0.0,
    this.comparativoMesAnterior = 0.0,
  });

  DashboardDTO copyWith({
    double? totalGastos,
    Map<int, double>? totalPorCategoria,
    int? transacoes,
    Map<DateTime, double>? gastosPorMes,
    Map<int, double>? gastosPorDiaDaSemana,
    Map<String, double>? top5Estabelecimentos,
    double? gastoMedioPorTransacao,
    double? comparativoMesAnterior,
  }) {
    return DashboardDTO(
      totalGastos: totalGastos ?? this.totalGastos,
      totalPorCategoria: totalPorCategoria ?? this.totalPorCategoria,
      transacoes: transacoes ?? this.transacoes,
      gastosPorMes: gastosPorMes ?? this.gastosPorMes,
      gastosPorDiaDaSemana: gastosPorDiaDaSemana ?? this.gastosPorDiaDaSemana,
      top5Estabelecimentos: top5Estabelecimentos ?? this.top5Estabelecimentos,
      gastoMedioPorTransacao: gastoMedioPorTransacao ?? this.gastoMedioPorTransacao,
      comparativoMesAnterior: comparativoMesAnterior ?? this.comparativoMesAnterior,
    );
  }

  /// Very simple calculator: sum values, group by categoria id.
  static DashboardDTO calcular(List<Gasto> gastos) {
    double total = 0;
    final mapa = <int, double>{};

    for (final g in gastos) {
      total += g.total;
      mapa.update(g.categoriaId, (v) => v + g.total, ifAbsent: () => g.total);
    }

    return DashboardDTO(totalGastos: total, totalPorCategoria: mapa);
  }

  // Helper factory used by the common report implementation
  factory DashboardDTO.fromRaw(
    double total,
    Map<int, double> porCategoria,
  ) =>
      DashboardDTO(
        totalGastos: total,
        totalPorCategoria: porCategoria,
      );

  /// Example “empty” instance (useful for initial state)
  static DashboardDTO get vazio => DashboardDTO();
}