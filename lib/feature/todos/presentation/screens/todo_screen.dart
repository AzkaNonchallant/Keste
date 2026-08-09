import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';

import '../../providers/todo_provider.dart';
import '../../../../data/models/todo_model.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo Saya')),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(child: Text('Belum ada todo. Tap + untuk tambah.'));
          }

          final active = todos.where((t) => !t.completed).toList();
          final done = todos.where((t) => t.completed).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(todosProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...active.map((t) => _TodoTile(todo: t)),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Selesai (${done.length})',
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...done.map((t) => _TodoTile(todo: t)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Todo Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Apa yang perlu dilakukan?'),
          onSubmitted: (_) => _submitAdd(dialogContext, ref, controller.text),
        ),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () => _submitAdd(dialogContext, ref, controller.text),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _submitAdd(BuildContext dialogContext, WidgetRef ref, String title) {
    if (title.trim().isEmpty) return;
    ref.read(todosProvider.notifier).add(title.trim());
    dialogContext.pop();
  }
}

class _TodoTile extends ConsumerWidget {
  final TodoModel todo;
  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(todosProvider.notifier).delete(todo.id),
      child: Card(
        child: CheckboxListTile(
          value: todo.completed,
          onChanged: (_) => ref.read(todosProvider.notifier).toggle(todo),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              color: todo.completed ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}