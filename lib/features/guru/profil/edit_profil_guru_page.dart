import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  Uint8List? _fotoBytes;
  String? _fotoNama;

  Widget _inisialFoto() => Text(
    widget.profil.inisial,
    style: const TextStyle(
      color: Color(0xFF1677FF),
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
  );

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
        fotoBytes: _fotoBytes,
        fotoNama: _fotoNama,
      );
      if (!mounted) return;
      Navigator.pop(context, hasil);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', '').trim().isEmpty
                ? 'Gagal menyimpan profil. Coba lagi.'
                : error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto maksimal 2 MB.')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        _fotoNama = picked.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto tidak dapat dibuka. Coba lagi.')),
      );
    }
  }

  Future<void> _tampilkanPilihanFoto() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pilihFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dengan kamera'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pilihFoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
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
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFFDCEBFF),
                      child: ClipOval(
                        child: SizedBox(
                          width: 104,
                          height: 104,
                          child: _fotoBytes != null
                              ? Image.memory(
                                  _fotoBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Center(child: _inisialFoto()),
                                )
                              : widget.profil.fotoUrl?.isNotEmpty == true
                              ? Image.network(
                                  widget.profil.fotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Center(child: _inisialFoto()),
                                )
                              : Center(child: _inisialFoto()),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: IconButton.filled(
                        onPressed: _menyimpan ? null : _tampilkanPilihanFoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        tooltip: 'Ganti foto profil',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
