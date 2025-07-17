abstract class SessionStore {
  Future<void> saveUserId(int id);
  Future<int?> readUserId();
  Future<void> clear();
}
