import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/feature/course/provider/course_provider.dart';


class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseByIdProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mata Kuliah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/courses/$courseId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (course) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: course.color),
                title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${course.lecturer ?? '-'} • ${course.room ?? '-'}'),
              ),
            ),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.schedule_outlined,
              title: 'Jadwal',
              onTap: () => context.push('/schedule?courseId=$courseId'),
            ),
            _MenuTile(
              icon: Icons.assignment_outlined,
              title: 'Tugas',
              onTap: () => context.push('/assignments?courseId=$courseId'),
            ),
            _MenuTile(
              icon: Icons.folder_outlined,
              title: 'Materi',
              onTap: () => context.push('/materials?courseId=$courseId'),
            ),
            _MenuTile(
              icon: Icons.grade_outlined,
              title: 'Nilai',
              onTap: () => context.push('/grades?courseId=$courseId'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: const Text('Jadwal, tugas, materi, dan nilai terkait juga akan terhapus.'),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              final ok = await ref.read(courseFormControllerProvider.notifier).delete(courseId);
              if (ok && context.mounted) context.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}