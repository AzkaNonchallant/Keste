import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keste/feature/course/provider/course_provider.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';

import '../../providers/assignment_provider.dart';
import '../../../../data/models/assignment_model.dart';

class AssignmentFormScreen extends ConsumerStatefulWidget {
  final String? assignmentId;
  const AssignmentFormScreen({super.key, this.assignmentId});

  @override
  ConsumerState<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends ConsumerState<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCourseId;
  AssignmentPriority _priority = AssignmentPriority.medium;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final formState = ref.watch(assignmentFormControllerProvider);
    final isEdit = widget.assignmentId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat mata kuliah: $e')),
        data: (courses) {
          _selectedCourseId ??= courses.isNotEmpty ? courses.first.id : null;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                  items: courses
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCourseId = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul Tugas'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Deadline'),
                    child: Text(DateFormat('d MMM yyyy, HH:mm').format(_deadline)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AssignmentPriority>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Prioritas'),
                  items: AssignmentPriority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: formState.isLoading || _selectedCourseId == null ? null : _submit,
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final assignment = AssignmentModel(
      id: '',
      courseId: _selectedCourseId!,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _deadline,
      priority: _priority,
      status: AssignmentStatus.todo,
      createdAt: DateTime.now(),
    );

    final ok = await ref
        .read(assignmentFormControllerProvider.notifier)
        .save(assignment, existingId: widget.assignmentId);

    if (ok && mounted) context.pop();
  }
}