import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

/// Friend System Service
/// Handles friend requests, friendships, and user search
class FriendService {
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  final _supabase = Supabase.instance.client;

  // ============================================
  // USER SEARCH
  // ============================================

  /// Search users by username (excluding current user and existing friends)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');

      // Get current friends IDs
      final friendsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('user_id', currentUserId);

      final friendIds = (friendsResponse as List)
          .map((f) => f['friend_id'] as String)
          .toList();

      // Search users (exclude self and friends)
      final response = await _supabase
          .from('users')
          .select('id, username, created_at, photo_url, hobby, full_name')
          .ilike('username', '%$query%')
          .neq('id', currentUserId)
          .order('username', ascending: true);

      // Filter out existing friends
      final users = (response as List)
          .where((user) => !friendIds.contains(user['id']))
          .toList();

      return users.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // ============================================
  // FRIEND REQUESTS
  // ============================================

  /// Send friend request
  Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');

      // Check if already friends
      final existingFriend = await _supabase
          .from('friends')
          .select()
          .eq('user_id', currentUserId)
          .eq('friend_id', receiverId)
          .maybeSingle();

      if (existingFriend != null) {
        throw Exception('Already friends');
      }

      // Check if request already exists
      final existingRequest = await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', currentUserId)
          .eq('receiver_id', receiverId)
          .maybeSingle();

      if (existingRequest != null) {
        throw Exception('Friend request already sent');
      }

      // Create friend request
      await _supabase.from('friend_requests').insert({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
      });

      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  /// Get pending friend requests (received)
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');
      final response = await _supabase
          .from('friend_requests')
          .select('''
            id,
            sender_id,
            created_at,
            sender:users!friend_requests_sender_id_fkey(id, username, photo_url, hobby, full_name)
          ''')
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  /// Get sent friend requests (pending)
  Future<List<Map<String, dynamic>>> getSentRequests() async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');
      final response = await _supabase
          .from('friend_requests')
          .select('''
            id,
            receiver_id,
            created_at,
            receiver:users!friend_requests_receiver_id_fkey(id, username, photo_url, hobby, full_name)
          ''')
          .eq('sender_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting sent requests: $e');
      return [];
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId, String senderId) async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');

      // Update request status
      await _supabase
          .from('friend_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      // Create bidirectional friendship using helper function
      await _supabase.rpc(
        'create_friendship',
        params: {'user1': currentUserId, 'user2': senderId},
      );

      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  /// Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _supabase
          .from('friend_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);

      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  /// Cancel sent friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _supabase.from('friend_requests').delete().eq('id', requestId);
      return true;
    } catch (e) {
      print('Error canceling friend request: $e');
      return false;
    }
  }

  // ============================================
  // FRIENDS MANAGEMENT
  // ============================================

  /// Get all friends
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');
      final response = await _supabase
          .from('friends')
          .select('''
            id,
            friend_id,
            created_at,
            friend:users!friends_friend_id_fkey(id, username, photo_url, hobby, full_name)
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  /// Remove friend (unfriend)
  Future<bool> removeFriend(String friendId) async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) throw Exception('User not logged in');

      // Remove bidirectional friendship using helper function
      await _supabase.rpc(
        'remove_friendship',
        params: {'user1': currentUserId, 'user2': friendId},
      );

      return true;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  /// Check if two users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId1)
          .eq('friend_id', userId2)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking friendship: $e');
      return false;
    }
  }

  /// Get friend count
  Future<int> getFriendCount() async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) return 0;

      final response = await _supabase
          .from('friends')
          .select()
          .eq('user_id', currentUserId);

      return (response as List).length;
    } catch (e) {
      print('Error getting friend count: $e');
      return 0;
    }
  }

  /// Get pending request count
  Future<int> getPendingRequestCount() async {
    try {
      final currentUserId = UserSession.instance.currentUserId;
      if (currentUserId == null) return 0;

      final response = await _supabase
          .from('friend_requests')
          .select()
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending');

      return (response as List).length;
    } catch (e) {
      print('Error getting pending request count: $e');
      return 0;
    }
  }
}
