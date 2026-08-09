import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/material_model.dart' as model;

class MaterialRepository {
  final SupabaseClient _client;
  MaterialRepository(this._client);

  static const _bucket = 'materials';

  Future<List<model.MaterialModel>> getMaterials(String userId) async {
    final data = await _client
        .from('course_materials')
        .select('*, courses!inner(name, user_id)')
        .eq('courses.user_id', userId)
        .order('uploaded_at', ascending: false);

    return (data as List).map((e) => model.MaterialModel.fromJson(e)).toList();
  }

  Future<List<model.MaterialModel>> getMaterialsByCourse(String courseId) async {
    final data = await _client
        .from('course_materials')
        .select('*, courses(name)')
        .eq('course_id', courseId)
        .order('uploaded_at', ascending: false);

    return (data as List).map((e) => model.MaterialModel.fromJson(e)).toList();
  }

  
  Future<model.MaterialModel> uploadMaterial({
    required String courseId,
    required String title,
    required File file,
    required String fileName,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final path = '$userId/$courseId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage.from(_bucket).upload(path, file);
    final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);

    final data = await _client
        .from('course_materials')
        .insert({
          'course_id': courseId,
          'title': title,
          'file_url': publicUrl,
        })
        .select('*, courses(name)')
        .single();

    return model.MaterialModel.fromJson(data);
  }

  Future<void> deleteMaterial(String id, String fileUrl) async {
    await _client.from('course_materials').delete().eq('id', id);

    final uri = Uri.parse(fileUrl);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(_bucket);
    if (bucketIndex != -1) {
      final storagePath = segments.sublist(bucketIndex + 1).join('/');
      await _client.storage.from(_bucket).remove([storagePath]);
    }
  }
}