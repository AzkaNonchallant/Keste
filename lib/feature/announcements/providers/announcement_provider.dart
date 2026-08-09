import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import '../../../data/models/announcement_model.dart';
import '../data/announcement_repository.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(ref.watch(supabaseProvider));
});

final announcementsProvider =
    AsyncNotifierProvider<AnnouncementListNotifier, List<AnnouncementModel>>(
  AnnouncementListNotifier.new,
);

class AnnouncementListNotifier extends AsyncNotifier<List<AnnouncementModel>> {
  @override
  Future<List<AnnouncementModel>> build() async {
    return ref.watch(announcementRepositoryProvider).getAnnouncements();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final announcementByIdProvider =
    FutureProvider.family.autoDispose<AnnouncementModel, String>((ref, id) async {
  return ref.watch(announcementRepositoryProvider).getAnnouncementById(id);
});

/// Shortcut: true jika user yang login adalah admin
final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile?.isAdmin ?? false;
});

final announcementFormControllerProvider =
    AsyncNotifierProvider<AnnouncementFormController, void>(AnnouncementFormController.new);

class AnnouncementFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(AnnouncementModel announcement, {String? existingId}) async {
    state = const AsyncLoading();
    final repo = ref.read(announcementRepositoryProvider);

    final result = await AsyncValue.guard(() {
      return existingId == null
          ? repo.createAnnouncement(announcement)
          : repo.updateAnnouncement(existingId, announcement);
    });

    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) await ref.read(announcementsProvider.notifier).refresh();
    return !result.hasError;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(announcementRepositoryProvider).deleteAnnouncement(id),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) await ref.read(announcementsProvider.notifier).refresh();
    return !result.hasError;
  }
}