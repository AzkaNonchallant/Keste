import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import 'package:keste/feature/dashboard/provider/dashboard_provider.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => Text('Halo, ${profile?.fullName.split(' ').first ?? ''} 👋'),
          loading: () => const Text('Campus Hub'),
          error: (_, __) => const Text('Campus Hub'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat: $e')),
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProgressCard(data: data),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Jadwal Hari Ini', onSeeAll: () => context.push('/schedule')),
              if (data.todaySchedule.isEmpty)
                const _EmptyText('Tidak ada jadwal hari ini')
              else
                ...data.todaySchedule.map((s) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time, color: AppColors.primary),
                        title: Text(s.courseName ?? '-'),
                        subtitle: Text('${s.startTime} - ${s.endTime} • ${s.room ?? '-'}'),
                      ),
                    )),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Deadline Tugas', onSeeAll: () => context.push('/assignments')),
              if (data.upcomingAssignments.isEmpty)
                const _EmptyText('Tidak ada tugas mendatang')
              else
                ...data.upcomingAssignments.map((a) => Card(
                      child: ListTile(
                        leading: Icon(
                          a.isOverdue ? Icons.warning_amber : Icons.assignment_outlined,
                          color: a.isOverdue ? AppColors.error : AppColors.primary,
                        ),
                        title: Text(a.title),
                        subtitle: Text(
                          '${a.courseName ?? '-'} • ${DateFormat('d MMM, HH:mm').format(a.deadline)}',
                        ),
                      ),
                    )),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Pengumuman Terbaru', onSeeAll: () => context.push('/announcements')),
              if (data.latestAnnouncements.isEmpty)
                const _EmptyText('Belum ada pengumuman')
              else
                ...data.latestAnnouncements.map((an) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.campaign_outlined, color: AppColors.secondary),
                        title: Text(an.title),
                        subtitle: Text(
                          an.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Event Terbaru', onSeeAll: () => context.push('/events')),
              if (data.upcomingEvents.isEmpty)
                const _EmptyText('Belum ada event mendatang')
              else
                ...data.upcomingEvents.map((ev) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_outlined, color: AppColors.warning),
                        title: Text(ev.title),
                        subtitle: Text(DateFormat('d MMM yyyy').format(ev.eventDate)),
                      ),
                    )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _DashboardBottomNav(),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DashboardData data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: data.progress,
                    backgroundColor: AppColors.background,
                    strokeWidth: 6,
                  ),
                  Text('${(data.progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${data.completedAssignments} dari ${data.totalAssignments} tugas selesai'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;
  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: context.go('/dashboard'); break;
          case 1: context.go('/courses'); break;
          case 2: context.go('/schedule'); break;
          case 3: context.go('/todos'); break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Jadwal'),
        NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Todo'),
      ],
    );
  }
}