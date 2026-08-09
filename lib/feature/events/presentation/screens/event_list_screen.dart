import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/constant/app_color.dart';

import '../../providers/event_provider.dart';
import '../../../../data/models/event_model.dart';
import '../../../announcements/providers/announcement_provider.dart' show isAdminProvider;

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Kampus'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Akan Datang'), Tab(text: 'Selesai')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EventList(provider: upcomingEventsProvider),
          _EventList(provider: pastEventsProvider),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => context.push('/events/new'),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _EventList extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<EventModel>>> provider;
  const _EventList({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(provider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      data: (events) {
        if (events.isEmpty) return const Center(child: Text('Tidak ada event'));

        return RefreshIndicator(
          onRefresh: () => ref.read(eventsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = events[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/events/${e.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: e.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 140,
                            color: AppColors.background,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 140,
                            color: AppColors.background,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(DateFormat('d MMM yyyy').format(e.eventDate),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                            if (e.location != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(e.location!,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}