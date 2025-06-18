import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/statistics/estatistica_dto.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/models/services/statistica_service.dart';
import 'package:expenses_control/models/gasto.dart';
import 'package:collection/collection.dart';

/// ViewModel responsável por gerir o estado e a lógica de negócio do Dashboard.
class DashboardViewModel extends ChangeNotifier {
  final GastoRepository _repo;
  final EstatisticaService _stats;

  DashboardViewModel(this._repo, this._stats);

  EstatisticaDTO _resumo = EstatisticaDTO.vazio;
  bool _loading = false;
  int _transacoes = 0;
  Map<DateTime, double> _gastosPorMes = const {};
  Map<int, double> _gastosPorDiaDaSemana = {};
  Map<String, double> _top5Estabelecimentos = {};
  double _gastoMedioPorTransacao = 0.0;
  double _comparativoMesAnterior = 0.0; // Variação percentual

  EstatisticaDTO get resumo => _resumo;
  bool get loading => _loading;
  int get transacoes => _transacoes;
  Map<DateTime, double> get gastosPorMes => _gastosPorMes;
  Map<int, double> get gastosPorDiaDaSemana => _gastosPorDiaDaSemana;
  Map<String, double> get top5Estabelecimentos => _top5Estabelecimentos;
  double get gastoMedioPorTransacao => _gastoMedioPorTransacao;
  double get comparativoMesAnterior => _comparativoMesAnterior;


  /// Carrega os dados do repositório, processa as estatísticas e notifica a View.
  Future<void> carregarResumo() async {
    _loading = true;
    notifyListeners();

    final gastos = await _repo.findAll(); 

    _transacoes = gastos.length;
    _resumo = _stats.gerarResumo(gastos);
    _gastosPorMes = _calcularGastosPorMes(gastos);
    
    _calcularEstatisticasAdicionais(gastos);

    _loading = false;
    notifyListeners();
  }
  
  /// Agrupa os cálculos das novas estatísticas.
  void _calcularEstatisticasAdicionais(List<Gasto> gastos) {
    if (gastos.isEmpty) {
      _gastosPorDiaDaSemana = {};
      _top5Estabelecimentos = {};
      _gastoMedioPorTransacao = 0;
      _comparativoMesAnterior = 0;
      return;
    }

    _gastosPorDiaDaSemana = _calcularGastosPorDiaDaSemana(gastos);
    _top5Estabelecimentos = _calcularTopEstabelecimentos(gastos);
    _gastoMedioPorTransacao = _resumo.totalGastos / _transacoes;
    _comparativoMesAnterior = _calcularComparativoMesAnterior(gastos);
  }

  /// Método privado para calcular o total de gastos dos últimos 6 meses.
  Map<DateTime, double> _calcularGastosPorMes(List<Gasto> gastos) {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    
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
  /// Retorna um mapa onde a chave é o dia da semana (1=Segunda, 7=Domingo).
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

  /// Identifica os 5 estabelecimentos com maiores gastos.
  Map<String, double> _calcularTopEstabelecimentos(List<Gasto> gastos) {
    // Agrupa os gastos por nome do estabelecimento
    final gastosPorEstabelecimento = groupBy<Gasto, String>(
      gastos, 
      (gasto) => gasto.local
    );
    // Soma o total e a quantidade de itens para cada estabelecimento
    final totais = gastosPorEstabelecimento.map((key, value) {
      final total = value.isEmpty ? 0.0 : value.map((g) => g.total).reduce((a, b) => a + b);
      final qtdItens = value.isEmpty
        ? 0
        : value
          .map((g) => g.quantidadeTotalProdutos())
          .reduce((a, b) => a + b);
      // Para o dashboard, vamos ponderar pelo total gasto e, em caso de empate, pela quantidade de itens
      return MapEntry(key, {'total': total, 'qtdItens': qtdItens});
    });

    // Ordena do maior para o menor pelo total gasto, depois pela quantidade de itens
    final sortedEntries = totais.entries.toList()
      ..sort((a, b) {
      final cmpTotal = (b.value['total'] as double).compareTo(a.value['total'] as double);
      if (cmpTotal != 0) return cmpTotal;
      return (b.value['qtdItens'] as int).compareTo(a.value['qtdItens'] as int);
      });

    // Retorna um mapa apenas com o nome do estabelecimento e o total gasto (para manter compatibilidade)
    return Map.fromEntries(
      sortedEntries.take(5).map((e) => MapEntry(e.key, e.value['total'] as double))
    );
  }

  /// Calcula a variação percentual dos gastos do mês atual em relação ao anterior.
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
        .where((g) => g.data.month == mesAnterior && g.data.year == anoDoMesAnterior)
        .fold<double>(0.0, (sum, g) => sum + g.total);
    
    if (gastosMesAnterior == 0) {
      return gastosMesAtual > 0 ? 100.0 : 0.0; // Aumento "infinito", retorna 100%
    }

    return ((gastosMesAtual - gastosMesAnterior) / gastosMesAnterior) * 100;
  }
}
