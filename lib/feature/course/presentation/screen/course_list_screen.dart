import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import 'package:keste/feature/course/provider/course_provider.dart';
import 'package:keste/shared/widget/bottom_navbar.dart';
import '../../../../data/models/course_model.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _avatarColors = [
    Color(0xFFB39DDB), Color(0xFF80D8FF), Color(0xFFFFAB91),
    Color(0xFFA5D6A7), Color(0xFFFFE082), Color(0xFFF48FB1),
  ];

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  profileAsync.when(
                    data: (profile) => CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: profile?.photoUrl != null
                          ? CachedNetworkImageProvider(profile!.photoUrl!)
                          : null,
                      child: profile?.photoUrl == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    loading: () => const CircleAvatar(radius: 20),
                    error: (_, __) => const CircleAvatar(radius: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mata Kuliah',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ===== Search bar =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari mata kuliah...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== List mata kuliah =====
            Expanded(
              child: coursesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                data: (courses) {
                  final filtered = _query.isEmpty
                      ? courses
                      : courses.where((c) => c.name.toLowerCase().contains(_query)).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Belum ada mata kuliah'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(coursesProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final course = filtered[i];
                        final avatarColor = _avatarColors[i % _avatarColors.length];
                        return _CourseCard(
                          course: course,
                          avatarColor: avatarColor,
                          onTap: () => context.push('/courses/${course.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textPrimary,
        onPressed: () => context.push('/courses/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final Color avatarColor;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.avatarColor,
    required this.onTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1C1C1E), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor,
                child: Text(
                  _initials(course.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                    ),
                    const SizedBox(height: 8),
                    if (course.lecturer != null && course.lecturer!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 15, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              course.lecturer!,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (course.room != null && course.room!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              course.room!,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}