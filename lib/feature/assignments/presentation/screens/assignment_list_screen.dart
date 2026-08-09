import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/constant/app_color.dart';

import '../../providers/assignment_provider.dart';
import '../../../../data/models/assignment_model.dart';

class AssignmentListScreen extends ConsumerWidget {
  final String? courseId;
  const AssignmentListScreen({super.key, this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = courseId != null
        ? ref.watch(assignmentsProvider(courseId))
        : ref.watch(filteredAssignmentsProvider);
    final currentFilter = ref.watch(assignmentStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tugas')),
      body: Column(
        children: [
          if (courseId == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Semua',
                      selected: currentFilter == null,
                      onTap: () => ref.read(assignmentStatusFilterProvider.notifier).state = null,
                    ),
                    ...AssignmentStatus.values.map((s) => _FilterChip(
                          label: _statusLabel(s),
                          selected: currentFilter == s,
                          onTap: () => ref.read(assignmentStatusFilterProvider.notifier).state = s,
                        )),
                  ],
                ),
              ),
            ),
          Expanded(
            child: assignmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat: $e')),
              data: (assignments) {
                if (assignments.isEmpty) {
                  return const Center(child: Text('Tidak ada tugas'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(filteredAssignmentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: assignments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final a = assignments[i];
                      return Card(
                        child: ListTile(
                          leading: _PriorityDot(priority: a.priority),
                          title: Text(a.title),
                          subtitle: Text(
                            '${a.courseName ?? '-'} • ${DateFormat('d MMM, HH:mm').format(a.deadline)}',
                          ),
                          trailing: _StatusChip(status: a.status),
                          onTap: () => context.push('/assignments/${a.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/assignments/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _statusLabel(AssignmentStatus s) => switch (s) {
        AssignmentStatus.todo => 'Todo',
        AssignmentStatus.inProgress => 'In Progress',
        AssignmentStatus.completed => 'Completed',
      };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final AssignmentPriority priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      AssignmentPriority.high => AppColors.error,
      AssignmentPriority.medium => AppColors.warning,
      AssignmentPriority.low => AppColors.success,
    };
    return CircleAvatar(backgroundColor: color, radius: 6);
  }
}

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AssignmentStatus.todo => ('Todo', AppColors.textSecondary),
      AssignmentStatus.inProgress => ('In Progress', AppColors.primary),
      AssignmentStatus.completed => ('Done', AppColors.success),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}