import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import 'package:keste/data/models/course_model.dart';
import 'package:keste/feature/course/provider/course_provider.dart';

/// courseId == null -> mode tambah baru, courseId != null -> mode edit
class CourseFormScreen extends ConsumerStatefulWidget {
  final String? courseId;
  const CourseFormScreen({super.key, this.courseId});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _roomController = TextEditingController();
  Color _selectedColor = Colors.blue;

  static const _colorOptions = [
    Colors.blue, Colors.red, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      final course = ref.read(courseByIdProvider(widget.courseId!)).value;
      if (course != null) {
        _nameController.text = course.name;
        _lecturerController.text = course.lecturer ?? '';
        _roomController.text = course.room ?? '';
        _selectedColor = course.color;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(courseFormControllerProvider);
    final isEdit = widget.courseId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lecturerController,
                decoration: const InputDecoration(labelText: 'Dosen'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Ruangan'),
              ),
              const SizedBox(height: 16),
              const Text('Warna'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colorOptions.map((color) {
                  final selected = color.value == _selectedColor.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: selected ? 20 : 16,
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: formState.isLoading ? null : _submit,
                child: formState.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(supabaseProvider).auth.currentUser!.id;
    final course = CourseModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      lecturer: _lecturerController.text.trim(),
      room: _roomController.text.trim(),
      color: _selectedColor,
      createdAt: DateTime.now(),
    );

    final ok = await ref
        .read(courseFormControllerProvider.notifier)
        .save(course, existingId: widget.courseId);

    if (ok && mounted) context.pop();
  }
}