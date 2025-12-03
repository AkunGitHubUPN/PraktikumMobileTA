import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  SupabaseHelper._privateConstructor();
  static final SupabaseHelper instance = SupabaseHelper._privateConstructor();

  // ⚠️ GANTI INI dengan API credentials dari Supabase Dashboard!
  // Settings > API > Project URL dan anon/public key
  static const String supabaseUrl = 'https://hejkweydyxdjrhfgpwlm.supabase.co'; // Contoh: https://xxxxx.supabase.co
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhlamt3ZXlkeXhkanJoZmdwd2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3NjA5NDUsImV4cCI6MjA4MDMzNjk0NX0.727gPOztX-G90nzsV7pnP_SrNHsKbmFJmUxJQYopH7w'; // API key panjang

  // Singleton Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set false di production
    );
    print("[SUPABASE] ✅ Initialized successfully!");
  }

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get currentUserId => currentUser?.id;

  // Sign Up
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await client.auth.signOut();
  }  // Upload foto ke Storage
  Future<String> uploadPhoto(String filePath, String fileName) async {
    try {
      print("[SUPABASE] 🔍 Starting upload from: $filePath");
      
      final bytes = Uint8List.fromList(await _readFileBytes(filePath));
      
      // Upload langsung ke root bucket (tidak pakai subfolder user)
      final String fullPath = fileName;
        print("[SUPABASE] 📤 Uploading to bucket: journal-photos");
      print("[SUPABASE] 📁 Path: $fullPath");
      print("[SUPABASE] 📦 File size: ${bytes.length} bytes");
        // Upload dengan content type eksplisit
      final response = await client.storage.from('journal-photos').uploadBinary(
        fullPath,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg', // Eksplisit set content type
        ),
      );      print("[SUPABASE] 📡 Upload response: $response");

      // Get public URL
      final String publicUrl = client.storage
          .from('journal-photos')
          .getPublicUrl(fullPath);

      print("[SUPABASE] ✅ Upload success!");
      print("[SUPABASE] 🔗 Public URL: $publicUrl");
      return publicUrl;
    } catch (e, stackTrace) {
      print("[SUPABASE] ❌ Upload FAILED!");
      print("[SUPABASE] ❌ Error: $e");
      print("[SUPABASE] ❌ Error type: ${e.runtimeType}");
      print("[SUPABASE] ❌ Stack trace: $stackTrace");
      rethrow;
    }
  }

  // Delete foto dari Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {      // Extract path from URL
      final uri = Uri.parse(photoUrl);
      final path = uri.pathSegments.last;      
      await client.storage.from('journal-photos').remove([path]);
    } catch (e) {
      print("[SUPABASE] Error deleting photo: $e");
    }
  }
  // Helper: Read file bytes
  Future<List<int>> _readFileBytes(String filePath) async {
    final file = await _getFile(filePath);
    return await file.readAsBytes();
  }

  Future<dynamic> _getFile(String filePath) async {
    return File(filePath);
  }
}
