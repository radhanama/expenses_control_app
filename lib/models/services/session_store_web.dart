import 'dart:html' as html;
import 'session_store_base.dart';

class WebLocalSessionStore implements SessionStore {
  static const _key = 'current_user_id';

  @override
  Future<void> saveUserId(int id) async {
    html.window.localStorage[_key] = id.toString();
  }

  @override
  Future<int?> readUserId() async {
    final v = html.window.localStorage[_key];
    return v == null ? null : int.tryParse(v);
  }

  @override
  Future<void> clear() async {
    html.window.localStorage.remove(_key);
  }
}

SessionStore createSessionStore() => WebLocalSessionStore();
