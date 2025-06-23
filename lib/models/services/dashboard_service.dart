// libmodels/ervices/estatistica_service.dart
import 'package:expenses_control/models/dashboard/dashboard_dto.dart';
import 'package:expenses_control/models/dashboard/i_estrategia_dashboard.dart';
import 'package:expenses_control/models/dashboard/relatorio_comum.dart';
import 'package:expenses_control/models/dashboard/relatorio_avancado.dart';
import 'package:expenses_control/models/gasto.dart';

class DashboardService {
  IEstrategiaDashboard _estrategiaComum = RelatorioComum();
  IEstrategiaDashboard _estrategiaAvancada = RelatorioAvancado();

  void setEstrategiaComum(IEstrategiaDashboard estrategiaComum) => _estrategiaComum = estrategiaComum;
  void setEstrategiaAvancada(IEstrategiaDashboard estrategiaAvancada) => _estrategiaAvancada = estrategiaAvancada;
    
  Future<DashboardDTO> geraDashboardCompleto(List<Gasto> gastos) async {
    final dtoComum = _estrategiaComum.geraRelatorio(gastos);

    final dtoAvancado = _estrategiaAvancada.geraRelatorio(gastos);

    // Mescla os resultados usando o método copyWith.
    final dtoFinal = dtoComum.copyWith(
      top5Estabelecimentos: dtoAvancado.top5Estabelecimentos,
      comparativoMesAnterior: dtoAvancado.comparativoMesAnterior,
    );

    return dtoFinal;
  }
}