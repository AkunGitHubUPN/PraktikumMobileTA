import 'package:flutter/material.dart';
import 'dart:io';
import '../helpers/journal_service.dart';
import '../helpers/supabase_helper.dart';
import '../helpers/location_helper.dart';
import 'package:image_picker/image_picker.dart';

class JournalDetailPage extends StatefulWidget {
  final String journalId;
  const JournalDetailPage({super.key, required this.journalId});

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  final _journalService = JournalService.instance;
  final _supabaseHelper = SupabaseHelper.instance;

  Map<String, dynamic>? _journal;
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  late TextEditingController _judulController;
  late TextEditingController _ceritaController;
  List<String> _photosToDelete = [];
  List<String> _newPhotoPaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _ceritaController = TextEditingController();
    _loadJournalData();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _ceritaController.dispose();
    super.dispose();
  }
  void _loadJournalData() async {
    final journalData = await _journalService.getJournalById(widget.journalId);

    setState(() {
      _journal = journalData;
      _photos = (journalData?['journal_photos'] as List?)
          ?.cast<Map<String, dynamic>>() ?? [];
      _judulController.text = journalData?['judul'] ?? '';
      _ceritaController.text = journalData?['cerita'] ?? '';
      _isLoading = false;
    });
  }
  Future<void> _saveChanges() async {
    try {
      // Update journal text only
      final success = await _journalService.updateJournal(
        journalId: widget.journalId,
        judul: _judulController.text,
        cerita: _ceritaController.text,
      );

      if (!success) {
        throw Exception('Failed to update journal');
      }

      // Delete photos marked for deletion
      for (String photoUrl in _photosToDelete) {
        final photo = _photos.firstWhere(
          (p) => p['photo_url'] == photoUrl,
          orElse: () => {},
        );
        if (photo.isNotEmpty) {
          await _journalService.deletePhoto(photo['id']);
          await _supabaseHelper.deletePhoto(photoUrl);
        }
      }

      // Upload new photos
      for (String localPath in _newPhotoPaths) {
        final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final photoUrl = await _supabaseHelper.uploadPhoto(localPath, fileName);
        await _journalService.addPhotoToJournal(
          journalId: widget.journalId,
          photoUrl: photoUrl,
        );
      }

      _photosToDelete.clear();
      _newPhotoPaths.clear();
      _loadJournalData();
      
      setState(() {
        _isEditMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jurnal berhasil diperbarui'),
            backgroundColor: Color(0xFFFF6B4A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _togglePhotoForDelete(String photoPath) {
    setState(() {
      if (_photosToDelete.contains(photoPath)) {
        _photosToDelete.remove(photoPath);
      } else {
        _photosToDelete.add(photoPath);
      }
    });
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newPhotoPaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: const Color(0xFFFF6B4A),
          ),
        );
      }
    }
  }
  Future<void> _deleteJournal() async {
    try {
      // Delete photos from storage
      for (var photo in _photos) {
        await _supabaseHelper.deletePhoto(photo['photo_url']);
      }
      
      // Delete journal (will cascade delete photos in database)
      final success = await _journalService.deleteJournal(widget.journalId);
      
      if (!success) {
        throw Exception('Failed to delete journal');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jurnal berhasil dihapus'),
            backgroundColor: Color(0xFFFF6B4A),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menghapus jurnal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Anda yakin ingin menghapus jurnal \'${_journal!['judul']}\'?\n\nTindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJournal();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Memuat...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_journal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Jurnal tidak ditemukan.")),
      );
    }    String tanggal = _journal!['tanggal'].toString();
    String tanggalFormatted = tanggal.substring(0, 10);
    
    String locationName =
        _journal!['nama_lokasi'] ?? "Lokasi Tidak Diketahui";
    locationName = LocationHelper.formatLocationName(locationName);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_journal!['judul']),
        backgroundColor: const Color(0xFFFF6B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isEditMode ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (_isEditMode) {
              setState(() {
                _isEditMode = false;
                _photosToDelete.clear();
                _loadJournalData();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            if (_photos.isNotEmpty || _newPhotoPaths.isNotEmpty)
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + _newPhotoPaths.length + (_isEditMode ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isEditMode && index == _photos.length + _newPhotoPaths.length) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16 : 8,
                          right: 16,
                        ),
                        child: GestureDetector(
                          onTap: _pickPhotoFromGallery,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B4A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6B4A),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 60,
                                  color: Color(0xFFFF6B4A),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tambah Foto',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B4A),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }                    String path;
                    bool isNewPhoto = index >= _photos.length;
                    bool isLocalFile = false;
                    
                    if (isNewPhoto) {
                      path = _newPhotoPaths[index - _photos.length];
                      isLocalFile = true;
                    } else {
                      path = _photos[index]['photo_url'];
                      isLocalFile = false;
                    }

                    bool isMarkedForDelete = _photosToDelete.contains(path);

                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: index == _photos.length + _newPhotoPaths.length - 1 && !_isEditMode ? 16 : 8,
                      ),                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isLocalFile 
                              ? Image.file(
                                  File(path),
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  opacity: AlwaysStoppedAnimation(
                                    isMarkedForDelete ? 0.5 : 1.0,
                                  ),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 250,
                                      height: 250,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                )
                              : Image.network(
                                  path,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  opacity: AlwaysStoppedAnimation(
                                    isMarkedForDelete ? 0.5 : 1.0,
                                  ),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 250,
                                      height: 250,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                          ),
                          if (_isEditMode && !isNewPhoto)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    _togglePhotoForDelete(path),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isMarkedForDelete
                                        ? Colors.red
                                        : Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.close,
                                    color: isMarkedForDelete
                                        ? Colors.white
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          if (_isEditMode && isNewPhoto)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _newPhotoPaths.removeAt(index - _photos.length);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditMode)
                    TextField(
                      controller: _judulController,
                      decoration: InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B4A),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B4A),
                            width: 2,
                          ),
                        ),
                      ),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6B4A),
                      ),
                    )                  else
                    Text(
                      _journal!['judul'],
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6B4A),
                      ),
                    ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B4A).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFFFF6B4A),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              tanggalFormatted,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),                        const SizedBox(height: 12),

                        if (_journal!['nama_lokasi'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFFFF6B4A),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Cerita Pena',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B4A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: TextField(
                        controller: _ceritaController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: 'Cerita Perjalanan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6B4A),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6B4A),
                              width: 2,
                            ),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF6B4A).withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),                      child: Text(
                        _journal!['cerita'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
