import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/provider/supabase_provider.dart';

import 'package:keste/feature/auth/presentation/screens/login_screen.dart';
import 'package:keste/feature/auth/presentation/screens/register_screen.dart';
import 'package:keste/feature/auth/presentation/screens/reset_password_screen.dart';

import 'package:keste/feature/dashboard/presentation/screen/dashboard_screen.dart';

import 'package:keste/feature/profile/presentation/screen/profile_screen.dart';
import 'package:keste/feature/profile/presentation/screen/edit_profile_screen.dart';

import 'package:keste/feature/course/presentation/screen/course_list_screen.dart';
import 'package:keste/feature/course/presentation/screen/course_form_screen.dart';
import 'package:keste/feature/course/presentation/screen/course_detail_screen.dart';

import 'package:keste/feature/schedule/presentation/screen/schedule_screen.dart';
import 'package:keste/feature/schedule/presentation/screen/schedule_form_screen.dart';

import 'package:keste/feature/assignments/presentation/screens/assignment_list_screen.dart';
import 'package:keste/feature/assignments/presentation/screens/assignment_form_screen.dart';
import 'package:keste/feature/assignments/presentation/screens/assignment_detail_screen.dart';

import 'package:keste/feature/materials/presentation/screens/material_list_screen.dart';
import 'package:keste/feature/materials/presentation/screens/material_upload_screen.dart';

import 'package:keste/feature/grades/presentation/screens/grade_screen.dart';

import 'package:keste/feature/todos/presentation/screens/todo_screen.dart';

import 'package:keste/feature/announcements/presentation/screens/announcement_list_screen.dart';
import 'package:keste/feature/announcements/presentation/screens/announcement_detail_screen.dart';

import 'package:keste/feature/events/presentation/screens/event_list_screen.dart';
import 'package:keste/feature/events/presentation/screens/event_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = supabase.auth.currentSession != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/reset-password');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ===== AUTH =====
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/reset-password', builder: (c, s) => const ResetPasswordScreen()),

      // ===== DASHBOARD =====
      GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),

      // ===== PROFILE =====
      GoRoute(
        path: '/profile',
        builder: (c, s) => const ProfileScreen(),
        routes: [
          GoRoute(path: 'edit', builder: (c, s) => const EditProfileScreen()),
        ],
      ),

      // ===== COURSES =====
      GoRoute(
        path: '/courses',
        builder: (c, s) => const CourseListScreen(),
        routes: [
          GoRoute(path: 'new', builder: (c, s) => const CourseFormScreen()),
          GoRoute(
            path: ':courseId',
            builder: (c, s) => CourseDetailScreen(
              courseId: s.pathParameters['courseId']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => CourseFormScreen(
                  courseId: s.pathParameters['courseId'],
                ),
              ),
            ],
          ),
        ],
      ),

    
      GoRoute(
        path: '/schedule',
        builder: (c, s) => ScheduleScreen(
          courseId: s.uri.queryParameters['courseId'],
        ),
        routes: [
          GoRoute(path: 'new', builder: (c, s) => const ScheduleFormScreen()),
          GoRoute(
            path: ':scheduleId/edit',
            builder: (c, s) => ScheduleFormScreen(
              scheduleId: s.pathParameters['scheduleId'],
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/assignments',
        builder: (c, s) => AssignmentListScreen(
          courseId: s.uri.queryParameters['courseId'],
        ),
        routes: [
          GoRoute(path: 'new', builder: (c, s) => const AssignmentFormScreen()),
          GoRoute(
            path: ':assignmentId',
            builder: (c, s) => AssignmentDetailScreen(
              assignmentId: s.pathParameters['assignmentId']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => AssignmentFormScreen(
                  assignmentId: s.pathParameters['assignmentId'],
                ),
              ),
            ],
          ),
        ],
      ),

      // ===== MATERIALS =====
      GoRoute(
        path: '/materials',
        builder: (c, s) => MaterialListScreen(
          courseId: s.uri.queryParameters['courseId'],
        ),
        routes: [
          GoRoute(
            path: 'upload',
            builder: (c, s) => MaterialUploadScreen(
              courseId: s.uri.queryParameters['courseId'],
            ),
          ),
        ],
      ),

      // ===== GRADES =====
      // /grades = ringkasan semua matkul, /grades?courseId=xxx = form 1 matkul
      GoRoute(
        path: '/grades',
        builder: (c, s) => GradeScreen(
          courseId: s.uri.queryParameters['courseId'],
        ),
      ),

      // ===== TODOS =====
      GoRoute(path: '/todos', builder: (c, s) => const TodoScreen()),

      // ===== ANNOUNCEMENTS =====
      GoRoute(
        path: '/announcements',
        builder: (c, s) => const AnnouncementListScreen(),
        routes: [
          GoRoute(path: 'new', builder: (c, s) => const AnnouncementFormScreen()),
          GoRoute(
            path: ':announcementId',
            builder: (c, s) => AnnouncementDetailScreen(
              announcementId: s.pathParameters['announcementId']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => AnnouncementFormScreen(
                  announcementId: s.pathParameters['announcementId'],
                ),
              ),
            ],
          ),
        ],
      ),

      // ===== EVENTS =====
      GoRoute(
        path: '/events',
        builder: (c, s) => const EventListScreen(),
        routes: [
          GoRoute(path: 'new', builder: (c, s) => const EventFormScreen()),
          GoRoute(
            path: ':eventId',
            builder: (c, s) => EventDetailScreen(
              eventId: s.pathParameters['eventId']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => EventFormScreen(
                  eventId: s.pathParameters['eventId'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});