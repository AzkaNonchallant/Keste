import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/schedule_model.dart';
import '../data/schedule_repository.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(supabaseProvider));
});

/// courseId opsional -> jika diisi, filter jadwal untuk 1 matkul saja
final schedulesProvider =
    FutureProvider.autoDispose.family<List<ScheduleModel>, String?>((ref, courseId) async {
  final repo = ref.watch(scheduleRepositoryProvider);

  if (courseId != null) {
    return repo.getSchedulesByCourse(courseId);
  }

  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;
  return repo.getAllSchedules(userId);
});

/// Jadwal dikelompokkan per hari, untuk ditampilkan dalam tab Senin-Minggu
final schedulesByDayProvider =
    FutureProvider.autoDispose<Map<String, List<ScheduleModel>>>((ref) async {
  final schedules = await ref.watch(schedulesProvider(null).future);
  final grouped = <String, List<ScheduleModel>>{};

  for (final day in ScheduleRepository.dayOrder) {
    grouped[day] = schedules.where((s) => s.day == day).toList();
  }
  return grouped;
});

final scheduleFormControllerProvider =
    AsyncNotifierProvider<ScheduleFormController, void>(ScheduleFormController.new);

class ScheduleFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(ScheduleModel schedule, {String? existingId}) async {
    state = const AsyncLoading();
    final repo = ref.read(scheduleRepositoryProvider);

    final result = await AsyncValue.guard(() {
      return existingId == null
          ? repo.createSchedule(schedule)
          : repo.updateSchedule(existingId, schedule);
    });

    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(schedulesProvider);
      ref.invalidate(schedulesByDayProvider);
    }
    return !result.hasError;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(scheduleRepositoryProvider).deleteSchedule(id),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(schedulesProvider);
      ref.invalidate(schedulesByDayProvider);
    }
    return !result.hasError;
  }
}