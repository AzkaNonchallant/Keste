import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/assignment_provider.dart';
import '../../../../data/models/assignment_model.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  final String assignmentId;
  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(assignmentByIdProvider(assignmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/assignments/$assignmentId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: assignmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (a) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(a.courseName ?? '-', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(DateFormat('EEEE, d MMM yyyy • HH:mm').format(a.deadline)),
                ],
              ),
              const SizedBox(height: 16),
              if (a.description != null && a.description!.isNotEmpty) ...[
                const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(a.description!),
                const SizedBox(height: 16),
              ],
              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<AssignmentStatus>(
                segments: const [
                  ButtonSegment(value: AssignmentStatus.todo, label: Text('Todo')),
                  ButtonSegment(value: AssignmentStatus.inProgress, label: Text('In Progress')),
                  ButtonSegment(value: AssignmentStatus.completed, label: Text('Done')),
                ],
                selected: {a.status},
                onSelectionChanged: (selection) {
                  ref
                      .read(assignmentFormControllerProvider.notifier)
                      .updateStatus(assignmentId, selection.first);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              final ok = await ref.read(assignmentFormControllerProvider.notifier).delete(assignmentId);
              if (ok && context.mounted) context.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}