import 'supabase_helper.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final _supabase = SupabaseHelper.client;

  // Register User (menggunakan tabel users custom, bukan Supabase Auth)
  Future<Map<String, dynamic>?> registerUser(String username, String password) async {
    try {
      // Hash password
      final hashedPassword = await FlutterBcrypt.hashPw(
        password: password,
        salt: await FlutterBcrypt.salt(),
      );

      // Check if username exists
      final existing = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        print("[AUTH] ❌ Username already exists");
        return null;
      }

      // Insert new user
      final response = await _supabase.from('users').insert({
        'username': username,
        'password': hashedPassword,
      }).select().single();

      print("[AUTH] ✅ User registered: ${response['id']}");
      return response;
    } catch (e) {
      print("[AUTH] ❌ Register error: $e");
      return null;
    }
  }

  // Login User
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      // Get user by username
      final user = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (user == null) {
        print("[AUTH] ❌ User not found");
        return null;
      }

      // Verify password
      final isValid = await FlutterBcrypt.verify(
        password: password,
        hash: user['password'],
      );

      if (!isValid) {
        print("[AUTH] ❌ Invalid password");
        return null;
      }

      print("[AUTH] ✅ Login successful: ${user['id']}");
      return user;
    } catch (e) {
      print("[AUTH] ❌ Login error: $e");
      return null;
    }
  }

  // Get User by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print("[AUTH] ❌ Get user error: $e");
      return null;
    }
  }
}
