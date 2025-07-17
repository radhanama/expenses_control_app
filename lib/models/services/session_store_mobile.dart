import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session_store_base.dart';

class SecureSessionStore implements SessionStore {
  final FlutterSecureStorage storage;
  SecureSessionStore(this.storage);

  static const _key = 'current_user_id';

  @override
  Future<void> saveUserId(int id) =>
      storage.write(key: _key, value: id.toString());

  @override
  Future<int?> readUserId() async {
    final v = await storage.read(key: _key);
    return v == null ? null : int.tryParse(v);
  }

  @override
  Future<void> clear() => storage.delete(key: _key);
}

SessionStore createSessionStore() => SecureSessionStore(const FlutterSecureStorage());
