import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'package:flutter/services.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Fungsi untuk menentukan apakah tugas perlu notifikasi
  bool _shouldNotify(Map<String, dynamic> task) {
    if ((task['isDone'] ?? false) == true) return false;
    if (task['dueDate'] == null || task['dueDate'].toString().isEmpty)
      return false;
    final dueDate = DateTime.tryParse(task['dueDate']);
    if (dueDate == null) return false;
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    // Notifikasi jika kurang dari 2 hari atau sudah lewat
    return diff < 2;
  }

  void _showTaskDetailDialog(BuildContext context, Map<String, dynamic> t) {
    final dueDate = DateTime.tryParse(t['dueDate'] ?? '');
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              t['title'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((t['description'] ?? '').toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(t['description']),
                      ],
                    ),
                  ),
                if (dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tenggat:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOverdue
                              ? 'Tenggat terlewati! (${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year})'
                              : '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}',
                          style: TextStyle(
                            color:
                                isOverdue
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proyek:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(t['project'] ?? '-'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (t['isDone'] ?? false) ? 'Selesai' : 'Belum Selesai',
                      style: TextStyle(
                        color:
                            (t['isDone'] ?? false)
                                ? Colors.green
                                : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

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
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final userId = FirebaseService().currentUserId;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .onPrimary, // Use theme color for better adaptability
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child:
                  userId == null
                      ? Center(
                        child: Text(
                          'Silakan login untuk melihat notifikasi.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 18, color: textColor),
                        ),
                      )
                      : StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('tasks')
                                .orderBy('dueDate')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'Belum ada notifikasi tugas.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontSize: 18, color: textColor),
                              ),
                            );
                          }
                          final tasks =
                              snapshot.data!.docs
                                  .map(
                                    (doc) => doc.data() as Map<String, dynamic>,
                                  )
                                  .where(_shouldNotify)
                                  .toList();
                          if (tasks.isEmpty) {
                            return Center(
                              child: Text(
                                'Tidak ada tugas yang mendekati tenggat.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontSize: 18, color: textColor),
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(24),
                            itemCount: tasks.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, i) {
                              final t = tasks[i];
                              final dueDate = DateTime.tryParse(
                                t['dueDate'] ?? '',
                              );
                              final isOverdue =
                                  dueDate != null &&
                                  dueDate.isBefore(DateTime.now());
                              return Card(
                                color:
                                    isOverdue
                                        ? Colors.red[50]
                                        : Colors.yellow[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: Icon(
                                    t['project'] == 'Progres Harian'
                                        ? Icons.wb_sunny
                                        : Icons.calendar_today,
                                    color: primaryColor,
                                  ),
                                  title: Text(
                                    t['title'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ((t['description'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Text(
                                          t['description'],
                                          style: TextStyle(color: textColor),
                                        ),
                                      if (dueDate != null)
                                        Text(
                                          isOverdue
                                              ? 'Tenggat terlewati! (${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year})'
                                              : 'Tenggat: ${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}',
                                          style: TextStyle(
                                            color:
                                                isOverdue
                                                    ? Colors.red
                                                    : primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap:
                                      () => _showTaskDetailDialog(context, t),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
