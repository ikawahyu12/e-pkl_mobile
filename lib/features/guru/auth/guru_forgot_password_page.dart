import 'package:flutter/material.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../../../shared/widgets/epkl_colors.dart';

class GuruForgotPasswordPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruForgotPasswordPage({super.key, required this.repository});

  @override
  State<GuruForgotPasswordPage> createState() => _GuruForgotPasswordPageState();
}

class _GuruForgotPasswordPageState extends State<GuruForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _requestAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
      _requestAccepted = false;
    });

    try {
      await widget.repository.mintaResetPassword(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _requestAccepted = true;
        _message =
            'Jika alamat email terdaftar, instruksi reset kata sandi akan dikirim.';
      });
    } on GuruAuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      appBar: AppBar(
        title: const Text('Lupa Password'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 72,
                      color: EpklColors.biru,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Reset Password Guru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EpklColors.teks,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan email akun Guru. Jika terdaftar, tautan untuk '
                      'membuat password baru akan dikirim ke email tersebut.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EpklColors.teksSekunder,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      key: const ValueKey('guru-reset-email'),
                      controller: _emailController,
                      enabled: !_loading && !_requestAccepted,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => _requestReset(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'nama@email.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email wajib diisi.';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Masukkan alamat email yang valid.';
                        }
                        return null;
                      },
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        _message!,
                        key: const ValueKey('guru-reset-request-message'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _requestAccepted
                              ? const Color(0xFF167747)
                              : const Color(0xFFB42318),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('guru-reset-request-submit'),
                      onPressed:
                          _loading || _requestAccepted ? null : _requestReset,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kirim tautan reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
