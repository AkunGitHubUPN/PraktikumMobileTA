import 'supabase_helper.dart';
import 'user_session.dart';

class JournalService {
  JournalService._privateConstructor();
  static final JournalService instance = JournalService._privateConstructor();

  final _supabase = SupabaseHelper.client;
  // Create Journal
  Future<String?> createJournal({
    required String judul,
    required String cerita,
    required DateTime tanggal,
    double? latitude,
    double? longitude,
    String? namaLokasi,
    String privacy = 'public', // NEW: Privacy setting (public/friends/private)
  }) async {
    try {
      final userId = UserSession.instance.currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase.from('journals').insert({
        'user_id': userId,
        'judul': judul,
        'cerita': cerita,
        'tanggal': tanggal.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'nama_lokasi': namaLokasi,
        'privacy': privacy, // NEW: Add privacy field
      }).select().single();

      print("[JOURNAL] ✅ Created: ${response['id']} (privacy: $privacy)");
      return response['id'];
    } catch (e) {
      print("[JOURNAL] ❌ Create error: $e");
      return null;
    }
  }
  // Get Journals for Current User
  Future<List<Map<String, dynamic>>> getJournalsForUser() async {
    try {
      final userId = UserSession.instance.currentUserId; // ← FIX: Pakai UserSession
      if (userId == null) return [];

      final response = await _supabase
          .from('journals')
          .select('*, journal_photos(id, photo_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("[JOURNAL] ❌ Fetch error: $e");
      return [];
    }
  }

  // NEW: Get PUBLIC journals of a specific user (for Friend Profile)
  Future<List<Map<String, dynamic>>> getUserPublicJournals(String userId) async {
    try {
      final response = await _supabase
          .from('journals')
          .select('*, journal_photos(id, photo_url)')
          .eq('user_id', userId)
          .eq('privacy', 'public')
          .order('created_at', ascending: false);

      print("[JOURNAL] ✅ Loaded ${(response as List).length} public journals for user $userId");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("[JOURNAL] ❌ Fetch public journals error: $e");
      return [];
    }
  }

  // NEW: Get journal count for a user (with privacy filter)
  Future<int> getUserJournalCount(String userId, {bool publicOnly = false}) async {
    try {
      var query = _supabase
          .from('journals')
          .select()
          .eq('user_id', userId);
      
      if (publicOnly) {
        query = query.eq('privacy', 'public');
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      print("[JOURNAL] ❌ Count error: $e");
      return 0;
    }
  }

  // Get Single Journal by ID
  Future<Map<String, dynamic>?> getJournalById(String journalId) async {
    try {
      final response = await _supabase
          .from('journals')
          .select('*, journal_photos(id, photo_url)')
          .eq('id', journalId)
          .single();

      return response;
    } catch (e) {
      print("[JOURNAL] ❌ Fetch by ID error: $e");
      return null;
    }
  }

  // Update Journal
  Future<bool> updateJournal({
    required String journalId,
    required String judul,
    required String cerita,
    String? privacy, // NEW: Optional privacy update
  }) async {
    try {
      final updateData = {
        'judul': judul,
        'cerita': cerita,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add privacy if provided
      if (privacy != null) {
        updateData['privacy'] = privacy;
      }

      await _supabase.from('journals').update(updateData).eq('id', journalId);

      print("[JOURNAL] ✅ Updated: $journalId");
      return true;
    } catch (e) {
      print("[JOURNAL] ❌ Update error: $e");
      return false;
    }
  }

  // Delete Journal
  Future<bool> deleteJournal(String journalId) async {
    try {
      // Delete photos first (CASCADE should handle this, but just in case)
      await _supabase.from('journal_photos').delete().eq('journal_id', journalId);
      
      // Delete journal
      await _supabase.from('journals').delete().eq('id', journalId);

      print("[JOURNAL] ✅ Deleted: $journalId");
      return true;
    } catch (e) {
      print("[JOURNAL] ❌ Delete error: $e");
      return false;
    }
  }

  // Add Photo to Journal
  Future<bool> addPhotoToJournal({
    required String journalId,
    required String photoUrl,
  }) async {
    try {
      await _supabase.from('journal_photos').insert({
        'journal_id': journalId,
        'photo_url': photoUrl,
      });

      print("[JOURNAL] ✅ Photo added to journal: $journalId");
      return true;
    } catch (e) {
      print("[JOURNAL] ❌ Add photo error: $e");
      return false;
    }
  }

  // Delete Photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      await _supabase.from('journal_photos').delete().eq('id', photoId);

      print("[JOURNAL] ✅ Photo deleted: $photoId");
      return true;
    } catch (e) {
      print("[JOURNAL] ❌ Delete photo error: $e");
      return false;
    }
  }
  // Get Photos for Journal
  Future<List<Map<String, dynamic>>> getPhotosForJournal(String journalId) async {
    try {
      final response = await _supabase
          .from('journal_photos')
          .select()
          .eq('journal_id', journalId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("[JOURNAL] ❌ Get photos error: $e");
      return [];
    }
  }
}
