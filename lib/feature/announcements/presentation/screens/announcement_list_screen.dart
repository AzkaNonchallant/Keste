import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/constant/app_color.dart';

import '../../providers/announcement_provider.dart';
import '../../../../data/models/announcement_model.dart';

class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('Belum ada pengumuman'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(announcementsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = announcements[i];
                return Card(
                  child: ListTile(
                    leading: _TypeIcon(type: a.type),
                    title: Text(a.title),
                    subtitle: Text(
                      '${a.content}\n${DateFormat('d MMM yyyy').format(a.publishedAt)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () => context.push('/announcements/${a.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => context.push('/announcements/new'),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final AnnouncementType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      AnnouncementType.academic => (Icons.school_outlined, AppColors.primary),
      AnnouncementType.holiday => (Icons.beach_access_outlined, AppColors.warning),
      AnnouncementType.scheduleChange => (Icons.event_repeat_outlined, AppColors.error),
      AnnouncementType.administration => (Icons.description_outlined, AppColors.secondary),
    };
    return CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color));
  }
}