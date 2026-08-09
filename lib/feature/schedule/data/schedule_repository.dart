import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/schedule_model.dart';

class ScheduleRepository {
  final SupabaseClient _client;
  ScheduleRepository(this._client);

  static const dayOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  /// Semua jadwal milik user, join ke courses untuk nama & ruangan
  Future<List<ScheduleModel>> getAllSchedules(String userId) async {
    final data = await _client
        .from('schedules')
        .select('*, courses!inner(name, room, user_id)')
        .eq('courses.user_id', userId)
        .order('start_time');

    final list = (data as List).map((e) => ScheduleModel.fromJson(e)).toList();
    list.sort((a, b) => dayOrder.indexOf(a.day).compareTo(dayOrder.indexOf(b.day)));
    return list;
  }

  Future<List<ScheduleModel>> getSchedulesByCourse(String courseId) async {
    final data = await _client
        .from('schedules')
        .select('*, courses(name, room)')
        .eq('course_id', courseId)
        .order('start_time');

    return (data as List).map((e) => ScheduleModel.fromJson(e)).toList();
  }

  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final data = await _client.from('schedules').insert(schedule.toJson()).select().single();
    return ScheduleModel.fromJson(data);
  }

  Future<ScheduleModel> updateSchedule(String id, ScheduleModel schedule) async {
    final data = await _client
        .from('schedules')
        .update(schedule.toJson())
        .eq('id', id)
        .select()
        .single();
    return ScheduleModel.fromJson(data);
  }

  Future<void> deleteSchedule(String id) async {
    await _client.from('schedules').delete().eq('id', id);
  }
}