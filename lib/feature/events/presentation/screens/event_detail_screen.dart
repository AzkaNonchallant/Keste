import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:keste/core/provider/supabase_provider.dart';

import '../../providers/event_provider.dart';
import '../../../../data/models/event_model.dart';
import '../../../announcements/providers/announcement_provider.dart' show isAdminProvider;

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/events/$eventId/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ]
            : null,
      ),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (e) => ListView(
          children: [
            if (e.imageUrl != null)
              CachedNetworkImage(
                imageUrl: e.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(DateFormat('EEEE, d MMM yyyy').format(e.eventDate)),
                    ],
                  ),
                  if (e.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(e.location!),
                      ],
                    ),
                  ],
                  if (e.description != null && e.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(e.description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Event?'),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              final ok = await ref.read(eventFormControllerProvider.notifier).delete(eventId);
              if (ok && context.mounted) context.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Form tambah/edit event — khusus admin
class EventFormScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const EventFormScreen({super.key, this.eventId});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  PlatformFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      final existing = ref.read(eventByIdProvider(widget.eventId!)).value;
      if (existing != null) {
        _titleController.text = existing.title;
        _descController.text = existing.description ?? '';
        _locationController.text = existing.location ?? '';
        _eventDate = existing.eventDate;
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedImage = result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(eventFormControllerProvider);
    final isEdit = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Event' : 'Buat Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _pickedImage != null
                    ? const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 40))
                    : const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 40)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Event'),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Tanggal Event'),
                child: Text(DateFormat('d MMM yyyy').format(_eventDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 4,
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
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(supabaseProvider).auth.currentUser!.id;
    final event = EventModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      location: _locationController.text.trim(),
      eventDate: _eventDate,
      imageUrl: null,
      createdBy: userId,
    );

    final ok = await ref.read(eventFormControllerProvider.notifier).save(
          event,
          existingId: widget.eventId,
          imageFile: _pickedImage?.path != null ? File(_pickedImage!.path!) : null,
          imageFileName: _pickedImage?.name,
        );

    if (ok && mounted) context.pop();
  }
}