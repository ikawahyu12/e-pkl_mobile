import 'package:flutter/material.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../../../shared/widgets/epkl_colors.dart';

class GuruRegisterPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruRegisterPage({super.key, required this.repository});

  @override
  State<GuruRegisterPage> createState() => _GuruRegisterPageState();
}

class _GuruRegisterPageState extends State<GuruRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _nipController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _loading = false;
  bool _resending = false;
  bool _registrationAccepted = false;
  bool _messageIsError = false;
  String? _message;

  @override
  void dispose() {
    _nipController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  String? _validasiNip(String? value) {
    final nip = value?.trim() ?? '';
    if (nip.isEmpty) return 'NIP wajib diisi.';
    if (nip.length > 30) return 'NIP maksimal 30 karakter.';
    return null;
  }

  String? _validasiNama(String? value) {
    final nama = value?.trim() ?? '';
    if (nama.isEmpty) return 'Nama lengkap wajib diisi.';
    if (nama.length > 120) return 'Nama maksimal 120 karakter.';
    return null;
  }

  String? _validasiEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi.';
    if (email.length > 150 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  String? _validasiPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi.';
    if (value.length < 12) return 'Password minimal 12 karakter.';
    return null;
  }

  String? _validasiKonfirmasi(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak cocok.';
    }
    return null;
  }

  Future<void> _daftar() async {
    if (_loading ||
        _resending ||
        _registrationAccepted ||
        !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await widget.repository.daftarGuru(
        nip: _nipController.text,
        namaLengkap: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _konfirmasiController.text,
      );
      if (!mounted) return;
      setState(() {
        _registrationAccepted = true;
        _messageIsError = false;
        _message =
            'Jika NIP dan nama cocok dengan data Guru dan belum terhubung ke akun lain, instruksi verifikasi akan dikirim ke email. Setelah verifikasi, masuk menggunakan NIP atau email dan password.';
      });
    } on GuruAuthException catch (error) {
      if (mounted) {
        setState(() {
          _messageIsError = true;
          _message = error.message;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kirimUlangVerifikasi() async {
    if (_loading ||
        _resending ||
        !(_emailFieldKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _resending = true;
      _message = null;
    });

    try {
      await widget.repository.kirimUlangVerifikasiGuru(
        email: _emailController.text,
      );
      if (!mounted) return;
      setState(() {
        _messageIsError = false;
        _message =
            'Jika akun menunggu verifikasi, tautan baru akan dikirim ke email.';
      });
    } on GuruAuthException catch (error) {
      if (mounted) {
        setState(() {
          _messageIsError = true;
          _message = error.message;
        });
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Registrasi Guru')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Gunakan NIP dan nama yang terdaftar pada data Guru sekolah.',
                      style: TextStyle(
                        color: EpklColors.teks,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('guru-register-nip'),
                      controller: _nipController,
                      enabled: !_loading,
                      maxLength: 30,
                      textInputAction: TextInputAction.next,
                      validator: _validasiNip,
                      decoration: const InputDecoration(
                        labelText: 'NIP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('guru-register-name'),
                      controller: _namaController,
                      enabled: !_loading,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: _validasiNama,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap sesuai data Guru',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: _emailFieldKey,
                      controller: _emailController,
                      enabled: !_loading && !_resending,
                      maxLength: 150,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validasiEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email aktif',
                        hintText: 'nama@email.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('guru-register-password'),
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: _validasiPassword,
                      decoration: const InputDecoration(
                        labelText: 'Password (minimal 12 karakter)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('guru-register-confirm-password'),
                      controller: _konfirmasiController,
                      enabled: !_loading,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: _validasiKonfirmasi,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message!,
                        key: const ValueKey('guru-register-message'),
                        style: TextStyle(
                          color: _messageIsError
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('guru-register-submit'),
                      onPressed: _loading || _resending || _registrationAccepted
                          ? null
                          : _daftar,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Daftar dan kirim verifikasi'),
                    ),
                    TextButton(
                      key: const ValueKey('guru-register-resend'),
                      onPressed: _loading || _resending
                          ? null
                          : _kirimUlangVerifikasi,
                      child: _resending
                          ? const Text('Mengirim ulang...')
                          : const Text(
                              'Sudah mendaftar? Kirim ulang verifikasi',
                            ),
                    ),
                    TextButton(
                      onPressed: _loading || _resending
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Sudah punya akun? Masuk'),
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
