import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  final List<String> _projectList = ['Progres Harian', 'Progres Mingguan'];
  String _selectedProject = 'Progres Harian';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userId = _firebaseService.currentUserId;
        if (userId == null) {
          throw Exception('User tidak ditemukan');
        }

        await _firebaseService.addTask(
          userId,
          _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          project: _selectedProject,
        );

        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessNotification();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Gagal menambahkan tugas: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showSuccessNotification() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Tugas berhasil ditambahkan'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final titleColor =
        Theme.of(context).textTheme.titleLarge?.color ?? Colors.black;
    final primaryColor = Theme.of(context).primaryColor;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header custom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'Tambah Tugas',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInputSection(
                          title: 'Judul',
                          child: TextFormField(
                            controller: _titleController,
                            decoration: _getInputDecoration(
                              'Masukkan judul tugas',
                              backgroundColor,
                              textColor,
                            ),
                            validator:
                                (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Judul tidak boleh kosong'
                                        : null,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildInputSection(
                          title: 'Deskripsi',
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: _getInputDecoration(
                              'Masukkan deskripsi tugas',
                              backgroundColor,
                              textColor,
                            ),
                            minLines: 3,
                            maxLines: 5,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildInputSection(
                          title: 'Pilih Progres',
                          child: DropdownButtonFormField<String>(
                            value: _selectedProject,
                            items:
                                _projectList
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Row(
                                          children: [
                                            Icon(
                                              p == 'Progres Harian'
                                                  ? Icons.wb_sunny
                                                  : Icons.calendar_today,
                                              color: primaryColor,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              p,
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedProject = val);
                            },
                            decoration: _getInputDecoration(
                              'Pilih progres',
                              backgroundColor,
                              textColor,
                            ),
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildInputSection(
                          title: 'Tenggat Waktu',
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white,
                                        surface: cardColor,
                                        onSurface: textColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null)
                                setState(() => _dueDate = picked);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isLoading ? null : _submitTask,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Text(
                                      'Tambah Tugas',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
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
      ),
    );
  }

  Widget _buildInputSection({required String title, required Widget child}) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _getInputDecoration(
    String hint,
    Color fillColor,
    Color textColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
