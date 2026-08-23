import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/feature/course/provider/course_provider.dart';
import 'package:keste/feature/schedule/provider/schedule_provider.dart';
import 'package:keste/feature/assignments/providers/assignment_provider.dart';
import 'package:keste/feature/materials/providers/material_provider.dart';
import '../../../../data/models/assignment_model.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseByIdProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (course) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      Row(
                        children: [
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
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1B1A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: course.color.withOpacity(0.85),
                        child: Text(
                          course.name.isNotEmpty ? course.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (course.lecturer != null && course.lecturer!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              course.lecturer!,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      if (course.room != null && course.room!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                course.room!,
                                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ScheduleMenuTile(courseId: courseId),
                  const SizedBox(height: 12),
                  _AssignmentMenuTile(courseId: courseId),
                  const SizedBox(height: 12),
                  _MaterialMenuTile(courseId: courseId),
                  const SizedBox(height: 12),
                  _MenuTile(
                    icon: Icons.star_outline,
                    title: 'Nilai',
                    subtitle: 'Lihat rekap nilai',
                    onTap: () => context.push('/grades?courseId=$courseId'),
                  ),
                ]),
              ),
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

/// Menu tile dasar — desain sesuai referensi (icon kotak, title, subtitle, chevron)
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDot;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1C1C1E)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                  ],
                ),
              ),
              if (showDot)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile Jadwal — subtitle nampilin jadwal terdekat course ini
class _ScheduleMenuTile extends ConsumerWidget {
  final String courseId;
  const _ScheduleMenuTile({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider(courseId));

    final subtitle = schedulesAsync.when(
      data: (list) {
        if (list.isEmpty) return 'Belum ada jadwal';
        final s = list.first;
        return '${s.day}, ${s.startTime} - ${s.endTime}';
      },
      loading: () => 'Memuat...',
      error: (_, __) => 'Gagal memuat',
    );

    return _MenuTile(
      icon: Icons.calendar_today_outlined,
      title: 'Jadwal',
      subtitle: subtitle,
      onTap: () => context.push('/schedule?courseId=$courseId'),
    );
  }
}

/// Tile Tugas — subtitle nampilin jumlah tugas yang belum selesai + dot merah
class _AssignmentMenuTile extends ConsumerWidget {
  final String courseId;
  const _AssignmentMenuTile({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider(courseId));

    final pendingCount = assignmentsAsync.maybeWhen(
      data: (list) => list.where((a) => a.status != AssignmentStatus.completed).length,
      orElse: () => null,
    );

    final subtitle = assignmentsAsync.when(
      data: (_) => pendingCount == 0 ? 'Semua tugas selesai' : '$pendingCount Tugas Menunggu',
      loading: () => 'Memuat...',
      error: (_, __) => 'Gagal memuat',
    );

    return _MenuTile(
      icon: Icons.assignment_outlined,
      title: 'Tugas',
      subtitle: subtitle,
      showDot: (pendingCount ?? 0) > 0,
      onTap: () => context.push('/assignments?courseId=$courseId'),
    );
  }
}

/// Tile Materi — subtitle nampilin jumlah modul yang tersedia
class _MaterialMenuTile extends ConsumerWidget {
  final String courseId;
  const _MaterialMenuTile({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(courseId));

    final subtitle = materialsAsync.when(
      data: (list) => list.isEmpty ? 'Belum ada materi' : '${list.length} Modul Tersedia',
      loading: () => 'Memuat...',
      error: (_, __) => 'Gagal memuat',
    );

    return _MenuTile(
      icon: Icons.menu_book_outlined,
      title: 'Materi',
      subtitle: subtitle,
      onTap: () => context.push('/materials?courseId=$courseId'),
    );
  }
}