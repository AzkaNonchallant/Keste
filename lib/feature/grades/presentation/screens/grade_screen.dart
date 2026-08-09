import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/course/provider/course_provider.dart';

import '../../providers/grade_provider.dart';
import '../../../../data/models/grade_model.dart';


class GradeScreen extends ConsumerWidget {
  final String? courseId; // opsional, dibuka dari CourseDetailScreen
  const GradeScreen({super.key, this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courseId != null) {
      return _SingleCourseGradeView(courseId: courseId!);
    }

    final gradesAsync = ref.watch(gradesProvider);
    final gpaAsync = ref.watch(gpaSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nilai')),
      body: gradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (grades) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(gradesProvider);
              ref.invalidate(gpaSummaryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Rata-rata Nilai Akhir',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        gpaAsync.when(
                          data: (gpa) => Text(
                            gpa != null ? gpa.toStringAsFixed(1) : '-',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          loading: () => const CircularProgressIndicator(color: Colors.white),
                          error: (_, __) => const Text('-', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (grades.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada nilai yang dicatat'),
                  )
                else
                  ...grades.map((g) => Card(
                        child: ListTile(
                          title: Text(g.courseName ?? '-'),
                          subtitle: Text(
                            'UTS: ${g.uts ?? '-'}  •  UAS: ${g.uas ?? '-'}  •  Tugas: ${g.assignment ?? '-'}',
                          ),
                          trailing: Text(
                            g.finalGrade?.toStringAsFixed(1) ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tampilan + form input nilai untuk 1 mata kuliah spesifik
class _SingleCourseGradeView extends ConsumerStatefulWidget {
  final String courseId;
  const _SingleCourseGradeView({required this.courseId});

  @override
  ConsumerState<_SingleCourseGradeView> createState() => _SingleCourseGradeViewState();
}

class _SingleCourseGradeViewState extends ConsumerState<_SingleCourseGradeView> {
  final _utsController = TextEditingController();
  final _uasController = TextEditingController();
  final _assignmentController = TextEditingController();
  final _finalController = TextEditingController();
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final gradeAsync = ref.watch(gradeByCourseProvider(widget.courseId));
    final courseAsync = ref.watch(courseByIdProvider(widget.courseId));
    final formState = ref.watch(gradeFormControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Nilai - ${courseAsync.value?.name ?? ''}')),
      body: gradeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (grade) {
          if (!_initialized && grade != null) {
            _utsController.text = grade.uts?.toString() ?? '';
            _uasController.text = grade.uas?.toString() ?? '';
            _assignmentController.text = grade.assignment?.toString() ?? '';
            _finalController.text = grade.finalGrade?.toString() ?? '';
            _initialized = true;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _GradeField(label: 'Nilai UTS', controller: _utsController),
                const SizedBox(height: 12),
                _GradeField(label: 'Nilai UAS', controller: _uasController),
                const SizedBox(height: 12),
                _GradeField(label: 'Nilai Tugas', controller: _assignmentController),
                const SizedBox(height: 12),
                _GradeField(label: 'Nilai Akhir', controller: _finalController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Nilai'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final grade = GradeModel(
      id: '',
      courseId: widget.courseId,
      uts: double.tryParse(_utsController.text),
      uas: double.tryParse(_uasController.text),
      assignment: double.tryParse(_assignmentController.text),
      finalGrade: double.tryParse(_finalController.text),
    );

    final ok = await ref.read(gradeFormControllerProvider.notifier).save(grade);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai berhasil disimpan')),
      );
    }
  }
}

class _GradeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _GradeField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}