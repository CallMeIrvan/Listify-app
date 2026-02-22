import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, CircleAvatar;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'motivation_page.dart';
import 'profile_page.dart';
import 'add_task_page.dart';
import 'progres_detail_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'notification_page.dart';
import 'package:flutter/services.dart';

enum TaskFilter { all, active, completed }

class TaskHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const TaskHomePage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();
  List<String> selectedTasks = [];
  bool isMultiSelectMode = false;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_firebaseService.currentUserId != null) {
      final userData = await _firebaseService.getUserData(
        _firebaseService.currentUserId!,
      );
      final data = userData.data() as Map<String, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          // _userName = data['name'] as String?;
        });
      }
    }
  }

  Widget _buildProjectCard(
    String title,
    String date,
    Color color, {
    int done = 0,
    int total = 0,
  }) {
    double progress = total > 0 ? done / total : 0;
    // Warna progress bar transisi dari muda ke tua sesuai progress, opacity minimum 0.6 agar tetap kelihatan
    final double minOpacity = 0.6;
    final double maxOpacity = 1.0;
    minOpacity + (maxOpacity - minOpacity) * progress;
    final Color progressColor = color.withOpacity(1.0);
    Color bgCircleColor;
    if (color == Colors.blue) {
      bgCircleColor = Colors.blue[800]!.withOpacity(0.6);
    } else if (color == Colors.green) {
      bgCircleColor = Colors.green[800]!.withOpacity(0.6);
    } else {
      bgCircleColor = color.withOpacity(0.6);
    }
    final textColor =
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Shadow agar progress bar tidak menyatu dengan card
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: bgCircleColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  Center(
                    child: Text(
                      total > 0
                          ? '${(progress * 100).toStringAsFixed(0)}%'
                          : '0%',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$done/$total tugas',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCardWithProgress(
    String projectName,
    String date,
    Color color,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(_firebaseService.currentUserId)
              .collection('tasks')
              .where('project', isEqualTo: projectName)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildProjectCard(projectName, date, color, done: 0, total: 0);
        }
        final tasks = snapshot.data!.docs;
        final total = tasks.length;
        final done = tasks.where((t) => (t['isDone'] ?? false) == true).length;
        return _buildProjectCard(
          projectName,
          date,
          color,
          done: done,
          total: total,
        );
      },
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // HOME PAGE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER HOME
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
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(_firebaseService.currentUserId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    String? name;
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.data() != null) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      name = data['name'] as String?;
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name != null ? 'Welcome, $name' : 'Welcome',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ListifyApp',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (255 * 0.18).round(),
                                ),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            child: Text(
                              name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // BODY HOME
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        // SECTION: Progress Harian & Mingguan
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProgresDetailPage(
                                            projectName: 'Progres Harian',
                                            projectDate: '',
                                            doneTasks: 0,
                                            totalTasks: 0,
                                          ),
                                    ),
                                  );
                                },
                                child: _buildProjectCardWithProgress(
                                  'Progres Harian',
                                  '',
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProgresDetailPage(
                                            projectName: 'Progres Mingguan',
                                            projectDate: '',
                                            doneTasks: 0,
                                            totalTasks: 0,
                                          ),
                                    ),
                                  );
                                },
                                child: _buildProjectCardWithProgress(
                                  'Progres Mingguan',
                                  '',
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Motivation Page
          const MotivationPage(),
          // Placeholder for AddTaskPage (tidak dipakai, AddTaskPage dibuka sebagai modal)
          Container(),
          // Notifikasi (placeholder)
          const NotificationPage(),
          // Profile Page
          Builder(
            builder:
                (context) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProfilePage(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                      ),
                    );
                    if (result == true) {
                      _loadUserData();
                    }
                  },
                  child: ProfilePage(onToggleTheme: widget.onToggleTheme),
                ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Theme.of(context).disabledColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (i) {
              if (i == 2) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: const BoxConstraints(maxHeight: 600),
                          child: SingleChildScrollView(child: AddTaskPage()),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setState(() => _selectedIndex = i);
              }
            },
          ),
        ),
      ),
    );
  }
}
