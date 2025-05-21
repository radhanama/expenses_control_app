// lib/core/services/authentication_service.dart
//
// “Hot-spot” service responsible for registration, login and logout.
// Business rules live here; storage lives in UsuarioRepository.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:expenses_control/data/usuario_repository.dart';
import 'package:expenses_control/models/usuario.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthenticationService {
  final UsuarioRepository _usuarioRepo;
  final FlutterSecureStorage? _secureStorage;

  /// Optionally inject FlutterSecureStorage (or fake) for session persistence.
  AuthenticationService(
    this._usuarioRepo, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage;

  // ===========================================================================
  //  REGISTRATION
  // ===========================================================================
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required String senhaPura,
  }) async {
    if (await _usuarioRepo.emailExists(email)) {
      throw AuthenticationException('E-mail já cadastrado');
    }
    final novo = Usuario(
      nome: nome,
      email: email,
      senhaHash: _hash(senhaPura),
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

    // Persist session if secure storage is available
    await _secureStorage?.write(key: _kCurrentUserId, value: user.id);

    return user;
  }

  // ===========================================================================
  //  LOGOUT
  // ===========================================================================
  Future<void> logout() async {
    await _secureStorage?.delete(key: _kCurrentUserId);
    //  If using tokens/JWT, revoke or clear cache here.
  }

  // ===========================================================================
  //  SESSION HELPERS
  // ===========================================================================
  static const _kCurrentUserId = 'current_user_id';

  Future<Usuario?> currentUser() async {
    final id = await _secureStorage?.read(key: _kCurrentUserId);
    return id == null ? null : _usuarioRepo.findById(id);
  }

  // ===========================================================================
  //  Internal helpers
  // ===========================================================================
  @visibleForTesting
  String _hash(String senha) => sha256.convert(utf8.encode(senha)).toString();
}
