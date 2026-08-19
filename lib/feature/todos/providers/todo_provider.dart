import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/todo_model.dart';
import '../data/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(supabaseProvider));
});

final todosProvider =
    AsyncNotifierProvider<TodoListNotifier, List<TodoModel>>(TodoListNotifier.new);

class TodoListNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() async {
    final client = ref.watch(supabaseProvider);
    final userId = client.auth.currentUser!.id;
    return ref.watch(todoRepositoryProvider).getTodos(userId);
  }

  Future<bool> add(String title) async {
    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser!.id;

    final result = await AsyncValue.guard(
      () => ref.read(todoRepositoryProvider).createTodo(
            TodoModel(id: '', userId: userId, title: title, createdAt: DateTime.now()),
          ),
    );

    if (result.hasError) return false;

    await refresh();
    return true;
  }

  Future<void> toggle(TodoModel todo) async {
    final current = state.value ?? [];
    final optimistic = current
        .map((t) => t.id == todo.id ? t.copyWith(completed: !t.completed) : t)
        .toList();

    state = AsyncData(optimistic);

    try {
      await ref.read(todoRepositoryProvider).toggleCompleted(todo.id, !todo.completed);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> rename(String id, String title) async {
    await ref.read(todoRepositoryProvider).updateTitle(id, title);
    await refresh();
  }

  Future<void> delete(String id) async {
    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());

    try {
      await ref.read(todoRepositoryProvider).deleteTodo(id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}