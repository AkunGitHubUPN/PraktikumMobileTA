import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._privateConstructor();
  static final UserSession instance = UserSession._privateConstructor();
  static const String _kLoggedInUserId = 'logged_in_user_id';

  String? _currentUserId; // Changed to String for UUID support
  String? get currentUserId => _currentUserId;
  bool get isLoggedIn => _currentUserId != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_kLoggedInUserId); // Changed to getString
    if (_currentUserId != null) {
      print("[SESSION] User ID $_currentUserId ditemukan. Auto-login berhasil.");
    } else {
      print("[SESSION] Tidak ada sesi aktif.");
    }
  }

  Future<void> saveSession(String userId) async { // Changed parameter type
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInUserId, userId); // Changed to setString
    print("[SESSION] Sesi disimpan untuk User ID: $userId");
  }

  Future<void> clearSession() async {
    print("[SESSION] Menghapus sesi untuk User ID: $_currentUserId");
    _currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInUserId);
  }
}