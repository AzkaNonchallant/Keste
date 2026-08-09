import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/grade_model.dart';
import '../data/grade_repository.dart';

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository(ref.watch(supabaseProvider));
});

final gradesProvider = FutureProvider.autoDispose<List<GradeModel>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;
  return ref.watch(gradeRepositoryProvider).getGrades(userId);
});

final gradeByCourseProvider =
    FutureProvider.family.autoDispose<GradeModel?, String>((ref, courseId) async {
  return ref.watch(gradeRepositoryProvider).getGradeByCourse(courseId);
});

/// Rata-rata nilai akhir dari semua mata kuliah yang sudah punya nilai
final gpaSummaryProvider = FutureProvider.autoDispose<double?>((ref) async {
  final grades = await ref.watch(gradesProvider.future);
  final withFinal = grades.where((g) => g.finalGrade != null).toList();
  if (withFinal.isEmpty) return null;
  return withFinal.map((g) => g.finalGrade!).reduce((a, b) => a + b) / withFinal.length;
});

final gradeFormControllerProvider =
    AsyncNotifierProvider<GradeFormController, void>(GradeFormController.new);

class GradeFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(GradeModel grade) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(gradeRepositoryProvider).saveGrade(grade),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(gradesProvider);
      ref.invalidate(gradeByCourseProvider(grade.courseId));
      ref.invalidate(gpaSummaryProvider);
    }
    return !result.hasError;
  }
}