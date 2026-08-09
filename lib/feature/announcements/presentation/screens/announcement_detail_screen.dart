import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/provider/supabase_provider.dart';

import '../../providers/announcement_provider.dart';
import '../../../../data/models/announcement_model.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  final String announcementId;
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementAsync = ref.watch(announcementByIdProvider(announcementId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/announcements/$announcementId/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ]
            : null,
      ),
      body: announcementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (a) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(a.publishedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(a.content, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pengumuman?'),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              final ok = await ref
                  .read(announcementFormControllerProvider.notifier)
                  .delete(announcementId);
              if (ok && context.mounted) context.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Form terpisah untuk tambah/edit — hanya dipakai admin
class AnnouncementFormScreen extends ConsumerStatefulWidget {
  final String? announcementId;
  const AnnouncementFormScreen({super.key, this.announcementId});

  @override
  ConsumerState<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends ConsumerState<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AnnouncementType _type = AnnouncementType.academic;

  @override
  void initState() {
    super.initState();
    if (widget.announcementId != null) {
      final existing = ref.read(announcementByIdProvider(widget.announcementId!)).value;
      if (existing != null) {
        _titleController.text = existing.title;
        _contentController.text = existing.content;
        _type = existing.type;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(announcementFormControllerProvider);
    final isEdit = widget.announcementId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Pengumuman' : 'Buat Pengumuman')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AnnouncementType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: const [
                  DropdownMenuItem(value: AnnouncementType.academic, child: Text('Akademik')),
                  DropdownMenuItem(value: AnnouncementType.holiday, child: Text('Libur')),
                  DropdownMenuItem(
                      value: AnnouncementType.scheduleChange, child: Text('Perubahan Jadwal')),
                  DropdownMenuItem(
                      value: AnnouncementType.administration, child: Text('Administrasi')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
                maxLines: 6,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: formState.isLoading ? null : _submit,
                child: formState.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEdit ? 'Simpan Perubahan' : 'Terbitkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(supabaseProvider).auth.currentUser!.id;
    final announcement = AnnouncementModel(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _type,
      createdBy: userId,
      publishedAt: DateTime.now(),
    );

    final ok = await ref
        .read(announcementFormControllerProvider.notifier)
        .save(announcement, existingId: widget.announcementId);

    if (ok && mounted) context.pop();
  }
}