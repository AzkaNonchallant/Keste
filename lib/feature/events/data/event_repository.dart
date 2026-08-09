import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/event_model.dart';

class EventRepository {
  final SupabaseClient _client;
  EventRepository(this._client);

  static const _bucket = 'event-images';

  Future<List<EventModel>> getEvents() async {
    final data = await _client.from('events').select().order('event_date');
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  Future<EventModel> getEventById(String id) async {
    final data = await _client.from('events').select().eq('id', id).single();
    return EventModel.fromJson(data);
  }

  Future<String?> uploadEventImage(File file, String fileName) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from(_bucket).upload(path, file);
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<EventModel> createEvent(EventModel event) async {
    final data = await _client.from('events').insert(event.toJson()).select().single();
    return EventModel.fromJson(data);
  }

  Future<EventModel> updateEvent(String id, EventModel event) async {
    final data =
        await _client.from('events').update(event.toJson()).eq('id', id).select().single();
    return EventModel.fromJson(data);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}