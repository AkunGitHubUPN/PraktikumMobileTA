import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B4A),
        foregroundColor: Colors.white,
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B4A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.travel_explore,
                        size: 60,
                        color: Color(0xFFFF6B4A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'JejakPena',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buku Diary Digital Traveler',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF6B4A),
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),
                            
                            const Text(
                              'Tentang Aplikasi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B4A),
                              ),
                            ),
                          ],
                        ),                        const SizedBox(height: 16),
                        
                        const Text(
                          "JejakPena adalah buku diary digital pribadi yang mengubah setiap langkah menjadi cerita abadi. Aplikasi ini memungkinkan Anda untuk mencatat perjalanan dengan foto, lokasi, dan cerita yang tersimpan aman di cloud. Dengan fitur online terbaru, JejakPena kini dilengkapi sistem pertemanan yang memungkinkan Anda terhubung dengan traveler lain dan berbagi momen perjalanan favorit. Setiap jejak petualangan Anda dapat dibagikan dengan teman atau disimpan pribadi, menciptakan koleksi kenangan yang terbentang di seluruh dunia dan berfungsi penuh selamanya.",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),                  const SizedBox(height: 24),

                  // AUTHORS SECTION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.group_outlined,
                                color: Color(0xFFFF6B4A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tim Developer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B4A),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),

                        // Horizontal Scroll for Authors
                        SizedBox(
                          height: 240,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildAuthorCard(
                                context,
                                'Muhamad Nobel Wurjayatma',
                                '124230114',
                                'assets/about.JPG',
                              ),
                              const SizedBox(width: 16),
                              _buildAuthorCard(
                                context,
                                'Stefano Garrent Khristiawan',
                                '124230117',
                                'assets/about2.jpeg',
                              ),
                              const SizedBox(width: 16),
                              _buildAuthorCard(
                                context,
                                'Al Ilham Daffa\nNurridho',
                                '124230085',
                                'assets/about1.jpeg',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school_outlined,
                                color: Color(0xFFFF6B4A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saran dan Kesan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B4A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Untuk Mata Kuliah: Pemrograman Aplikasi Mobile',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Matkul Mobile bersama Pak Bagus mudah dan menyenangkan bukan?',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.8,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B4A).withOpacity(0.1),
                          const Color(0xFFFF6B4A).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B4A).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Versi 2.0.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFF6B4A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '© 2025 JejakPena. All rights reserved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Author Card Widget
  Widget _buildAuthorCard(
    BuildContext context,
    String name,
    String nim,
    String imagePath,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B4A).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6B4A),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 45,
                      color: Color(0xFFFF6B4A),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B4A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B4A).withOpacity(0.3),
              ),
            ),
            child: Text(
              nim,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFF6B4A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
