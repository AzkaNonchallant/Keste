import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import 'dart:io';
import '../../../data/models/assignment_model.dart';
import '../data/assignment_repository.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(ref.watch(supabaseProvider));
});

final assignmentsProvider =
    FutureProvider.autoDispose.family<List<AssignmentModel>, String?>((ref, courseId) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  if (courseId != null) return repo.getAssignmentsByCourse(courseId);
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;
  return repo.getAssignments(userId);
});

final assignmentByIdProvider =
    FutureProvider.family.autoDispose<AssignmentModel, String>((ref, id) async {
  return ref.watch(assignmentRepositoryProvider).getAssignmentById(id);
});

final assignmentStatusFilterProvider = StateProvider<AssignmentStatus?>((ref) => null);

final filteredAssignmentsProvider =
    FutureProvider.autoDispose<List<AssignmentModel>>((ref) async {
  final all = await ref.watch(assignmentsProvider(null).future);
  final filter = ref.watch(assignmentStatusFilterProvider);
  if (filter == null) return all;
  return all.where((a) => a.status == filter).toList();
});

final assignmentFormControllerProvider =
    AsyncNotifierProvider<AssignmentFormController, void>(AssignmentFormController.new);

class AssignmentFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(AssignmentModel assignment, {String? existingId}) async {
    state = const AsyncLoading();
    final repo = ref.read(assignmentRepositoryProvider);
    final result = await AsyncValue.guard(() {
      return existingId == null
          ? repo.createAssignment(assignment)
          : repo.updateAssignment(existingId, assignment);
    });
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(assignmentsProvider);
      ref.invalidate(filteredAssignmentsProvider);
    }
    return !result.hasError;
  }

  Future<void> updateStatus(String id, AssignmentStatus status) async {
    await ref.read(assignmentRepositoryProvider).updateStatus(id, status);
    ref.invalidate(assignmentsProvider);
    ref.invalidate(filteredAssignmentsProvider);
    ref.invalidate(assignmentByIdProvider(id));
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(assignmentRepositoryProvider).deleteAssignment(id),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(assignmentsProvider);
      ref.invalidate(filteredAssignmentsProvider);
    }
    return !result.hasError;
  }

  Future<bool> uploadSubmission(String assignmentId, File file, String fileName) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(assignmentRepositoryProvider).uploadSubmissionFile(assignmentId, file, fileName),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(assignmentByIdProvider(assignmentId));
      ref.invalidate(assignmentsProvider);
    }
    return !result.hasError;
  }

  Future<bool> removeSubmission(String assignmentId, String fileUrl) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(assignmentRepositoryProvider).removeSubmissionFile(assignmentId, fileUrl),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) {
      ref.invalidate(assignmentByIdProvider(assignmentId));
      ref.invalidate(assignmentsProvider);
    }
    return !result.hasError;
  }
}