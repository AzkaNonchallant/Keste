import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/profile_model.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentProfile();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          ),
    );

    if (result.hasError) {
      state = AsyncError(
        _getErrorMessage(result.error),
        result.stackTrace!,
      );
      return false;
    }

    state = const AsyncData(null);
    return true;
  }

  Future<bool> register(
    String email,
    String password,
    String fullName,
  ) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            fullName: fullName,
          ),
    );

    if (result.hasError) {
      state = AsyncError(
        _getErrorMessage(result.error),
        result.stackTrace!,
      );
      return false;
    }

    state = const AsyncData(null);
    return true;
  }

  Future<bool> resetPassword(String email) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resetPassword(email),
    );

    if (result.hasError) {
      state = AsyncError(
        _getErrorMessage(result.error),
        result.stackTrace!,
      );
      return false;
    }

    state = const AsyncData(null);
    return true;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }

  String _getErrorMessage(Object? error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email atau password yang kamu masukkan salah.';

        case 'Email not confirmed':
          return 'Email kamu belum dikonfirmasi. Silakan cek email kamu.';

        case 'User already registered':
          return 'Email ini sudah terdaftar.';

        default:
          return 'Terjadi masalah saat masuk. Silakan coba lagi.';
      }
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}