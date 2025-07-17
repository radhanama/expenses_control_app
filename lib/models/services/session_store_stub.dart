import 'session_store_base.dart';

class StubSessionStore implements SessionStore {
  int? _id;

  @override
  Future<void> saveUserId(int id) async {
    _id = id;
  }

  @override
  Future<int?> readUserId() async => _id;

  @override
  Future<void> clear() async {
    _id = null;
  }
}

SessionStore createSessionStore() => StubSessionStore();
