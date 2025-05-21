// lib/core/services/estatistica_service.dart
import 'package:expenses_control/core/statistics/estatistica_dto.dart';
import 'package:expenses_control/core/statistics/i_estrategia_estatistica.dart';
import 'package:expenses_control/core/statistics/relatorio_comum.dart';
import 'package:expenses_control/models/gasto.dart';

class EstatisticaService {
  IEstrategiaEstatistica _estrategia = RelatorioComum();

  void setEstrategia(IEstrategiaEstatistica nova) => _estrategia = nova;

  EstatisticaDTO gerarResumo(List<Gasto> gastos) =>
      _estrategia.gerarEstatistica(gastos);
}
