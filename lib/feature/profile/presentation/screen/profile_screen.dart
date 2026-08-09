import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';



class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profil tidak ditemukan'));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: profile.photoUrl != null
                      ? CachedNetworkImageProvider(profile.photoUrl!)
                      : null,
                  child: profile.photoUrl == null
                      ? Text(
                          profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 32, color: AppColors.primary),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(profile.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Text(profile.email, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _InfoTile(label: 'NIM', value: profile.nim ?? '-'),
                    const Divider(height: 1),
                    _InfoTile(label: 'Jurusan', value: profile.major ?? '-'),
                    const Divider(height: 1),
                    _InfoTile(label: 'Semester', value: profile.semester?.toString() ?? '-'),
                    const Divider(height: 1),
                    _InfoTile(label: 'Role', value: profile.isAdmin ? 'Admin' : 'Mahasiswa'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15)),
    );
  }
}