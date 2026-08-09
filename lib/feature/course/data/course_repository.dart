import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/course_model.dart';

class CourseRepository {
  final SupabaseClient _client;
  CourseRepository(this._client);

  Future<List<CourseModel>> getCourses(String userId) async {
    final data = await _client
        .from('courses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => CourseModel.fromJson(e)).toList();
  }

  Future<CourseModel> getCourseById(String id) async {
    final data = await _client.from('courses').select().eq('id', id).single();
    return CourseModel.fromJson(data);
  }

  Future<CourseModel> createCourse(CourseModel course) async {
    final data = await _client.from('courses').insert(course.toJson()).select().single();
    return CourseModel.fromJson(data);
  }

  Future<CourseModel> updateCourse(String id, CourseModel course) async {
    final data = await _client
        .from('courses')
        .update(course.toJson())
        .eq('id', id)
        .select()
        .single();
    return CourseModel.fromJson(data);
  }


  Future<void> deleteCourse(String id) async {
    await _client.from('courses').delete().eq('id', id);
  }
}