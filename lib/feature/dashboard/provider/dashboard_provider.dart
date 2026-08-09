import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/core/provider/supabase_provider.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/event_model.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(supabaseProvider));
});

class DashboardData {
  final List<ScheduleModel> todaySchedule;
  final List<AssignmentModel> upcomingAssignments;
  final List<AnnouncementModel> latestAnnouncements;
  final List<EventModel> upcomingEvents;
  final int totalAssignments;
  final int completedAssignments;

  DashboardData({
    required this.todaySchedule,
    required this.upcomingAssignments,
    required this.latestAnnouncements,
    required this.upcomingEvents,
    required this.totalAssignments,
    required this.completedAssignments,
  });

  double get progress =>
      totalAssignments == 0 ? 0 : completedAssignments / totalAssignments;
}

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser!.id;

  final results = await Future.wait([
    repo.getTodaySchedule(userId),
    repo.getUpcomingAssignments(userId),
    repo.getLatestAnnouncements(),
    repo.getUpcomingEvents(),
    repo.getAssignmentProgress(userId),
  ]);

  final progress = results[4] as ({int total, int completed});

  return DashboardData(
    todaySchedule: results[0] as List<ScheduleModel>,
    upcomingAssignments: results[1] as List<AssignmentModel>,
    latestAnnouncements: results[2] as List<AnnouncementModel>,
    upcomingEvents: results[3] as List<EventModel>,
    totalAssignments: progress.total,
    completedAssignments: progress.completed,
  );
});