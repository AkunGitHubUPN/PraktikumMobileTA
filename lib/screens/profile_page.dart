import 'package:flutter/material.dart';
import '../helpers/journal_service.dart';
import '../helpers/friend_service.dart';
import '../helpers/user_session.dart';
import '../helpers/supabase_helper.dart';
import 'journal_detail_page.dart';
import 'edit_profile_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _journalService = JournalService.instance;
  final _friendService = FriendService();

  bool _isLoading = true;
  String _username = '';
  String? _photoUrl;
  String? _hobby;
  int _journalCount = 0;
  int _friendCount = 0;
  List<Map<String, dynamic>> _journals = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final userId = UserSession.instance.currentUserId;
      print('[PROFILE] Current userId: $userId');

      if (userId == null) {
        print('[PROFILE] ❌ userId is null');
        return;
      }

      // Get username from database
      final supabase = SupabaseHelper.client;
      print('[PROFILE] Fetching user data...');
      final userData = await supabase
          .from('users')
          .select('username, photo_url, hobby')
          .eq('id', userId)
          .single();
      print('[PROFILE] User data: $userData');

      // Load data
      print('[PROFILE] Fetching journals...');
      final journals = await _journalService.getJournalsForUser();
      print('[PROFILE] Journals loaded: ${journals.length}');

      print('[PROFILE] Fetching friends...');
      final friends = await _friendService.getFriends();
      print('[PROFILE] Friends loaded: ${friends.length}');

      setState(() {
        _username = userData['username'] ?? 'User';
        _photoUrl = userData['photo_url'];
        _hobby = userData['hobby'];
        _journalCount = journals.length;
        _friendCount = friends.length;
        _journals = journals;
        _isLoading = false;
      });

      print('[PROFILE] ✅ Profile loaded successfully');
    } catch (e, stackTrace) {
      print('[PROFILE] ❌ Error loading data: $e');
      print('[PROFILE] ❌ Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFFFF6B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentUsername: _username,
                    currentPhotoUrl: _photoUrl,
                    currentHobby: _hobby,
                  ),
                ),
              );
              if (result == true) {
                _loadProfileData();
              }
            },
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Color(0xFFFF6B4A)),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: _photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : null,
                            child: _photoUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFFFF6B4A),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_hobby != null && _hobby!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _hobby!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                'Jurnal',
                                _journalCount.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildStatItem('Teman', _friendCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Journals Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Koleksi Jurnal Saya',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B4A),
                                ),
                              ),
                              Text(
                                '$_journalCount jurnal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_journals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.book_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada jurnal',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _journals.length,
                              itemBuilder: (context, index) {
                                return _buildJournalCard(_journals[index]);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> journal) {
    final privacy = journal['privacy'] ?? 'public';
    final photos =
        (journal['journal_photos'] as List?)?.cast<Map<String, dynamic>>() ??
        [];
    final firstPhotoUrl = photos.isNotEmpty ? photos[0]['photo_url'] : null;

    final tanggal = journal['tanggal'] != null
        ? DateTime.parse(journal['tanggal'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalDetailPage(journalId: journal['id']),
            ),
          ).then((_) => _loadProfileData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (firstPhotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    firstPhotoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.article,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            journal['judul'] ?? 'Tanpa Judul',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          privacy == 'private' ? Icons.lock : Icons.public,
                          size: 16,
                          color: privacy == 'private'
                              ? Colors.grey[600]
                              : const Color(0xFFFF6B4A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (tanggal != null)
                      Text(
                        DateFormat('d MMMM yyyy').format(tanggal),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      journal['cerita'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (journal['nama_lokasi'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              journal['nama_lokasi'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
