import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': 'student',
      });
    }

    return response;
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() {
    return _client.auth.signOut();
  }

  Future<ProfileModel?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data != null ? ProfileModel.fromJson(data) : null;
  }
}