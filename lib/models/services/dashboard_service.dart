// lib/models/services/dashboard_service.dart
import 'package:expenses_control/models/statistics/dashboard_dto.dart';
import 'package:expenses_control/models/statistics/i_estrategia_dashboard.dart';
import 'package:expenses_control/models/statistics/relatorio_comum.dart';
import 'package:expenses_control/models/statistics/relatorio_avancado.dart';
import 'package:expenses_control/models/gasto.dart';

class DashboardService {
  IEstrategiaDashboard _estrategiaComum = RelatorioComum();
  IEstrategiaDashboard _estrategiaAvancada = RelatorioAvancado();

  void setEstrategiaComum(IEstrategiaDashboard estrategiaComum) => _estrategiaComum = estrategiaComum;
  void setEstrategiaAvancada(IEstrategiaDashboard estrategiaAvancada) => _estrategiaAvancada = estrategiaAvancada;
    
  Future<DashboardDTO> geraDashboardCompleto(List<Gasto> gastos) async {
    final dtoComum = _estrategiaComum.gerarEstatistica(gastos);

    final dtoAvancado = _estrategiaAvancada.gerarEstatistica(gastos);

    // Mescla os resultados usando o método copyWith.
    final dtoFinal = dtoComum.copyWith(
      top5Estabelecimentos: dtoAvancado.top5Estabelecimentos,
      comparativoMesAnterior: dtoAvancado.comparativoMesAnterior,
    );

    return dtoFinal;
  }
}
