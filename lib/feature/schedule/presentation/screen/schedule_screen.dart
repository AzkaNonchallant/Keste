import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/schedule/provider/schedule_provider.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';
import '../../data/schedule_repository.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final String? courseId; // opsional, difilter dari CourseDetailScreen
  const ScheduleScreen({super.key, this.courseId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1; // 0 = Senin
    _tabController = TabController(
      length: ScheduleRepository.dayOrder.length,
      vsync: this,
      initialIndex: todayIndex,
    );
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
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ScheduleRepository.dayOrder.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: groupedAsync.when(
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
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final s = items[i];
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        color: AppColors.primary,
                      ),
                      title: Text(s.courseName ?? '-'),
                      subtitle: Text('${s.startTime} - ${s.endTime} • ${s.room ?? '-'}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.push('/schedule/${s.id}/edit');
                          } else if (value == 'delete') {
                            _confirmDelete(context, s.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Hapus')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
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