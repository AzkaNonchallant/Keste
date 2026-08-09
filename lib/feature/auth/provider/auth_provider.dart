import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      () => ref.read(authRepositoryProvider).login(email: email, password: password),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    return !result.hasError;
  }

  Future<bool> register(String email, String password, String fullName) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            fullName: fullName,
          ),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    return !result.hasError;
  }

  Future<bool> resetPassword(String email) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resetPassword(email),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    return !result.hasError;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }
}