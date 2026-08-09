import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/course_model.dart';
import '../data/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.watch(supabaseProvider));
});

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;
  return ref.watch(courseRepositoryProvider).getCourses(userId);
});

final courseByIdProvider =
    FutureProvider.family.autoDispose<CourseModel, String>((ref, id) async {
  return ref.watch(courseRepositoryProvider).getCourseById(id);
});

final courseFormControllerProvider =
    AsyncNotifierProvider<CourseFormController, void>(CourseFormController.new);

class CourseFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(CourseModel course, {String? existingId}) async {
  state = const AsyncLoading();

  try {
    final repo = ref.read(courseRepositoryProvider);

    print('SAVE: mulai');
    print('SAVE: existingId = $existingId');
    print('SAVE: course = ${course.toJson()}');

    if (existingId == null) {
      await repo.createCourse(course);
      print('SAVE: CREATE BERHASIL');
    } else {
      await repo.updateCourse(existingId, course);
      print('SAVE: UPDATE BERHASIL');
    }

    state = const AsyncData(null);

    ref.invalidate(coursesProvider);

    print('SAVE: SELESAI');

    return true;
  } catch (e, st) {
    print('SAVE ERROR: $e');
    print(st);

    state = AsyncError(e, st);
    return false;
  }
}

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(courseRepositoryProvider).deleteCourse(id),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) ref.invalidate(coursesProvider);
    return !result.hasError;
  }
}