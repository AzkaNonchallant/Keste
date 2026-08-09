import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/assignment_model.dart';

class AssignmentRepository {
  final SupabaseClient _client;
  AssignmentRepository(this._client);

  Future<List<AssignmentModel>> getAssignments(String userId) async {
    final data = await _client
        .from('assignments')
        .select('*, courses!inner(name, user_id)')
        .eq('courses.user_id', userId)
        .order('deadline');

    return (data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<List<AssignmentModel>> getAssignmentsByCourse(String courseId) async {
    final data = await _client
        .from('assignments')
        .select('*, courses(name)')
        .eq('course_id', courseId)
        .order('deadline');

    return (data as List).map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<AssignmentModel> getAssignmentById(String id) async {
    final data = await _client
        .from('assignments')
        .select('*, courses(name)')
        .eq('id', id)
        .single();
    return AssignmentModel.fromJson(data);
  }

  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final data = await _client
        .from('assignments')
        .insert(assignment.toJson())
        .select('*, courses(name)')
        .single();
    return AssignmentModel.fromJson(data);
  }

  Future<AssignmentModel> updateAssignment(String id, AssignmentModel assignment) async {
    final data = await _client
        .from('assignments')
        .update(assignment.toJson())
        .eq('id', id)
        .select('*, courses(name)')
        .single();
    return AssignmentModel.fromJson(data);
  }

  /// Update status cepat (dipakai saat drag/tap status di list, tanpa buka form penuh)
  Future<void> updateStatus(String id, AssignmentStatus status) async {
    await _client
        .from('assignments')
        .update({'status': status.name == 'inProgress' ? 'in_progress' : status.name})
        .eq('id', id);
  }

  Future<void> deleteAssignment(String id) async {
    await _client.from('assignments').delete().eq('id', id);
  }
}