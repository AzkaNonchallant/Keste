import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/material_model.dart';
import '../data/material_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(ref.watch(supabaseProvider));
});

final materialsProvider =
    FutureProvider.autoDispose.family<List<MaterialModel>, String?>((ref, courseId) async {
  final repo = ref.watch(materialRepositoryProvider);

  if (courseId != null) return repo.getMaterialsByCourse(courseId);

  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;
  return repo.getMaterials(userId);
});

final materialUploadControllerProvider =
    AsyncNotifierProvider<MaterialUploadController, void>(MaterialUploadController.new);

class MaterialUploadController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> upload({
    required String courseId,
    required String title,
    required dynamic file, // File dari dart:io
    required String fileName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(materialRepositoryProvider).uploadMaterial(
            courseId: courseId,
            title: title,
            file: file,
            fileName: fileName,
          ),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) ref.invalidate(materialsProvider);
    return !result.hasError;
  }

  Future<bool> delete(String id, String fileUrl) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(materialRepositoryProvider).deleteMaterial(id, fileUrl),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) ref.invalidate(materialsProvider);
    return !result.hasError;
  }
}