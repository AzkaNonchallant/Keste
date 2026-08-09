import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import '../../../data/models/profile_model.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

final profileFormControllerProvider =
    AsyncNotifierProvider<ProfileFormController, void>(ProfileFormController.new);

class ProfileFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(
    ProfileModel profile, {
    File? avatarFile,
    String? avatarFileName,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      var updated = profile;

      if (avatarFile != null && avatarFileName != null) {
        final url = await repo.uploadAvatar(profile.id, avatarFile, avatarFileName);
        updated = profile.copyWith(photoUrl: url);
      }

      return repo.updateProfile(profile.id, updated);
    });

    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) ref.invalidate(currentProfileProvider);
    return !result.hasError;
  }
}