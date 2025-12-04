import 'package:flutter/material.dart';
import '../helpers/friend_service.dart';
import 'friend_profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _friendService = FriendService();
  final _searchController = TextEditingController();

  // State
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _searchResults = [];

  bool _isLoadingFriends = true;
  bool _isLoadingRequests = true;
  bool _isLoadingSent = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadFriends(),
      _loadPendingRequests(),
      _loadSentRequests(),
    ]);
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    final friends = await _friendService.getFriends();
    setState(() {
      _friends = friends;
      _isLoadingFriends = false;
    });
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoadingRequests = true);
    final requests = await _friendService.getPendingRequests();
    setState(() {
      _pendingRequests = requests;
      _isLoadingRequests = false;
    });
  }

  Future<void> _loadSentRequests() async {
    setState(() => _isLoadingSent = true);
    final requests = await _friendService.getSentRequests();
    setState(() {
      _sentRequests = requests;
      _isLoadingSent = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _friendService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _sendFriendRequest(String userId, String username) async {
    final success = await _friendService.sendFriendRequest(userId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to $username')),
      );
      _searchController.clear();
      setState(() => _searchResults = []);
      _loadSentRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  Future<void> _acceptRequest(String requestId, String senderId) async {
    final success = await _friendService.acceptFriendRequest(
      requestId,
      senderId,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request accepted')));
      _loadData();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to accept request')));
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final success = await _friendService.rejectFriendRequest(requestId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request rejected')));
      _loadPendingRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to reject request')));
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final success = await _friendService.cancelFriendRequest(requestId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request cancelled')));
      _loadSentRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to cancel request')));
    }
  }

  Future<void> _removeFriend(String friendId, String friendName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove $friendName from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _friendService.removeFriend(friendId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$friendName removed from friends')),
      );
      _loadFriends();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to remove friend')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6200EA),
        elevation: 0,
        title: const Text(
          'Friends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Friends (${_friends.length})'),
            Tab(text: 'Requests (${_pendingRequests.length})'),
            Tab(text: 'Sent (${_sentRequests.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_searchResults.isNotEmpty || _isSearching) _buildSearchResults(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildPendingRequestsList(),
                _buildSentRequestsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by username...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6200EA)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _searchUsers,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      color: Colors.grey.shade50,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final photoUrl = user['photo_url'];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6200EA),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      user['username'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            title: Text(user['username'] ?? 'Unknown'),
            subtitle: Text(user['full_name'] ?? ''),
            trailing: ElevatedButton(
              onPressed: () => _sendFriendRequest(user['id'], user['username']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for users to add friends',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friendship = _friends[index];
          final friend = friendship['friend'] as Map<String, dynamic>;
          final photoUrl = friend['photo_url'];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6200EA),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        friend['username'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(
                friend['username'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(friend['full_name'] ?? ''),
              onTap: () async {
                // Navigate to friend's profile
                final needsRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendProfilePage(
                      userId: friend['id'],
                      username: friend['username'],
                    ),
                  ),
                );

                // Refresh friends list if friend was removed
                if (needsRefresh == true) {
                  _loadFriends();
                }
              },
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Friend'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeFriend(friend['id'], friend['username']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestsList() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      child: ListView.builder(
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          final sender = request['sender'] as Map<String, dynamic>;
          final photoUrl = sender['photo_url'];
          final createdAt = DateTime.parse(request['created_at']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6200EA),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        sender['username'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(
                sender['username'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sender['full_name'] ?? ''),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () =>
                        _acceptRequest(request['id'], sender['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectRequest(request['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsList() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No sent requests',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSentRequests,
      child: ListView.builder(
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          final receiver = request['receiver'] as Map<String, dynamic>;
          final photoUrl = receiver['photo_url'];
          final createdAt = DateTime.parse(request['created_at']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade400,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        receiver['username'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(
                receiver['username'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receiver['full_name'] ?? ''),
                  const SizedBox(height: 4),
                  Text(
                    'Sent ${timeago.format(createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              trailing: TextButton(
                onPressed: () => _cancelRequest(request['id']),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
