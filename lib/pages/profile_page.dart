import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../utils/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'help_center_page.dart';
import 'about_us_page.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final FirebaseService _firebaseService;

  ProfilePage({super.key, this.onToggleTheme})
    : _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final user = FirebaseAuth.instance.currentUser;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Theme.of(context).appBarTheme.foregroundColor ?? Colors.black;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    String selectedColor =
        ThemeNotifier.colorOptions.entries
            .firstWhere((e) => e.value == themeNotifier.primaryColor)
            .key;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).cardColor,
                          child: Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontSize: 32,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.email ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildProfileItem(
                        context,
                        icon: Icons.person,
                        title: 'Edit Profil',
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          String? firestoreName;
                          if (user?.uid != null) {
                            final userDoc = await FirebaseService().getUserData(
                              user!.uid,
                            );
                            firestoreName = userDoc['name'] as String?;
                          }
                          final nameController = TextEditingController(
                            text: user?.displayName ?? firestoreName ?? '',
                          );
                          final emailController = TextEditingController(
                            text: user?.email ?? '',
                          );
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text('Edit Profil'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (firestoreName != null &&
                                        firestoreName.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          'Nama sebelumnya: $firestoreName',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      enabled:
                                          false, // Email tidak bisa diubah langsung
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final newName =
                                          nameController.text.trim();
                                      if (newName.isEmpty) return;
                                      try {
                                        await user?.updateDisplayName(newName);
                                        await FirebaseService().updateUserName(
                                          user?.uid,
                                          newName,
                                        );
                                        Navigator.pop(context, true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Profil berhasil diperbarui',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Gagal update profil: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Simpan'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (result == true && Navigator.canPop(context)) {
                            // Trigger refresh di halaman sebelumnya jika perlu
                          }
                        },
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.color_lens,
                        title: 'Pengaturan Tema Aplikasi',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        ThemeNotifier.colorOptions.entries.map((
                                          entry,
                                        ) {
                                          return RadioListTile<String>(
                                            title: Text(entry.key),
                                            value: entry.key,
                                            groupValue: selectedColor,
                                            onChanged: (value) {
                                              themeNotifier.setTheme(
                                                entry.value,
                                              );
                                              Navigator.pop(context);
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.help_outline,
                        title: 'Bantuan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterPage(),
                            ),
                          );
                        },
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Keluar',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            await _firebaseService.signOut();
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
      ),
    );
  }
}
