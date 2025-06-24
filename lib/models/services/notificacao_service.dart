import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/gasto.dart';
import '../data/meta_repository.dart';
import '../data/notificacao_repository.dart';
import '../meta.dart';
import '../notificacao.dart';
import 'dashboard_service.dart';
import 'gemini_service.dart';

class NotificacaoService {
  final GastoRepository _gastoRepo;
  final MetaRepository _metaRepo;
  final NotificacaoRepository _repo;
  final DashboardService _dashboard;
  final GeminiService _gemini;

  NotificacaoService({
    required GastoRepository gastoRepo,
    required MetaRepository metaRepo,
    required NotificacaoRepository repo,
    required DashboardService dashboard,
    required GeminiService gemini,
  })  : _gastoRepo = gastoRepo,
        _metaRepo = metaRepo,
        _repo = repo,
        _dashboard = dashboard,
        _gemini = gemini;

  Future<void> gerarSugestoes() async {
    try {
      final gastos = await _gastoRepo.findAll();
      if (gastos.isEmpty) return;

      final int usuarioIdGasto = gastos.first.usuarioId;

      final resumo = await _dashboard.geraDashboardCompleto(gastos);
      final metas = await _metaRepo.findAll();
      final agora = DateTime.now();

    for (final Meta m in metas) {
      final totalMeta = _totalGastoParaMeta(gastos, m);
      final ultimoDia = DateTime(m.mesAno.year, m.mesAno.month + 1, 0);

      if (m.mesAno.year == agora.year && m.mesAno.month == agora.month) {
        if (totalMeta >= m.valorLimite * 0.8) {
          final mensagem = await _gemini.sugestaoParaMeta(
              m.descricao, totalMeta, m.valorLimite);
          await _repo.create(Notificacao(
            tipo: NotificationTipo.ALERTA_GASTO,
            mensagem: mensagem,
            data: DateTime.now(),
            usuarioId: m.usuarioId,
          ));
        }
      } else if (agora.isAfter(ultimoDia) && totalMeta <= m.valorLimite) {
        final mensagem = await _gemini.parabensPorMeta(m.descricao);
        await _repo.create(Notificacao(
          tipo: NotificationTipo.LEMBRETE,
          mensagem: mensagem,
          data: DateTime.now(),
          usuarioId: m.usuarioId,
        ));
      }
    }

    if (resumo.top5Estabelecimentos.isNotEmpty) {
      final top = resumo.top5Estabelecimentos.entries.first;
      final mensagem =
          'Você gastou R\$ ${top.value.toStringAsFixed(2)} em ${top.key} este mês. Considere economizar.';
      await _repo.create(Notificacao(
        tipo: NotificationTipo.LEMBRETE,
        mensagem: mensagem,
        data: DateTime.now(),
        usuarioId: usuarioIdGasto,
      ));
    }
    } catch (e) {
      // Rethrow with context so ViewModels can display meaningful errors
      throw Exception('Falha ao gerar notificações: $e');
    }
  }

  double _totalGastoParaMeta(List<Gasto> gastos, Meta m) {
    final mes = m.mesAno.month;
    final ano = m.mesAno.year;
    return gastos
        .where((g) => g.data.month == mes && g.data.year == ano)
        .where((g) => m.categoriaId == null || g.categoriaId == m.categoriaId)
        .fold<double>(0.0, (s, g) => s + g.total);
  }
}
