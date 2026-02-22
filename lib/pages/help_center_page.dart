import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pusat Bantuan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // BODY
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'FAQ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    context,
                    question: 'Bagaimana cara menambah tugas?',
                    answer:
                        'Tekan tombol tambah (+) di halaman utama, isi detail tugas, lalu simpan.',
                  ),
                  _buildFaqItem(
                    context,
                    question:
                        'Bagaimana cara melihat notifikasi tenggat tugas?',
                    answer:
                        'Buka halaman Notifikasi dari menu bawah, Anda akan melihat tugas yang mendekati tenggat.',
                  ),
                  _buildFaqItem(
                    context,
                    question: 'Bagaimana cara mengubah tema aplikasi?',
                    answer:
                        'Buka halaman Profil, lalu pilih "Pengaturan Tema Aplikasi".',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Butuh bantuan lebih lanjut?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungi pengembang di:\nEmail: reovanwilfredsakbana@gmail.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(answer, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
