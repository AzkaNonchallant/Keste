import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/event_model.dart';
import '../../announcements/providers/announcement_provider.dart' show isAdminProvider;
import '../data/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(supabaseProvider));
});

final eventsProvider =
    AsyncNotifierProvider<EventListNotifier, List<EventModel>>(EventListNotifier.new);

class EventListNotifier extends AsyncNotifier<List<EventModel>> {
  @override
  Future<List<EventModel>> build() async {
    return ref.watch(eventRepositoryProvider).getEvents();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final eventByIdProvider =
    FutureProvider.family.autoDispose<EventModel, String>((ref, id) async {
  return ref.watch(eventRepositoryProvider).getEventById(id);
});

/// Event dikelompokkan: akan datang vs sudah lewat
final upcomingEventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final events = await ref.watch(eventsProvider.future);
  return events.where((e) => e.isUpcoming).toList();
});

final pastEventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final events = await ref.watch(eventsProvider.future);
  return events.where((e) => !e.isUpcoming).toList();
});

final eventFormControllerProvider =
    AsyncNotifierProvider<EventFormController, void>(EventFormController.new);

class EventFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(
    EventModel event, {
    String? existingId,
    File? imageFile,
    String? imageFileName,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(eventRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      var finalEvent = event;

      if (imageFile != null && imageFileName != null) {
        final url = await repo.uploadEventImage(imageFile, imageFileName);
        finalEvent = EventModel(
          id: event.id,
          title: event.title,
          description: event.description,
          location: event.location,
          eventDate: event.eventDate,
          imageUrl: url,
          createdBy: event.createdBy,
        );
      }

      return existingId == null
          ? repo.createEvent(finalEvent)
          : repo.updateEvent(existingId, finalEvent);
    });

    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) await ref.read(eventsProvider.notifier).refresh();
    return !result.hasError;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(eventRepositoryProvider).deleteEvent(id));
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    if (!result.hasError) await ref.read(eventsProvider.notifier).refresh();
    return !result.hasError;
  }
}