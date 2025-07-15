import 'package:expenses_control/models/data/usuario_repository.dart';
import 'package:expenses_control/models/usuario.dart';
import 'package:expenses_control_app/models/services/authentication_service.dart';
import 'package:flutter/foundation.dart';

/// View‑Model para a tela de autenticação.
/// Faz ponte entre a [UsuarioView] e o [AuthenticationService].
class UsuarioViewModel extends ChangeNotifier {
  final UsuarioRepository repo;
  final AuthenticationService auth;

  UsuarioViewModel({required this.repo, required this.auth});

  // ─────────── State ───────────
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Usuario? _usuarioLogado;
  Usuario? get usuarioLogado => _usuarioLogado;

  // ─────────── Actions ───────────
  Future<void> login(String email, String senha) async {
    await _wrapAsync(() async {
      _usuarioLogado = await auth.login(email: email, senhaPura: senha);
    });
  }

  Future<void> registrar(String email, String senha,
      {required String nome, PlanoUsuario plano = PlanoUsuario.gratuito}) async {
    await _wrapAsync(() async {
      _usuarioLogado = await auth.registrar(
        nome: nome,
        email: email,
        senhaPura: senha,
        plano: plano,
      );
    });
  }

  Future<void> logout() async {
    await _wrapAsync(() async {
      await auth.logout();
      _usuarioLogado = null;
    });
  }

  // Helper que lida com loading + erro
  Future<void> _wrapAsync(Future<void> Function() body) async {
    _errorMessage = null;
    _loading = true;
    notifyListeners();
    try {
      await body();
    } on AuthenticationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
