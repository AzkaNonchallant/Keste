import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/schedule/provider/schedule_provider.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';
import '../../data/schedule_repository.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final String? courseId;
  const ScheduleScreen({super.key, this.courseId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _accentColor = Color(0xFFB39DDB); // ungu muda aksen
  static const _chipUnselected = Color(0xFFF1EFFB);

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1;
    _tabController = TabController(
      length: ScheduleRepository.dayOrder.length,
      vsync: this,
      initialIndex: todayIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || !_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(schedulesByDayProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header custom =====
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push('/profile'),
                  ),
                  const Expanded(
                    child: Text(
                      'Jadwal Kuliah',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ===== Pill tab bar =====
            SizedBox(
              height: 52,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                tabs: List.generate(ScheduleRepository.dayOrder.length, (i) {
                  final day = ScheduleRepository.dayOrder[i];
                  final isSelected = _tabController.index == i;
                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : _chipUnselected,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),

            // ===== List jadwal per hari =====
            Expanded(
              child: groupedAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                data: (grouped) => TabBarView(
                  controller: _tabController,
                  children: ScheduleRepository.dayOrder.map((day) {
                    final items = grouped[day] ?? [];
                    if (items.isEmpty) {
                      return const Center(child: Text('Tidak ada jadwal'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(schedulesByDayProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final s = items[i];
                          return _ScheduleCard(
                            startTime: s.startTime,
                            endTime: s.endTime,
                            title: s.courseName ?? '-',
                            location: s.room ?? '-',
                            onEdit: () => context.push('/schedule/${s.id}/edit'),
                            onDelete: () => _confirmDelete(context, s.id),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C1C1E),
        onPressed: () => context.push('/schedule/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }

  void _confirmDelete(BuildContext context, String scheduleId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              await ref.read(scheduleFormControllerProvider.notifier).delete(scheduleId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Card jadwal: aksen garis ungu di kiri, waktu di atas, nama matkul + lokasi di bawah
class _ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String title;
  final String location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFB39DDB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            startTime,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            endTime,
                            style: const TextStyle(fontSize: 13, color: Colors.black45),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18, color: Colors.black38),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}