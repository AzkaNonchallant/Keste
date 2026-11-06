import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  static const _table = 'notifications';

  Future<List<NotificationItem>> getNotifications(String userId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => NotificationItem.fromJson(e)).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final data = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client.from(_table).update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> createNotification(NotificationItem notification) async {
    await _client.from(_table).insert(notification.toJson());
  }

  Future<void> deleteNotification(String notificationId) async {
    await _client.from(_table).delete().eq('id', notificationId);
  }

  Future<void> deleteOldNotifications(String userId) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .lt('created_at', cutoff.toIso8601String());
  }

  Future<void> saveAndNotify({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String relatedId,
  }) async {
    final notification = NotificationItem(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }
}
