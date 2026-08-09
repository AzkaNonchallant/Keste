import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/grade_model.dart';

class GradeRepository {
  final SupabaseClient _client;
  GradeRepository(this._client);

  Future<List<GradeModel>> getGrades(String userId) async {
    final data = await _client
        .from('grades')
        .select('*, courses!inner(name, user_id)')
        .eq('courses.user_id', userId);

    return (data as List).map((e) => GradeModel.fromJson(e)).toList();
  }

  Future<GradeModel?> getGradeByCourse(String courseId) async {
    final data = await _client
        .from('grades')
        .select('*, courses(name)')
        .eq('course_id', courseId)
        .maybeSingle();

    return data != null ? GradeModel.fromJson(data) : null;
  }

  
  Future<GradeModel> saveGrade(GradeModel grade) async {
    final data = await _client
        .from('grades')
        .upsert(grade.toJson(), onConflict: 'course_id')
        .select('*, courses(name)')
        .single();

    return GradeModel.fromJson(data);
  }
}