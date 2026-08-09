import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keste/feature/auth/provider/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_sent)
              const Text('Link reset password telah dikirim ke email kamu.')
            else ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final ok = await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(_emailController.text.trim());
                        if (ok) setState(() => _sent = true);
                      },
                child: const Text('Kirim Link Reset'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}