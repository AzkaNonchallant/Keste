import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/todo_model.dart';

class TodoRepository {
  final SupabaseClient _client;
  TodoRepository(this._client);

  Future<List<TodoModel>> getTodos(String userId) async {
    final data = await _client
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => TodoModel.fromJson(e)).toList();
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    final data = await _client.from('todos').insert(todo.toJson()).select().single();
    return TodoModel.fromJson(data);
  }

  Future<void> toggleCompleted(String id, bool completed) async {
    await _client.from('todos').update({'completed': completed}).eq('id', id);
  }

  Future<void> updateTitle(String id, String title) async {
    await _client.from('todos').update({'title': title}).eq('id', id);
  }

  Future<void> deleteTodo(String id) async {
    await _client.from('todos').delete().eq('id', id);
  }
}