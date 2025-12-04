import 'package:flutter/material.dart';
import '../helpers/journal_service.dart';
import '../helpers/friend_service.dart';
import '../helpers/supabase_helper.dart';
import 'journal_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FriendProfilePage extends StatefulWidget {
  final String userId;
  final String username;

  const FriendProfilePage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  final _journalService = JournalService.instance;
  final _friendService = FriendService();
  final MapController _mapController = MapController();

  bool _isLoading = true;
  String? _photoUrl;
  String? _hobby;
  int _publicJournalCount = 0;
  List<Map<String, dynamic>> _publicJournals = [];
  LatLng _mapCenter = const LatLng(-7.557484, 110.856972); // Default center

  @override
  void initState() {
    super.initState();
    _loadFriendProfile();
  }

  Future<void> _loadFriendProfile() async {
    setState(() => _isLoading = true);

    try {
      print('[FRIEND_PROFILE] Loading profile for userId: ${widget.userId}');

      // Get user data
      final supabase = SupabaseHelper.client;
      print('[FRIEND_PROFILE] Fetching user data...');
      final userData = await supabase
          .from('users')
          .select('photo_url, hobby')
          .eq('id', widget.userId)
          .single();
      print('[FRIEND_PROFILE] User data: $userData');

      // Load only public journals
      print('[FRIEND_PROFILE] Fetching public journals...');
      final journals = await _journalService.getUserPublicJournals(
        widget.userId,
      );
      print('[FRIEND_PROFILE] Public journals loaded: ${journals.length}');

      setState(() {
        _photoUrl = userData['photo_url'];
        _hobby = userData['hobby'];
        _publicJournals = journals;
        _publicJournalCount = journals.length;
        _isLoading = false;

        // Set map center to first journal location if available
        if (journals.isNotEmpty &&
            journals[0]['latitude'] != null &&
            journals[0]['longitude'] != null) {
          _mapCenter = LatLng(
            journals[0]['latitude'],
            journals[0]['longitude'],
          );
        }
      });

      print('[FRIEND_PROFILE] ✅ Profile loaded successfully');
    } catch (e, stackTrace) {
      print('[FRIEND_PROFILE] ❌ Error loading data: $e');
      print('[FRIEND_PROFILE] ❌ Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  List<Marker> _buildMarkers() {
    return _publicJournals
        .where((journal) {
          return journal['latitude'] != null && journal['longitude'] != null;
        })
        .map((journal) {
          final photos =
              (journal['journal_photos'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          final photoCount = photos.length;

          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(journal['latitude'], journal['longitude']),
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JournalDetailPage(journalId: journal['id']),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (photoCount > 0)
                      Positioned(
                        bottom: 25,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFF6B4A),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$photoCount',
                            style: const TextStyle(
                              color: Color(0xFFFF6B4A),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.location_pin,
                      color: Color(0xFFFF6B4A),
                      size: 45,
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList();
  }

  Future<void> _unfriendUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Teman'),
        content: Text('Hapus ${widget.username} dari daftar teman Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _friendService.removeFriend(widget.userId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.username} dihapus dari teman')),
      );
      Navigator.pop(
        context,
        true,
      ); // Return to friends list with refresh signal
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus teman')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: const Color(0xFFFF6B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: _unfriendUser,
            tooltip: 'Hapus Teman',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFriendProfile,
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
                            widget.username,
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
                          _buildStatItem(
                            'Jurnal Publik',
                            _publicJournalCount.toString(),
                          ),
                        ],
                      ),
                    ),

                    // Map Section - Only show if there are public journals with location
                    if (_publicJournals.any(
                      (j) => j['latitude'] != null && j['longitude'] != null,
                    ))
                      Container(
                        height: 250,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _mapCenter,
                              initialZoom: 12,
                              minZoom: 5,
                              maxZoom: 18,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.jejak_pena',
                              ),
                              MarkerLayer(markers: _buildMarkers()),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Public Journals Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jurnal Publik',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B4A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B4A,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.public,
                                      size: 16,
                                      color: Color(0xFFFF6B4A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_publicJournalCount jurnal',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFFF6B4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_publicJournals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.public_off,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada jurnal publik',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${widget.username} belum membagikan jurnal',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _publicJournals.length,
                              itemBuilder: (context, index) {
                                return _buildJournalCard(
                                  _publicJournals[index],
                                );
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
          );
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
                        const Icon(
                          Icons.public,
                          size: 16,
                          color: Color(0xFFFF6B4A),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              maxLines: 2,
                              softWrap: true,
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
