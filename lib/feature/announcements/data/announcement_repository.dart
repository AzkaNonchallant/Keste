import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/announcement_model.dart';

class AnnouncementRepository {
  final SupabaseClient _client;
  AnnouncementRepository(this._client);

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final data = await _client
        .from('announcements')
        .select()
        .order('published_at', ascending: false);

    return (data as List).map((e) => AnnouncementModel.fromJson(e)).toList();
  }

  Future<AnnouncementModel> getAnnouncementById(String id) async {
    final data = await _client.from('announcements').select().eq('id', id).single();
    return AnnouncementModel.fromJson(data);
  }

  /// Hanya admin yang bisa insert (ditegakkan oleh RLS policy di Supabase)
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    final data = await _client
        .from('announcements')
        .insert(announcement.toJson())
        .select()
        .single();
    return AnnouncementModel.fromJson(data);
  }

  Future<AnnouncementModel> updateAnnouncement(String id, AnnouncementModel announcement) async {
    final data = await _client
        .from('announcements')
        .update(announcement.toJson())
        .eq('id', id)
        .select()
        .single();
    return AnnouncementModel.fromJson(data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.from('announcements').delete().eq('id', id);
  }
}