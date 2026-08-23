import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';

import '../../providers/todo_provider.dart';
import '../../../../data/models/todo_model.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Text(
                    'Todo Saya',
                    style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  todosAsync.maybeWhen(
                    data: (todos) {
                      final activeCount = todos.where((t) => !t.completed).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$activeCount aktif',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ===== List =====
            Expanded(
              child: todosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                data: (todos) {
                  if (todos.isEmpty) {
                    return _EmptyState();
                  }

                  final active = todos.where((t) => !t.completed).toList();
                  final done = todos.where((t) => t.completed).toList();

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(todosProvider),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        if (active.isEmpty && done.isNotEmpty)
                          const _SectionEmptyText('Semua todo sudah selesai 🎉'),
                        ...active.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TodoTile(todo: t),
                            )),
                        if (done.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Selesai',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${done.length})',
                                style: GoogleFonts.robotoMono(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...done.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TodoTile(todo: t),
                              )),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C1C1E),
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Todo Baru',
                style: GoogleFonts.robotoMono(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.robotoMono(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Apa yang perlu dilakukan?',
                  hintStyle: GoogleFonts.robotoMono(color: Colors.black26, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _submitAdd(dialogContext, ref, controller.text),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1C1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => _submitAdd(dialogContext, ref, controller.text),
                  child: Text('Tambah', style: GoogleFonts.robotoMono(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
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
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(todosProvider.notifier).delete(todo.id),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => ref.read(todosProvider.notifier).toggle(todo),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _CustomCheckbox(
                  checked: todo.completed,
                  onTap: () => ref.read(todosProvider.notifier).toggle(todo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed ? AppColors.textSecondary : AppColors.textPrimary,
                      fontWeight: todo.completed ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const _CustomCheckbox({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: checked ? const Color(0xFF1C1C1E) : const Color(0xFFD5D5D5),
            width: 1.6,
          ),
        ),
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _SectionEmptyText extends StatelessWidget {
  final String text;
  const _SectionEmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(color: AppColors.textSecondary, fontSize: 13.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checklist_rtl_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada todo',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap tombol + untuk menambah',
            style: GoogleFonts.robotoMono(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}