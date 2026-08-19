import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/course/provider/course_provider.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';


class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mata Kuliah')),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('Belum ada mata kuliah'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(coursesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final course = courses[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: course.color,
                      child: Text(
                        course.name.isNotEmpty ? course.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(course.name),
                    subtitle: Text('${course.lecturer ?? '-'} • ${course.room ?? '-'}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/courses/${course.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/courses/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}