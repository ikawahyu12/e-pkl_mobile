import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/profil_guru_model.dart';
import '../../../data/repositories/guru_auth_repository_api.dart';
import '../../../data/repositories/profil_guru_repository.dart';
import '../../../data/repositories/profil_guru_repository_api.dart';
import '../../../shared/widgets/epkl_widgets.dart';

/// Halaman edit profil guru.
/// - [profil]: data awal. Kalau null, halaman memuatnya sendiri dari repository.
/// - [repository]: kalau null, memakai ProfilGuruRepositoryApi.
/// Saat berhasil menyimpan, halaman menutup dan mengembalikan ProfilGuru terbaru.
class EditProfilGuruPage extends StatefulWidget {
  final ProfilGuru? profil;
  final ProfilGuruRepository? repository;

  const EditProfilGuruPage({super.key, this.profil, this.repository});

  @override
  State<EditProfilGuruPage> createState() => _EditProfilGuruPageState();
}

class _EditProfilGuruPageState extends State<EditProfilGuruPage> {
  static const _biru = Color(0xFF2F6FED);
  static const _biruMuda = Color(0xFF6CB8FF);
  static const _garis = Color(0xFFE6E9EE);
  static const _isiField = Color(0xFFF8F9FB);
  static const _maksFoto = 2 * 1024 * 1024; // 2 MB, sama dengan batas backend

  late final ProfilGuruRepository _repo;
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _emailAktifCtrl = TextEditingController();
  final _emailBaruCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();

  ProfilGuru? _profil;
  bool _memuat = false;
  bool _menyimpan = false;
  bool _mengirimEmail = false;
  String? _errorMuat;

  XFile? _foto;
  Uint8List? _fotoBytes;
  String? _fotoNama;

  @override
  void initState() {
    super.initState();
    _repo =
        widget.repository ??
        ProfilGuruRepositoryApi(authRepository: GuruAuthRepositoryApi());
    _profil = widget.profil;
    if (_profil != null) {
      _isi(_profil!);
    } else {
      _muat();
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nipCtrl.dispose();
    _emailAktifCtrl.dispose();
    _emailBaruCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  void _isi(ProfilGuru p) {
    _namaCtrl.text = p.nama;
    _nipCtrl.text = p.nip;
    _emailAktifCtrl.text = p.email ?? '';
    _hpCtrl.text = p.noHp ?? '';
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _errorMuat = null;
    });
    try {
      final p = await _repo.ambilProfil();
      if (!mounted) return;
      setState(() {
        _profil = p;
        _memuat = false;
      });
      _isi(p);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
        _errorMuat = _pesan(e);
      });
    }
  }

  String _pesan(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _snack(String teks, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(teks),
          backgroundColor: error ? Colors.red.shade600 : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String? _nullKalauKosong(String teks) {
    final t = teks.trim();
    return t.isEmpty ? null : t;
  }

  String? _validasiNama(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
    if (v.trim().length > 120) return 'Nama maksimal 120 karakter';
    return null;
  }

  String? _validasiEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
    return ok ? null : 'Format email tidak valid';
  }

  String? _validasiHp(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = RegExp(r'^[0-9+\s-]{8,20}$').hasMatch(t);
    return ok ? null : 'Nomor HP tidak valid';
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
      if (bytes.lengthInBytes > _maksFoto) {
        if (mounted) _snack('Ukuran foto maksimal 2 MB.');
        return;
      }
      if (!mounted) return;
      setState(() {
        _foto = picked;
        _fotoBytes = bytes;
        _fotoNama = picked.name;
      });
    } catch (_) {
      if (mounted) _snack('Foto tidak dapat dibuka. Coba lagi.');
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
    final email = _emailBaruCtrl.text.trim();
    final error = _validasiEmail(email);
    if (error != null || email.isEmpty) {
      _snack(error ?? 'Masukkan email baru terlebih dahulu.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _mengirimEmail = true);
    try {
      await _repo.ajukanPerubahanEmail(email);
      if (!mounted) return;
      _snack('Tautan verifikasi dikirim. Email aktif belum berubah.');
      _emailBaruCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      _snack(_pesan(e), error: true);
    } finally {
      if (mounted) setState(() => _mengirimEmail = false);
    }
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);
    try {
      final hasil = await _repo.ubahProfil(
        nama: _namaCtrl.text.trim(),
        noHp: _nullKalauKosong(_hpCtrl.text),
        fotoBytes: _fotoBytes,
        fotoNama: _fotoNama,
        foto: _foto,
      );
      if (!mounted) return;
      _snack('Profil berhasil diperbarui.');
      Navigator.of(context).pop(hasil);
    } catch (e) {
      if (!mounted) return;
      final teksError = _pesan(e).trim();
      _snack(
        teksError.isEmpty ? 'Gagal menyimpan profil. Coba lagi.' : teksError,
        error: true,
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  // ---------- tampilan ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const EpklGradientAppBar(judul: 'Edit Profil'),
      body: SafeArea(child: _isiHalaman()),
    );
  }

  Widget _isiHalaman() {
    if (_memuat) return const Center(child: CircularProgressIndicator());
    if (_errorMuat != null || _profil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMuat ?? 'Data profil tidak tersedia.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _muat, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _kartuFoto(),
          const SizedBox(height: 22),
          const Text(
            'Data diri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _namaCtrl,
            enabled: !_menyimpan,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _dekor('Nama lengkap & gelar', Icons.person_outline),
            validator: _validasiNama,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nipCtrl,
            enabled: false,
            decoration: _dekor(
              'NIP',
              Icons.badge_outlined,
              helper: 'NIP tidak dapat diubah',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailAktifCtrl,
            enabled: false,
            decoration: _dekor(
              'Email aktif',
              Icons.mail_outline,
              helper: 'Email hanya berubah setelah verifikasi.',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailBaruCtrl,
            enabled: !_menyimpan && !_mengirimEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _dekor(
              'Email baru (verifikasi)',
              Icons.mark_email_unread_outlined,
            ),
            validator: _validasiEmail,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: (_menyimpan || _mengirimEmail)
                  ? null
                  : _kirimTautanEmail,
              icon: _mengirimEmail
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.mark_email_read_outlined, size: 18),
              label: const Text('Kirim tautan verifikasi'),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _hpCtrl,
            enabled: !_menyimpan,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: _dekor('Nomor HP', Icons.phone_outlined),
            validator: _validasiHp,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _menyimpan ? null : _simpan,
              style: FilledButton.styleFrom(
                backgroundColor: _biru,
                disabledBackgroundColor: _biru.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _menyimpan
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu biru bergradasi, gayanya sama dengan header halaman Profil Akun.
  Widget _kartuFoto() {
    final p = _profil!;
    ImageProvider? gambar;
    if (_fotoBytes != null) {
      gambar = MemoryImage(_fotoBytes!);
    } else if (p.fotoUrl != null && p.fotoUrl!.isNotEmpty) {
      gambar = NetworkImage(p.fotoUrl!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_biru, _biruMuda],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _menyimpan ? null : _tampilkanPilihanFoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  backgroundImage: gambar,
                  onBackgroundImageError: gambar is NetworkImage
                      ? (_, _) {}
                      : null,
                  child: gambar == null
                      ? Text(
                          p.inisial,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: _biru,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _biru, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: _biru,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fotoBytes != null
                ? 'Foto baru siap disimpan'
                : 'Ketuk foto untuk mengubah',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  InputDecoration _dekor(String label, IconData ikon, {String? helper}) {
    OutlineInputBorder batas(Color warna, [double lebar = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: warna, width: lebar),
        );

    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(ikon, size: 20),
      filled: true,
      fillColor: _isiField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: batas(_garis),
      enabledBorder: batas(_garis),
      disabledBorder: batas(_garis),
      focusedBorder: batas(_biru, 1.6),
      errorBorder: batas(const Color(0xFFE0245E)),
      focusedErrorBorder: batas(const Color(0xFFE0245E), 1.6),
    );
  }
}