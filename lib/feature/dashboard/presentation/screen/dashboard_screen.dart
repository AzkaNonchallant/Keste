import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import 'package:keste/feature/dashboard/provider/dashboard_provider.dart';
import 'package:keste/shared/neo_brutal.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push('/profile'),
        ),
        
        title: profileAsync.when(
          data: (profile) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.robotoMono(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                'Halo, ${profile?.fullName.split(' ').first ?? ''} 👋',
                style: GoogleFonts.robotoMono(fontStyle: GoogleFonts.poppins().fontStyle),
              ),
            ],
          ),
          loading: () => const Text('Campus Hub'),
          error: (_, __) => const Text('Campus Hub'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat: $e')),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _ProgressCard(data: data),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Jadwal Hari Ini', onSeeAll: () => context.push('/schedule')),
              const SizedBox(height: 12),
              if (data.todaySchedule.isEmpty)
                const _EmptyText('Tidak ada jadwal hari ini')
              else
                ...data.todaySchedule.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ScheduleCard(
                      startTime: s.startTime,
                      endTime: s.endTime,
                      title: s.courseName ?? '-',
                      location: s.room ?? '-',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Deadline Tugas', onSeeAll: () => context.push('/assignments')),
              const SizedBox(height: 12),
              if (data.upcomingAssignments.isEmpty)
                const _EmptyText('Tidak ada tugas mendatang')
              else
                ...data.upcomingAssignments.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ListCard(
                        icon: a.isOverdue ? Icons.warning_amber_rounded : Icons.assignment_outlined,
                        iconColor: a.isOverdue ? AppColors.error : AppColors.textPrimary,
                        shadowColor: a.isOverdue ? const Color(0xFFFF8A80) : const Color(0xFF80D8FF),
                        title: a.title,
                        subtitle:
                            '${a.courseName ?? '-'} • ${DateFormat('d MMM, HH:mm').format(a.deadline)}',
                        onTap: () => context.push('/assignments/${a.id}'),
                      ),
                    )),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Pengumuman Terbaru', onSeeAll: () => context.push('/announcements')),
              const SizedBox(height: 12),
              if (data.latestAnnouncements.isEmpty)
                const _EmptyText('Belum ada pengumuman')
              else
                ...data.latestAnnouncements.map((an) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ListCard(
                        icon: Icons.campaign_outlined,
                        iconColor: AppColors.secondary,
                        shadowColor: const Color(0xFFA5D6A7),
                        title: an.title,
                        subtitle: an.content,
                        onTap: () => context.push('/announcements/${an.id}'),
                      ),
                    )),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Event Terbaru', onSeeAll: () => context.push('/events')),
              const SizedBox(height: 12),
              if (data.upcomingEvents.isEmpty)
                const _EmptyText('Belum ada event mendatang')
              else
                ...data.upcomingEvents.map((ev) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ListCard(
                        icon: Icons.event_outlined,
                        iconColor: AppColors.warning,
                        shadowColor: const Color(0xFFFFE082),
                        title: ev.title,
                        subtitle: DateFormat('d MMM yyyy').format(ev.eventDate),
                        onTap: () => context.push('/events/${ev.id}'),
                      ),
                    )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DashboardData data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      shadowColor: const Color.fromARGB(255, 10, 10, 10),
      offset: 6,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress Tugas',
                    style: GoogleFonts.robotoMono().copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'You have completed ${data.completedAssignments} of ${data.totalAssignments} task',
                  style: GoogleFonts.robotoMono().copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: CircularProgressIndicator(
                    value: data.progress,
                    backgroundColor: AppColors.background,
                    strokeWidth: 6,
                  ),
                ),
                Text('${(data.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
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
        Text(title, style: GoogleFonts.robotoMono().copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary)),
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

class _ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String title;
  final String location;

  const _ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      shadowColor: const Color(0xFFB39DDB),
      offset: 5,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(endTime, style: const TextStyle(fontSize: 13, color: Colors.black45)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card list generik (dipakai buat Tugas, Pengumuman, Event) — ikon kotak + judul + subtitle
class _ListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color shadowColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ListCard({
    required this.icon,
    required this.iconColor,
    required this.shadowColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      shadowColor: shadowColor,
      offset: 5,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}