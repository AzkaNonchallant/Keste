import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/feature/course/provider/course_provider.dart';

import '../../providers/material_provider.dart';

class MaterialUploadScreen extends ConsumerStatefulWidget {
  final String? courseId;
  const MaterialUploadScreen({super.key, this.courseId});

  @override
  ConsumerState<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
}

class _MaterialUploadScreenState extends ConsumerState<MaterialUploadScreen> {
  final _titleController = TextEditingController();
  String? _selectedCourseId;
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        if (_titleController.text.isEmpty) {
          _titleController.text = _pickedFile!.name.split('.').first;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final uploadState = ref.watch(materialUploadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Materi')),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat mata kuliah: $e')),
        data: (courses) {
          _selectedCourseId ??= courses.isNotEmpty ? courses.first.id : null;

          return ListView(
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
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Materi'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(_pickedFile == null ? Icons.upload_file : Icons.check_circle,
                          size: 40, color: _pickedFile == null ? Colors.grey : Colors.green),
                      const SizedBox(height: 8),
                      Text(_pickedFile?.name ?? 'Pilih file PDF, PPT, atau DOCX'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: uploadState.isLoading || _pickedFile == null || _selectedCourseId == null
                    ? null
                    : _submit,
                child: uploadState.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_pickedFile?.path == null) return;

    final ok = await ref.read(materialUploadControllerProvider.notifier).upload(
          courseId: _selectedCourseId!,
          title: _titleController.text.trim(),
          file: File(_pickedFile!.path!),
          fileName: _pickedFile!.name,
        );

    if (ok && mounted) context.pop();
  }
}