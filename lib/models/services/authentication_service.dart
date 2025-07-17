// libmodels/ervices/authentication_service.dart
//
// “Hot-spot” service responsible for registration, login and logout.
// Business rules live here; storage lives in UsuarioRepository.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:expenses_control/models/data/usuario_repository.dart';
import 'package:expenses_control/models/usuario.dart';
import 'package:flutter/foundation.dart';
import 'session_store.dart';

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthenticationService {
  final UsuarioRepository _usuarioRepo;
  final SessionStore _session;

  /// Optionally inject custom session store (or fake) for persistence.
  AuthenticationService(
    this._usuarioRepo, {
    SessionStore? sessionStore,
  }) : _session = sessionStore ?? createSessionStore();

  // ===========================================================================
  //  REGISTRATION
  // ===========================================================================
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required String senhaPura,
    PlanoUsuario plano = PlanoUsuario.gratuito,
  }) async {
    if (await _usuarioRepo.emailExists(email)) {
      throw AuthenticationException('E-mail já cadastrado');
    }
    final novo = Usuario(
      nome: nome,
      email: email,
      senhaHash: _hash(senhaPura),
      plano: plano,
    );
    return _usuarioRepo.create(novo);
  }

  // ===========================================================================
  //  LOGIN
  // ===========================================================================
  Future<Usuario> login({
    required String email,
    required String senhaPura,
  }) async {
    final user = await _usuarioRepo.findByEmail(email);
    if (user == null) throw AuthenticationException('Usuário não encontrado');

    if (user.senhaHash != _hash(senhaPura)) {
      throw AuthenticationException('Senha incorreta');
    }

    // Persist session
    await _session.saveUserId(user.id!);

    return user;
  }

  // ===========================================================================
  //  LOGOUT
  // ===========================================================================
  Future<void> logout() async {
    await _session.clear();
    //  If using tokens/JWT, revoke or clear cache here.
  }

  // ===========================================================================
  //  SESSION HELPERS
  // ===========================================================================
  Future<Usuario?> currentUser() async {
    final id = await _session.readUserId();
    return id == null ? null : _usuarioRepo.findById(id);
  }

  // ===========================================================================
  //  Internal helpers
  // ===========================================================================
  @visibleForTesting
  String _hash(String senha) => sha256.convert(utf8.encode(senha)).toString();
}
