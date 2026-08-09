import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  static const _bucket = 'avatars';

  Future<ProfileModel> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateProfile(String userId, ProfileModel profile) async {
    final data = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<String> uploadAvatar(String userId, File file, String fileName) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }
}