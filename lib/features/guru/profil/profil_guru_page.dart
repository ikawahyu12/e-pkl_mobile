import 'package:flutter/material.dart';

import 'edit_profil_guru_page.dart';
import 'ganti_password_page.dart';
import '../../../data/models/profil_guru_model.dart';
import '../../../data/repositories/profil_guru_repository.dart';

const _biru = Color(0xFF1677FF);
const _biruMuda = Color(0xFF6EC1FF);
const _teks = Color(0xFF111827);
const _teksSekunder = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class ProfilGuruPage extends StatefulWidget {
  final ProfilGuruRepository? repository;

  /// Dipanggil setelah logout berhasil (arahkan ke halaman login).
  final VoidCallback? onLogout;

  const ProfilGuruPage({super.key, this.repository, this.onLogout});

  @override
  State<ProfilGuruPage> createState() => _ProfilGuruPageState();
}

class _ProfilGuruPageState extends State<ProfilGuruPage> {
  late final ProfilGuruRepository _repo =
      widget.repository ?? ProfilGuruRepositoryMock();

  ProfilGuru? _profil;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.ambilProfil();
      if (!mounted) return;
      setState(() => _profil = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat profil. Periksa koneksi Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String pesan, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(pesan),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _editProfil() async {
    final hasil = await Navigator.push<ProfilGuru>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilGuruPage(profil: _profil!, repository: _repo),
      ),
    );
    if (hasil != null && mounted) {
      setState(() => _profil = hasil);
      _snack('Profil berhasil diperbarui');
    }
  }

  Future<void> _gantiPassword() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => GantiPasswordPage(repository: _repo)),
    );
    if (berhasil == true && mounted) {
      _snack('Kata sandi berhasil diubah');
    }
  }

  Future<void> _keluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda perlu masuk kembali untuk mengakses akun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar',
                style: TextStyle(color: Color(0xFFE11D48))),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await _repo.logout();
      widget.onLogout?.call();
    } catch (_) {
      _snack('Gagal keluar dari akun. Coba lagi.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil Akun',
          style: TextStyle(
              color: _teks, fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: SafeArea(child: _isi()),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _profil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: _teksSekunder),
              const SizedBox(height: 12),
              Text(_error ?? 'Data tidak tersedia',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _muat, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    final p = _profil!;
    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _KartuProfil(profil: p),
          const SizedBox(height: 20),
          const _JudulSeksi('Informasi akun'),
          _KartuInfo(rows: [
            ('NIP', p.nip),
            ('Sekolah', p.sekolah),
            ('Bimbingan', p.bimbingan),
          ]),
          const SizedBox(height: 20),
          const _JudulSeksi('Pengaturan'),
          Container(
            decoration: _dekorKartu(),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.manage_accounts_outlined,
                  warna: _biru,
                  latar: const Color(0xFFDCEBFF),
                  judul: 'Edit profil',
                  subjudul: 'Perbarui data diri dan identitas',
                  onTap: _editProfil,
                ),
                _MenuItem(
                  icon: Icons.verified_user_outlined,
                  warna: const Color(0xFF16A34A),
                  latar: const Color(0xFFDCF5E3),
                  judul: 'Keamanan akun',
                  subjudul: 'Kata sandi dan perangkat aktif',
                  onTap: _gantiPassword,
                ),
                _MenuItem(
                  icon: Icons.notifications_active_outlined,
                  warna: const Color(0xFFD97706),
                  latar: const Color(0xFFFFF1C2),
                  judul: 'Preferensi notifikasi',
                  subjudul: 'Atur pengingat dan pembaruan',
                  onTap: () => _snack('Fitur ini segera hadir'),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  warna: _teksSekunder,
                  latar: const Color(0xFFF3F4F6),
                  judul: 'Bantuan',
                  subjudul: 'Pusat bantuan dan kontak admin',
                  onTap: () => _snack('Fitur ini segera hadir'),
                  terakhir: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _keluar,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFEECEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFBD0D5)),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Color(0xFFE11D48), size: 20),
                  SizedBox(width: 8),
                  Text('Keluar dari akun',
                      style: TextStyle(
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _dekorKartu() => BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    );

class _KartuProfil extends StatelessWidget {
  final ProfilGuru profil;
  const _KartuProfil({required this.profil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_biru, _biruMuda],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              profil.inisial,
              style: const TextStyle(
                  color: _biru, fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profil.nama,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(profil.peran,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.apartment, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        profil.sekolah,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JudulSeksi extends StatelessWidget {
  final String teks;
  const _JudulSeksi(this.teks);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(teks,
            style: const TextStyle(
                color: _teks, fontWeight: FontWeight.w700, fontSize: 15)),
      );
}

class _KartuInfo extends StatelessWidget {
  final List<(String, String)> rows;
  const _KartuInfo({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _dekorKartu(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(rows[i].$1,
                        style: const TextStyle(
                            color: _teksSekunder, fontSize: 13)),
                  ),
                  Expanded(
                    child: Text(rows[i].$2,
                        style: const TextStyle(
                            color: _teks,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color warna;
  final Color latar;
  final String judul;
  final String subjudul;
  final VoidCallback onTap;
  final bool terakhir;

  const _MenuItem({
    required this.icon,
    required this.warna,
    required this.latar,
    required this.judul,
    required this.subjudul,
    required this.onTap,
    this.terakhir = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: terakhir
              ? null
              : const Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: latar, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: warna),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul,
                      style: const TextStyle(
                          color: _teks,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subjudul,
                      style: const TextStyle(
                          color: _teksSekunder, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _teksSekunder),
          ],
        ),
      ),
    );
  }
}