import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

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
                  'Tentang Aplikasi',
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
                    'ListifyApp',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ListifyApp adalah aplikasi manajemen tugas harian dan mingguan yang membantu Anda tetap produktif, terorganisir, dan tidak melewatkan tenggat waktu penting.\n\n'
                    'Fitur utama aplikasi ini meliputi:\n'
                    '- Menambah, mengedit, dan menghapus tugas harian maupun mingguan dengan mudah.\n'
                    '- Notifikasi khusus di halaman notifikasi untuk tugas yang mendekati tenggat atau sudah lewat.\n'
                    '- Statistik progres tugas harian dan mingguan secara visual.\n'
                    '- Pusat bantuan (Help Center) dan halaman profil yang dapat disesuaikan.\n'
                    '- Tampilan modern, ramah pengguna, dan mendukung tema gelap/terang.\n\n'
                    'Aplikasi ini dikembangkan untuk mendukung produktivitas dan kolaborasi, baik untuk individu maupun kelompok.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Our Team:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMemberItem(
                    'Reovan Wilfred Sakbana',
                    'Frontend Developer',
                  ),
                  _buildMemberItem('I Made Adi Wiranata', 'Backend Developer'),
                  _buildMemberItem('Putu Ari Sentanu', 'UI/UX Designer'),
                  _buildMemberItem('I Putu Gede Mahendra', 'Sistem Analist'),
                  _buildMemberItem(
                    'Makarius Delpiero Wawo Tiwu',
                    'Project Manager',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(String name, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.person, size: 22, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(role, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }
}
