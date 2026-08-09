import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/material_provider.dart';
import '../../../../data/models/material_model.dart';

class MaterialListScreen extends ConsumerWidget {
  final String? courseId;
  const MaterialListScreen({super.key, this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Materi Kuliah')),
      body: materialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (materials) {
          if (materials.isEmpty) {
            return const Center(child: Text('Belum ada materi'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(materialsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: materials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = materials[i];
                return Card(
                  child: ListTile(
                    leading: _FileIcon(extension: m.extension),
                    title: Text(m.title),
                    subtitle: Text(m.courseName ?? '-'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, m),
                    ),
                    onTap: () => launchUrl(Uri.parse(m.fileUrl), mode: LaunchMode.externalApplication),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/materials/upload${courseId != null ? '?courseId=$courseId' : ''}'),
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MaterialModel material) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Materi?'),
        content: Text(material.title),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              await ref
                  .read(materialUploadControllerProvider.notifier)
                  .delete(material.id, material.fileUrl);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  final String extension;
  const _FileIcon({required this.extension});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (extension) {
      'pdf' => (Icons.picture_as_pdf, Colors.red),
      'ppt' || 'pptx' => (Icons.slideshow, Colors.orange),
      'doc' || 'docx' => (Icons.description, Colors.blue),
      _ => (Icons.insert_drive_file, AppColors.textSecondary),
    };
    return CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color));
  }
}