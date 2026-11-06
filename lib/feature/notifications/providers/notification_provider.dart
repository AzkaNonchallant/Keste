import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import 'package:keste/core/services/notification_service.dart';
import 'package:keste/data/models/assignment_model.dart';
import 'package:keste/data/models/event_model.dart';
import 'package:keste/data/models/notification_model.dart';
import '../data/notification_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationListNotifier, List<NotificationItem>>(
        NotificationListNotifier.new);

class NotificationListNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    final client = ref.watch(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    return ref.watch(notificationRepositoryProvider).getNotifications(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> markAsRead(String notificationId) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    ref.invalidateSelf();
  }

  Future<void> markAllAsRead() async {
    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await ref.read(notificationRepositoryProvider).markAllAsRead(userId);
    ref.invalidateSelf();
  }

  Future<void> deleteNotification(String notificationId) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(notificationId);
    ref.invalidateSelf();
  }
}

final unreadCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notificationsProvider);
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return 0;
  return ref.watch(notificationRepositoryProvider).getUnreadCount(userId);
});

final scheduleNotificationsProvider = Provider<void>((ref) {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  final service = ref.read(notificationServiceProvider);
  final repo = ref.read(notificationRepositoryProvider);

  service.init().then((_) async {
    final assignmentsData = await client
        .from('assignments')
        .select('*, courses!inner(name, user_id)')
        .eq('courses.user_id', userId)
        .neq('status', 'completed');

    for (final a in assignmentsData) {
      try {
        await service.scheduleAssignmentReminder(
          AssignmentModel.fromJson(a),
        );
        await repo.saveAndNotify(
          userId: userId,
          title: 'Pengingat Deadline',
          body: 'Tugas "${a['title']}" deadline ${DateTime.parse(a['deadline']).day} ${_monthName(DateTime.parse(a['deadline']).month)}',
          type: 'assignment',
          relatedId: a['id'] as String,
        );
      } catch (_) {}
    }

    final eventsData = await client
        .from('events')
        .select()
        .gte('event_date', DateTime.now().toIso8601String());

    for (final e in eventsData) {
      try {
        await service.scheduleEventReminder(
          EventModel.fromJson(e),
        );
        await repo.saveAndNotify(
          userId: userId,
          title: 'Pengingat Event',
          body: 'Event "${e['title']}" pada ${DateTime.parse(e['event_date']).day} ${_monthName(DateTime.parse(e['event_date']).month)}',
          type: 'event',
          relatedId: e['id'] as String,
        );
      } catch (_) {}
    }
  });
});

String _monthName(int month) {
  const months = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return months[month];
}
