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
  print('REPO: mulai insert');

  try {
    final data = await _client
        .from('courses')
        .insert({
          'user_id': course.userId,
          'name': course.name,
          'lecturer': course.lecturer,
          'room': course.room,
          'color': course.color.value.toRadixString(16),
          'created_at': course.createdAt.toIso8601String(),
        })
        .select()
        .single();

    print('REPO: INSERT BERHASIL');
    print('REPO DATA: $data');

    return CourseModel.fromJson(data);
  } catch (e, st) {
    print('================================');
    print('CREATE COURSE ERROR: $e');
    print('================================');
    print(st);

    rethrow;
  }
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