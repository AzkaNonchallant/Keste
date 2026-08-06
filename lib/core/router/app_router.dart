// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:go_router/go_router.dart';
// // // import 'package:keste/core/provider/supabase_provider.dart';

// // import '../../feature/auth/presentation/screens/login_screen.dart';
// // // // import '../../features/auth/presentation/screens/register_screen.dart';
// // // // import '../../features/auth/presentation/screens/reset_password_screen.dart';
// // // // import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
// // // // import '../../features/profile/presentation/screens/profile_screen.dart';
// // // // import '../../features/courses/presentation/screens/course_list_screen.dart';
// // // // import '../../features/courses/presentation/screens/course_detail_screen.dart';
// // // // import '../../features/schedule/presentation/screens/schedule_screen.dart';
// // // // import '../../features/assignments/presentation/screens/assignment_list_screen.dart';
// // // // import '../../features/assignments/presentation/screens/assignment_detail_screen.dart';
// // // // import '../../features/materials/presentation/screens/material_list_screen.dart';
// // // // import '../../features/grades/presentation/screens/grade_screen.dart';
// // // // import '../../features/todos/presentation/screens/todo_screen.dart';
// // // // import '../../features/announcements/presentation/screens/announcement_list_screen.dart';
// // // // import '../../features/events/presentation/screens/event_list_screen.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   final supabase = ref.watch(supabaseProvider);

//   return GoRouter(
//     initialLocation: '/dashboard',
//     redirect: (context, state) {
//       final isLoggedIn = supabase.auth.currentSession != null;
//       final isAuthRoute = state.matchedLocation.startsWith('/login') ||
//           state.matchedLocation.startsWith('/register') ||
//           state.matchedLocation.startsWith('/reset-password');

//       if (!isLoggedIn && !isAuthRoute) return '/login';
//       if (isLoggedIn && isAuthRoute) return '/dashboard';
//       return null;
//     },
//     routes: [
//       GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
//       GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
//       GoRoute(path: '/reset-password', builder: (c, s) => const ResetPasswordScreen()),

//       GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
//       GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),

//       GoRoute(
//         path: '/courses',
//         builder: (c, s) => const CourseListScreen(),
//         routes: [
//           GoRoute(
//             path: ':courseId',
//             builder: (c, s) => CourseDetailScreen(
//               courseId: s.pathParameters['courseId']!,
//             ),
//           ),
//         ],
//       ),

//       GoRoute(path: '/schedule', builder: (c, s) => const ScheduleScreen()),

//       GoRoute(
//         path: '/assignments',
//         builder: (c, s) => const AssignmentListScreen(),
//         routes: [
//           GoRoute(
//             path: ':assignmentId',
//             builder: (c, s) => AssignmentDetailScreen(
//               assignmentId: s.pathParameters['assignmentId']!,
//             ),
//           ),
//         ],
//       ),

//       GoRoute(path: '/materials', builder: (c, s) => const MaterialListScreen()),
//       GoRoute(path: '/grades', builder: (c, s) => const GradeScreen()),
//       GoRoute(path: '/todos', builder: (c, s) => const TodoScreen()),
//       GoRoute(path: '/announcements', builder: (c, s) => const AnnouncementListScreen()),
//       GoRoute(path: '/events', builder: (c, s) => const EventListScreen()),
//     ],
//   );
// });