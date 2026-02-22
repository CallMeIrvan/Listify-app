import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ProgresDetailPage extends StatefulWidget {
  final String projectName;
  final String projectDate;
  final int doneTasks;
  final int totalTasks;

  const ProgresDetailPage({
    Key? key,
    required this.projectName,
    required this.projectDate,
    required this.doneTasks,
    required this.totalTasks,
  }) : super(key: key);

  @override
  State<ProgresDetailPage> createState() => _ProgresDetailPageState();
}

class _ProgresDetailPageState extends State<ProgresDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> filter = ValueNotifier<String>('Semua');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Progres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.projectName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<String>(
                valueListenable: filter,
                builder: (context, value, _) {
                  return Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: value == 'Semua',
                        onSelected: (_) => filter.value = 'Semua',
                        selectedColor: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Selesai'),
                        selected: value == 'Selesai',
                        onSelected: (_) => filter.value = 'Selesai',
                        selectedColor: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Belum'),
                        selected: value == 'Belum',
                        onSelected: (_) => filter.value = 'Belum',
                        selectedColor: Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: filter,
                  builder: (context, filterValue, _) {
                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(_firebaseService.currentUserId)
                              .collection('tasks')
                              .where('project', isEqualTo: widget.projectName)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final tasks = snapshot.data!.docs;
                        List<QueryDocumentSnapshot> filteredTasks = tasks;
                        if (filterValue == 'Selesai') {
                          filteredTasks =
                              tasks
                                  .where((t) => (t['isDone'] ?? false) == true)
                                  .toList();
                        } else if (filterValue == 'Belum') {
                          filteredTasks =
                              tasks
                                  .where((t) => (t['isDone'] ?? false) == false)
                                  .toList();
                        }
                        final total = filteredTasks.length;
                        final done =
                            filteredTasks
                                .where((t) => (t['isDone'] ?? false) == true)
                                .length;
                        final progress = total > 0 ? done / total : 0.0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (filteredTasks.isNotEmpty) ...[
                              Text(
                                'Progress',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor:
                                      Theme.of(context).dividerColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}% tugas selesai ($done dari $total tugas)',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 32),
                            ],
                            Text(
                              'Daftar Tugas',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (filteredTasks.isEmpty)
                              Text(
                                widget.projectName == 'Progres Harian'
                                    ? 'Belum ada tugas di tanggal ini.'
                                    : 'Belum ada tugas untuk project ini.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            if (filteredTasks.isNotEmpty)
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final doc = filteredTasks[index];
                                    final t =
                                        doc.data() as Map<String, dynamic>;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 14,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Checkbox(
                                                  activeColor:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                  onChanged: (val) async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(
                                                          _firebaseService
                                                              .currentUserId,
                                                        )
                                                        .collection('tasks')
                                                        .doc(doc.id)
                                                        .update({
                                                          'isDone':
                                                              val ?? false,
                                                        });
                                                  },
                                                  value: t['isDone'] ?? false,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    t['title'] ?? '-',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                      ),
                                                      onPressed: () async {
                                                        final shouldEdit = await showDialog<
                                                          bool
                                                        >(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => AlertDialog(
                                                                title: const Text(
                                                                  'Konfirmasi Edit',
                                                                ),
                                                                content: const Text(
                                                                  'Apakah Anda yakin ingin mengedit tugas ini?',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.of(
                                                                          context,
                                                                        ).pop(
                                                                          false,
                                                                        ),
                                                                    child:
                                                                        const Text(
                                                                          'Batal',
                                                                        ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () => Navigator.of(
                                                                          context,
                                                                        ).pop(
                                                                          true,
                                                                        ),
                                                                    child:
                                                                        const Text(
                                                                          'Ya',
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                        if (shouldEdit ==
                                                            true) {
                                                          _showEditDialog(
                                                            doc.id,
                                                            t,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        final shouldDelete = await showDialog<
                                                          bool
                                                        >(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => AlertDialog(
                                                                title: const Text(
                                                                  'Konfirmasi Hapus',
                                                                ),
                                                                content: const Text(
                                                                  'Apakah Anda yakin ingin menghapus tugas ini?',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.of(
                                                                          context,
                                                                        ).pop(
                                                                          false,
                                                                        ),
                                                                    child:
                                                                        const Text(
                                                                          'Batal',
                                                                        ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () => Navigator.of(
                                                                          context,
                                                                        ).pop(
                                                                          true,
                                                                        ),
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                          'Hapus',
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                        if (shouldDelete ==
                                                            true) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                'users',
                                                              )
                                                              .doc(
                                                                _firebaseService
                                                                    .currentUserId,
                                                              )
                                                              .collection(
                                                                'tasks',
                                                              )
                                                              .doc(doc.id)
                                                              .delete();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if ((t['description'] ?? '')
                                                .toString()
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                t['description'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(fontSize: 13),
                                              ),
                                            ],
                                            if ((t['dueDate'] ?? '')
                                                .toString()
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDueDate(t['dueDate']),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 13,
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                    ),
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              (t['isDone'] ?? false)
                                                  ? 'Selesai'
                                                  : 'Belum Selesai',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                color:
                                                    (t['isDone'] ?? false)
                                                        ? Colors.green
                                                        : Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(dynamic dueDate) {
    if (dueDate == null || dueDate.toString().isEmpty) return '';
    try {
      final date = DateTime.tryParse(dueDate) ?? DateTime.now();
      return 'Tenggat:  ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  void _showEditDialog(String docId, Map<String, dynamic> t) {
    final titleController = TextEditingController(text: t['title'] ?? '');
    final descController = TextEditingController(text: t['description'] ?? '');
    DateTime? dueDate =
        t['dueDate'] != null && t['dueDate'].toString().isNotEmpty
            ? DateTime.tryParse(t['dueDate'])
            : null;
    showDialog(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Edit Tugas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Judul tugas',
                      errorText: errorText,
                    ),
                    onChanged: (value) {
                      setState(() {
                        errorText =
                            value.trim().isEmpty
                                ? 'Judul tidak boleh kosong'
                                : null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Deskripsi tugas',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tenggat Waktu'),
                  ),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dueDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dueDate != null
                                ? '${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}'
                                : 'Pilih tenggat waktu',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed:
                      errorText != null || titleController.text.trim().isEmpty
                          ? null
                          : () async {
                            final shouldSave = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Konfirmasi Edit'),
                                    content: const Text(
                                      'Simpan perubahan tugas ini?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: const Text('Simpan'),
                                      ),
                                    ],
                                  ),
                            );
                            if (shouldSave == true) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_firebaseService.currentUserId)
                                  .collection('tasks')
                                  .doc(docId)
                                  .update({
                                    'title': titleController.text.trim(),
                                    'description': descController.text.trim(),
                                    'dueDate': dueDate?.toIso8601String() ?? '',
                                  });
                              Navigator.of(context).pop();
                            }
                          },
                  child: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
