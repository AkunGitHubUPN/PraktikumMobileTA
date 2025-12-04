import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helpers/user_session.dart';
import '../helpers/supabase_helper.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String? currentPhotoUrl;
  final String? currentHobby;

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    this.currentPhotoUrl,
    this.currentHobby,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _hobbyController = TextEditingController();
  final _supabaseHelper = SupabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  String? _newPhotoPath;
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hobbyController.text = widget.currentHobby ?? '';
    _currentPhotoUrl = widget.currentPhotoUrl;
  }

  @override
  void dispose() {
    _hobbyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newPhotoPath = pickedFile.path;
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

  void _showPhotoSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFF6B4A)),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFFF6B4A),
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentPhotoUrl != null || _newPhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Hapus Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _newPhotoPath = null;
                      _currentPhotoUrl = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = UserSession.instance.currentUserId;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      String? photoUrl = _currentPhotoUrl;

      // Upload new photo if selected
      if (_newPhotoPath != null) {
        // Delete old photo if exists
        if (_currentPhotoUrl != null) {
          try {
            await _supabaseHelper.deletePhoto(_currentPhotoUrl!);
          } catch (e) {
            print('[EDIT_PROFILE] Failed to delete old photo: $e');
          }
        }

        // Upload new photo
        final fileName =
            'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoUrl = await _supabaseHelper.uploadPhoto(_newPhotoPath!, fileName);
      }

      // Update user profile in database
      final supabase = SupabaseHelper.client;
      await supabase
          .from('users')
          .update({
            'photo_url': photoUrl,
            'hobby': _hobbyController.text.trim().isEmpty
                ? null
                : _hobbyController.text.trim(),
          })
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui'),
            backgroundColor: Color(0xFFFF6B4A),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFFFF6B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Photo Profile Section
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showPhotoSourceDialog,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(
                                0xFFFF6B4A,
                              ).withOpacity(0.1),
                              backgroundImage: _newPhotoPath != null
                                  ? FileImage(File(_newPhotoPath!))
                                  : (_currentPhotoUrl != null
                                        ? NetworkImage(_currentPhotoUrl!)
                                              as ImageProvider
                                        : null),
                              child:
                                  _newPhotoPath == null &&
                                      _currentPhotoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFFFF6B4A),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showPhotoSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B4A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.currentUsername,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B4A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap foto untuk mengubah',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    // Hobby Input
                    TextField(
                      controller: _hobbyController,
                      decoration: InputDecoration(
                        labelText: 'Hobi',
                        hintText: 'Contoh: Traveling, Fotografi, Menulis',
                        prefixIcon: const Icon(
                          Icons.favorite_outline,
                          color: Color(0xFFFF6B4A),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B4A),
                            width: 2,
                          ),
                        ),
                        helperText: 'Ceritakan hobi Anda',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B4A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
