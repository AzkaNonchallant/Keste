import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:keste/core/constant/app_color.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';
import 'package:keste/feature/profile/provider/profile_provider.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _majorController = TextEditingController();
  final _semesterController = TextEditingController();
  PlatformFile? _pickedAvatar;
  bool _initialized = false;

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedAvatar = result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final formState = ref.watch(profileFormControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profil tidak ditemukan'));

          if (!_initialized) {
            _nameController.text = profile.fullName;
            _nimController.text = profile.nim ?? '';
            _majorController.text = profile.major ?? '';
            _semesterController.text = profile.semester?.toString() ?? '';
            _initialized = true;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          backgroundImage: _pickedAvatar?.path != null
                              ? FileImage(File(_pickedAvatar!.path!))
                              : (profile.photoUrl != null
                                  ? CachedNetworkImageProvider(profile.photoUrl!) as ImageProvider
                                  : null),
                          child: _pickedAvatar == null && profile.photoUrl == null
                              ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                              : null,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nimController,
                  decoration: const InputDecoration(labelText: 'NIM'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _majorController,
                  decoration: const InputDecoration(labelText: 'Jurusan'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _semesterController,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: formState.isLoading ? null : () => _submit(profile),
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit(profile) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = profile.copyWith(
      fullName: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      major: _majorController.text.trim(),
      semester: int.tryParse(_semesterController.text),
    );

    final ok = await ref.read(profileFormControllerProvider.notifier).save(
          updated,
          avatarFile: _pickedAvatar?.path != null ? File(_pickedAvatar!.path!) : null,
          avatarFileName: _pickedAvatar?.name,
        );

    if (ok && mounted) context.pop();
  }
}