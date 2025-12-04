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
    print('[FRIENDS] Loaded ${friends.length} friends');
    for (var f in friends) {
      final friend = f['friend'] as Map<String, dynamic>?;
      if (friend != null) {
        print(
          '[FRIENDS] Friend: ${friend['username']}, photo_url: ${friend['photo_url']}',
        );
      }
    }
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
    print('[SEARCH] Found ${results.length} users');
    for (var user in results) {
      print(
        '[SEARCH] User: ${user['username']}, photo_url: ${user['photo_url']}, full_name: ${user['full_name']}',
      );
    }
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
        SnackBar(
          content: Text('Permintaan pertemanan dikirim ke $username'),
          backgroundColor: const Color(0xFFFF6B4A),
        ),
      );
      _searchController.clear();
      setState(() => _searchResults = []);
      _loadSentRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim permintaan pertemanan'),
          backgroundColor: Colors.red,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pertemanan diterima'),
          backgroundColor: Color(0xFFFF6B4A),
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menerima permintaan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final success = await _friendService.rejectFriendRequest(requestId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pertemanan ditolak'),
          backgroundColor: Color(0xFFFF6B4A),
        ),
      );
      _loadPendingRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menolak permintaan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final success = await _friendService.cancelFriendRequest(requestId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pertemanan dibatalkan'),
          backgroundColor: Color(0xFFFF6B4A),
        ),
      );
      _loadSentRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membatalkan permintaan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFriend(String friendId, String friendName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Teman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Hapus $friendName dari daftar teman Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _friendService.removeFriend(friendId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$friendName dihapus dari daftar teman'),
          backgroundColor: const Color(0xFFFF6B4A),
        ),
      );
      _loadFriends();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus teman'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B4A),
        elevation: 0,
        title: const Text(
          'Teman',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFFFF6B4A),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, size: 18),
                      const SizedBox(width: 6),
                      Text('Teman (${_friends.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add, size: 18),
                      const SizedBox(width: 6),
                      Text('Masuk (${_pendingRequests.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 18),
                      const SizedBox(width: 6),
                      Text('Terkirim (${_sentRequests.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari teman dengan username...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B4A)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B4A), width: 2),
          ),
        ),
        onChanged: _searchUsers,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: const Color(0xFFFF6B4A)),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final photoUrl = user['photo_url'];
          final hobby = user['hobby'];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFF6B4A),
                    foregroundImage:
                        photoUrl != null && photoUrl.toString().isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: Text(
                      user['username'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (photoUrl != null && photoUrl.toString().isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                user['username'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hobby != null && hobby.toString().isNotEmpty
                            ? hobby.toString()
                            : 'Belum ada hobi',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () =>
                    _sendFriendRequest(user['id'], user['username']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text(
                  'Tambah',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoadingFriends) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B4A)),
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: Color(0xFFFF6B4A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Teman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cari pengguna untuk menambah teman',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      color: const Color(0xFFFF6B4A),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friendship = _friends[index];
          final friend = friendship['friend'] as Map<String, dynamic>;
          final photoUrl = friend['photo_url'];
          final hobby = friend['hobby'];
          print(
            '[FRIENDS_LIST] Rendering: ${friend['username']}, photo: $photoUrl, hobby: $hobby',
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFFF6B4A),
                    foregroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: Text(
                      friend['username'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (photoUrl != null && photoUrl.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                friend['username'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hobby != null && hobby.toString().isNotEmpty
                            ? hobby.toString()
                            : 'Belum ada hobi',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
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
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Hapus Teman',
                            style: TextStyle(color: Colors.red),
                          ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestsList() {
    if (_isLoadingRequests) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B4A)),
      );
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Color(0xFFFF6B4A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Permintaan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada permintaan pertemanan masuk',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      color: const Color(0xFFFF6B4A),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          final sender = request['sender'] as Map<String, dynamic>;
          final photoUrl = sender['photo_url'];
          final hobby = sender['hobby'];
          final createdAt = DateTime.parse(request['created_at']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B4A).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B4A).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFF6B4A),
                foregroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: Text(
                  sender['username'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                sender['username'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hobby != null && hobby.toString().isNotEmpty
                              ? hobby.toString()
                              : 'Belum ada hobi',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFFF6B4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 24,
                      ),
                      onPressed: () =>
                          _acceptRequest(request['id'], sender['id']),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: () => _rejectRequest(request['id']),
                    ),
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B4A)),
      );
    }

    if (_sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_outlined,
                size: 64,
                color: Color(0xFFFF6B4A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Permintaan Terkirim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada permintaan pertemanan yang dikirim',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSentRequests,
      color: const Color(0xFFFF6B4A),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          final receiver = request['receiver'] as Map<String, dynamic>;
          final photoUrl = receiver['photo_url'];
          final hobby = receiver['hobby'];
          final createdAt = DateTime.parse(request['created_at']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    foregroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: Text(
                      receiver['username'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                receiver['username'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hobby != null && hobby.toString().isNotEmpty
                              ? hobby.toString()
                              : 'Belum ada hobi',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dikirim ${timeago.format(createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _cancelRequest(request['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
