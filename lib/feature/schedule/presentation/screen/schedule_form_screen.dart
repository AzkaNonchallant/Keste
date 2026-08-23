import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/feature/course/provider/course_provider.dart';
import 'package:keste/feature/schedule/provider/schedule_provider.dart';
import '../../data/schedule_repository.dart';
import '../../../../data/models/schedule_model.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final String? scheduleId;
  const ScheduleFormScreen({super.key, this.scheduleId});

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  String? _selectedCourseId;
  String _selectedDay = ScheduleRepository.dayOrder.first;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final formState = ref.watch(scheduleFormControllerProvider);
    final isEdit = widget.scheduleId != null;
      ref.listen(scheduleFormControllerProvider, (previous, next) {
    if (next.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${next.error}')),
      );
    }
  });

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat mata kuliah: $e')),
        data: (courses) {
          _selectedCourseId ??= courses.isNotEmpty ? courses.first.id : null;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
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
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: ScheduleRepository.dayOrder
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDay = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimePickerTile(
                        label: 'Mulai',
                        time: _startTime,
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _startTime);
                          if (picked != null) setState(() => _startTime = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimePickerTile(
                        label: 'Selesai',
                        time: _endTime,
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _endTime);
                          if (picked != null) setState(() => _endTime = picked);
                        },
                      ),
                    ),
                  ],
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
    );
  }

  Future<void> _submit() async {
    final schedule = ScheduleModel(
      id: '',
      courseId: _selectedCourseId!,
      day: _selectedDay,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      createdAt: DateTime.now(),
    );

    final ok = await ref
        .read(scheduleFormControllerProvider.notifier)
        .save(schedule, existingId: widget.scheduleId);

    if (ok && mounted) context.pop();
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePickerTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time.format(context)),
      ),
    );
  }
}