import 'package:flutter/material.dart';

import '../../../data/models/profil_guru_model.dart';
import '../../../data/repositories/profil_guru_repository.dart';

class EditProfilGuruPage extends StatefulWidget {
  final ProfilGuru profil;
  final ProfilGuruRepository repository;

  const EditProfilGuruPage({
    super.key,
    required this.profil,
    required this.repository,
  });

  @override
  State<EditProfilGuruPage> createState() => _EditProfilGuruPageState();
}

class _EditProfilGuruPageState extends State<EditProfilGuruPage> {
  final _formKey = GlobalKey<FormState>();
  late final _namaC = TextEditingController(text: widget.profil.nama);
  final _emailBaruC = TextEditingController();
  late final _hpC = TextEditingController(text: widget.profil.noHp ?? '');
  bool _menyimpan = false;
  bool _mengirimEmail = false;

  @override
  void dispose() {
    _namaC.dispose();
    _emailBaruC.dispose();
    _hpC.dispose();
    super.dispose();
  }

  String? _validasiNama(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
    if (v.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? _validasiEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null; // opsional
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
    return ok ? null : 'Format email tidak valid';
  }

  String? _validasiHp(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null; // opsional
    final ok = RegExp(r'^(\+62|62|0)8[0-9]{8,12}$').hasMatch(t);
    return ok ? null : 'Nomor HP tidak valid (contoh: 081234567890)';
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);
    try {
      final hasil = await widget.repository.ubahProfil(
        nama: _namaC.text.trim(),
        noHp: _hpC.text.trim().isEmpty ? null : _hpC.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, hasil);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menyimpan profil. Coba lagi.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Future<void> _kirimTautanEmail() async {
    final email = _emailBaruC.text.trim();
    final error = _validasiEmail(email);
    if (error != null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Masukkan email baru terlebih dahulu.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _mengirimEmail = true);
    try {
      await widget.repository.ajukanPerubahanEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tautan verifikasi dikirim. Email aktif belum berubah.',
          ),
        ),
      );
      _emailBaruC.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _mengirimEmail = false);
    }
  }

  InputDecoration _dekor(String label, {String? helper}) => InputDecoration(
    labelText: label,
    helperText: helper,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _namaC,
                textInputAction: TextInputAction.next,
                decoration: _dekor('Nama lengkap & gelar'),
                validator: _validasiNama,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.profil.nip,
                enabled: false,
                decoration: _dekor('NIP', helper: 'NIP tidak dapat diubah'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.profil.email ?? '',
                enabled: false,
                decoration: _dekor(
                  'Email aktif',
                  helper: 'Email hanya berubah setelah verifikasi.',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailBaruC,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _dekor('Email baru (verifikasi)'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _mengirimEmail ? null : _kirimTautanEmail,
                  icon: _mengirimEmail
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mark_email_read_outlined),
                  label: const Text('Kirim tautan verifikasi'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hpC,
                keyboardType: TextInputType.phone,
                decoration: _dekor('Nomor HP'),
                validator: _validasiHp,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _menyimpan ? null : _simpan,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
