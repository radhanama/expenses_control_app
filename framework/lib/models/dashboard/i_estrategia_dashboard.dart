// lib/models/statistics/i_estrategia_dashboard.dart
//
// Strategy contract (hot-spot).  Keeps framework agnostic of the concrete
// calculation logic.

import '../gasto.dart';
import 'dashboard_dto.dart';

abstract class IEstrategiaDashboard {
  DashboardDTO geraRelatorio(List<Gasto> gastos);
}
