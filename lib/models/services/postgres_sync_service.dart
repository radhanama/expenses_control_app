import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expenses_control/models/gasto.dart';
import 'package:expenses_control/models/usuario.dart';

class PostgresSyncService {
  final String? baseUrl;
  final http.Client _client;

  PostgresSyncService({this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  bool get _disabled => baseUrl == null || baseUrl!.isEmpty;

  Future<void> pushData(Usuario usuario, List<Gasto> gastos) async {
    if (_disabled) return;
    try {
      final url = Uri.parse('$baseUrl/sync');
      final body = jsonEncode({
        'usuario': usuario.toMap(),
        'gastos': gastos.map((g) => g.toMap()).toList(),
      });
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode != 200) {
        // ignore errors when server unavailable
        return;
      }
    } catch (_) {
      // ignore network errors silently
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(int userId) async {
    if (_disabled) return [];
    try {
      final url = Uri.parse('$baseUrl/sync/$userId');
      final res = await _client.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }
}
