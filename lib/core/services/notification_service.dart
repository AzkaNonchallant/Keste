import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../../data/models/assignment_model.dart';
import '../../../data/models/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  static bool get isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    if (isMobile) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Buka');
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  int _assignmentId(String assignmentId) {
    return 'assignment_$assignmentId'.hashCode;
  }

  int _eventId(String eventId) {
    return 'event_$eventId'.hashCode;
  }

  Future<void> scheduleAssignmentReminder(AssignmentModel assignment) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    final deadline = assignment.deadline;
    if (deadline.isBefore(now)) return;

    final reminderTime = deadline.subtract(const Duration(days: 1));

    // Desktop: scheduling tidak support, tampilkan jika saat ini sudah waktunya
    if (isDesktop) {
      if (!reminderTime.isAfter(now)) {
        await _showImmediateNotification(
          id: _assignmentId(assignment.id),
          title: 'Deadline Besok!',
          body: '"${assignment.title}" - ${assignment.courseName ?? "Tugas"}',
        );
      }
      return;
    }

    if (reminderTime.isBefore(now)) {
      await _showImmediateNotification(
        id: _assignmentId(assignment.id),
        title: 'Deadline Besok!',
        body: '"${assignment.title}" - ${assignment.courseName ?? "Tugas"}',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      _assignmentId(assignment.id),
      'Deadline Besok!',
      '"${assignment.title}" - ${assignment.courseName ?? "Tugas"}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_reminders',
          'Pengingat Deadline',
          channelDescription: 'Notifikasi pengingat deadline tugas dan event',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEventReminder(EventModel event) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    final eventDate = event.eventDate;
    if (eventDate.isBefore(now)) return;

    final reminderTime = eventDate.subtract(const Duration(days: 1));

    // Desktop: scheduling tidak support, tampilkan jika saat ini sudah waktunya
    if (isDesktop) {
      if (!reminderTime.isAfter(now)) {
        await _showImmediateNotification(
          id: _eventId(event.id),
          title: 'Event Besok!',
          body: '"${event.title}" - ${event.location ?? ""}',
        );
      }
      return;
    }

    if (reminderTime.isBefore(now)) {
      await _showImmediateNotification(
        id: _eventId(event.id),
        title: 'Event Besok!',
        body: '"${event.title}" - ${event.location ?? ""}',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      _eventId(event.id),
      'Event Besok!',
      '"${event.title}" - ${event.location ?? ""}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_reminders',
          'Pengingat Deadline',
          channelDescription: 'Notifikasi pengingat deadline tugas dan event',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_reminders',
          'Pengingat Deadline',
          channelDescription: 'Notifikasi pengingat deadline tugas dan event',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
      ),
    );
  }

  Future<void> cancelNotification(String id, {bool isAssignment = true}) async {
    final notificationId = isAssignment ? _assignmentId(id) : _eventId(id);
    await _plugin.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (isDesktop) return [];
    return await _plugin.pendingNotificationRequests();
  }

  static int deadlineReminderHash(String id, {bool isAssignment = true}) {
    final prefix = isAssignment ? 'assignment' : 'event';
    return '${prefix}_$id'.hashCode;
  }
}