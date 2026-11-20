import 'package:flutter/material.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../../../shared/widgets/epkl_colors.dart';

class GuruResetPasswordPage extends StatefulWidget {
  final GuruAuthRepository repository;
  final String email;
  final String token;

  const GuruResetPasswordPage({
    super.key,
    required this.repository,
    required this.email,
    required this.token,
  });

  @override
  State<GuruResetPasswordPage> createState() => _GuruResetPasswordPageState();
}

class _GuruResetPasswordPageState extends State<GuruResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _loading = false;
  bool _completed = false;
  String? _message;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await widget.repository.resetPassword(
        email: widget.email,
        token: widget.token,
        passwordBaru: _passwordController.text,
        passwordBaruConfirmation: _confirmationController.text,
      );
      if (!mounted) return;
      setState(() {
        _completed = true;
        _message =
            'Password berhasil diubah. Silakan masuk menggunakan password baru.';
      });
    } on GuruAuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung huruf dan angka.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final linkIsValid = widget.email.isNotEmpty &&
        RegExp(r'^[a-f0-9]{64}$').hasMatch(widget.token);

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      appBar: AppBar(
        title: const Text('Buat Password Baru'),
        backgroundColor: const Color(0xFFF3FAFF),
        foregroundColor: EpklColors.teks,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: linkIsValid
                  ? _buildForm()
                  : const Text(
                      'Tautan reset tidak valid. Minta tautan reset baru dari halaman login.',
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset_rounded,
            size: 68,
            color: EpklColors.biru,
          ),
          const SizedBox(height: 20),
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: EpklColors.teksSekunder),
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('guru-reset-new-password'),
            controller: _passwordController,
            enabled: !_loading && !_completed,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Password baru',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('guru-reset-confirm-password'),
            controller: _confirmationController,
            enabled: !_loading && !_completed,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Konfirmasi password baru',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) => value != _passwordController.text
                ? 'Konfirmasi password tidak cocok.'
                : null,
          ),
          if (_message != null) ...[
            const SizedBox(height: 18),
            Text(
              _message!,
              key: const ValueKey('guru-reset-password-message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _completed
                    ? const Color(0xFF167747)
                    : const Color(0xFFB42318),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('guru-reset-password-submit'),
            onPressed: _loading || _completed ? null : _resetPassword,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan password baru'),
          ),
          if (_completed) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context)
                ..popUntil((route) => route.isFirst),
              child: const Text('Kembali ke login'),
            ),
          ],
        ],
      ),
    );
  }
}
