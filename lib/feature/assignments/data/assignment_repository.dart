import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/assignment_model.dart';

class AssignmentRepository {
  final SupabaseClient _client;
  AssignmentRepository(this._client);

  static const _bucket = 'assignment-files';

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

  Future<void> updateStatus(String id, AssignmentStatus status) async {
    await _client
        .from('assignments')
        .update({'status': status.name == 'inProgress' ? 'in_progress' : status.name})
        .eq('id', id);
  }

  Future<void> deleteAssignment(String id) async {
    await _client.from('assignments').delete().eq('id', id);
  }

  Future<String> uploadSubmissionFile(String assignmentId, File file, String fileName) async {
    final userId = _client.auth.currentUser!.id;
    final path = '$userId/$assignmentId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage.from(_bucket).upload(path, file);
    final url = _client.storage.from(_bucket).getPublicUrl(path);

    await _client.from('assignments').update({'submission_file_url': url}).eq('id', assignmentId);
    return url;
  }

  Future<void> removeSubmissionFile(String assignmentId, String fileUrl) async {
    final uri = Uri.parse(fileUrl);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(_bucket);
    if (bucketIndex != -1) {
      final storagePath = segments.sublist(bucketIndex + 1).join('/');
      await _client.storage.from(_bucket).remove([storagePath]);
    }
    await _client.from('assignments').update({'submission_file_url': null}).eq('id', assignmentId);
  }
}