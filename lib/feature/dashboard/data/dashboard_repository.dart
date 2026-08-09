import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/event_model.dart';

class DashboardRepository {
  final SupabaseClient _client;
  DashboardRepository(this._client);

  Future<List> getTodaySchedule(String userId) async {
  final today = DateTime.now().weekday;

  final data = await _client
      .from('schedules')
      .select('*, courses!inner(name, room, user_id)')
      .eq('courses.user_id', userId)
      .eq('day', today)
      .order('start_time');

  return (data as List).map((e) => ScheduleModel.fromJson(e)).toList();
}

  Future<List<AssignmentModel>> getUpcomingAssignments(
    String userId, {
    int limit = 5,
  }) async {
    final data = await _client
        .from('assignments')
        .select('*, courses!inner(name, user_id)')
        .eq('courses.user_id', userId)
        .neq('status', 'completed')
        .order('deadline')
        .limit(limit);

    return (data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<List<AnnouncementModel>> getLatestAnnouncements({int limit = 3}) async {
    final data = await _client
        .from('announcements')
        .select()
        .order('published_at', ascending: false)
        .limit(limit);

    return (data as List).map((e) => AnnouncementModel.fromJson(e)).toList();
  }

  Future<List<EventModel>> getUpcomingEvents({int limit = 3}) async {
    final data = await _client
        .from('events')
        .select()
        .gte('event_date', DateTime.now().toIso8601String())
        .order('event_date')
        .limit(limit);

    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  /// Progress tugas: total vs completed
  Future<({int total, int completed})> getAssignmentProgress(String userId) async {
    final data = await _client
        .from('assignments')
        .select('status, courses!inner(user_id)')
        .eq('courses.user_id', userId);

    final list = data as List;
    final total = list.length;
    final completed = list.where((e) => e['status'] == 'completed').length;
    return (total: total, completed: completed);
  }
}