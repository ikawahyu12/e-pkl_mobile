import 'package:e_pkl/features/guru/presensi/buat_presensi.dart';
import 'package:flutter/material.dart';

import '../../../data/models/dashboard_guru_model.dart';
import '../../../data/repositories/dashboard_guru_repository.dart';
import '../../../shared/utils/guru_navigasi.dart';
import '../../../shared/widgets/epkl_widgets.dart';

/// Beranda guru pembimbing: sapaan, ringkasan statistik, menu cepat,
/// dan informasi terbaru.
///
/// Halaman ini hanya isi tab "Beranda". Bottom navigation dipasang oleh shell,
/// yang cukup memberi [onPindahTab] agar pintasan ke tab Siswa / Monitoring /
/// Profil berpindah tab (bukan membuka halaman baru).
class GuruHomePage extends StatefulWidget {
  final DashboardGuruRepository? repository;

  /// Dipanggil saat pintasan menuju sebuah tab (index mengikuti
  /// [GuruTujuan.tab]: Siswa=1, Monitoring=2, Profil=3).
  final GuruPindahTab? onPindahTab;

  const GuruHomePage({super.key, this.repository, this.onPindahTab});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  late final DashboardGuruRepository _repo =
      widget.repository ?? const DashboardGuruRepositoryMock();

  DashboardGuru? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  /// [senyap] = true untuk pull-to-refresh: data lama tetap tampil.
  Future<void> _muat({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _repo.ambilDashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      if (_data == null) {
        setState(() => _error = 'Gagal memuat beranda. Periksa koneksi Anda.');
      } else {
        _snack('Gagal memperbarui data.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _buka(GuruTujuan tujuan) {
    GuruNavigasi.buka(context, tujuan, onPindahTab: widget.onPindahTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: EpklHomeAppBar(
        adaNotifikasiBaru: _data?.adaNotifikasiBaru ?? false,
        onNotifikasi: () => _buka(GuruTujuan.notifikasi),
        onProfil: () => _buka(GuruTujuan.profil),
      ),
      body: SafeArea(child: _isi()),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = _data;
    if (_error != null || data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 40, color: EpklColors.teksSekunder),
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

    return RefreshIndicator(
      onRefresh: () => _muat(senyap: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _KartuSapaan(),
          const SizedBox(height: 16),
          _barisTile(
            EpklStatTile(
              icon: Icons.person,
              nilai: '${data.jumlahSiswa}',
              label: 'Siswa Bimbingan',
              onTap: () => _buka(GuruTujuan.siswaBimbingan),
            ),
            EpklStatTile(
              icon: Icons.how_to_reg,
              warnaIkon: EpklColors.hijau,
              latarIkon: EpklColors.hijauSoft,
              nilai: '${data.persenKehadiran}%',
              label: 'Kehadiran',
              onTap: () => _buka(GuruTujuan.monitoring),
            ),
          ),
          const SizedBox(height: 12),
          _barisTile(
            EpklStatTile(
              icon: Icons.description,
              nilai: '${data.jumlahJurnal}',
              label: 'Jurnal',
              onTap: () => _buka(GuruTujuan.jurnal),
            ),
            EpklStatTile(
              icon: Icons.star,
              warnaIkon: EpklColors.kuning,
              latarIkon: EpklColors.kuningSoft,
              nilai: '${data.jumlahPenilaian}',
              label: 'Penilaian',
              // Penilaian diisi dari detail siswa, jadi arahkan ke tab Siswa.
              onTap: () => _buka(GuruTujuan.siswaBimbingan),
            ),
          ),
          const SizedBox(height: 20),
          const EpklSectionTitle('Menu Cepat'),
          EpklMenuCepat(
            items: [
              EpklMenuCepatItem(
                icon: Icons.schedule,
                label: 'Absensi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BuatPresensiPage(),
                  ),
                ),
              ),
              EpklMenuCepatItem(
                icon: Icons.description_outlined,
                label: 'Validasi Jurnal',
                onTap: () => _buka(GuruTujuan.jurnal),
              ),
              EpklMenuCepatItem(
                icon: Icons.star_border_rounded,
                label: 'Penilaian',
                onTap: () => _buka(GuruTujuan.siswaBimbingan),
              ),
              EpklMenuCepatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Agenda',
                // Belum ada halaman Agenda di desain.
                onTap: () => _snack('Fitur ini segera hadir'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          EpklInfoTile(
            icon: Icons.campaign,
            judul: 'Informasi Terbaru',
            keterangan: data.infoTerbaru,
            onTap: () => _buka(GuruTujuan.jurnal),
          ),
        ],
      ),
    );
  }

  /// Dua tile sebaris dengan tinggi sama.
  Widget _barisTile(Widget kiri, Widget kanan) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: kiri),
          const SizedBox(width: 12),
          Expanded(child: kanan),
        ],
      ),
    );
  }
}

class _KartuSapaan extends StatelessWidget {
  const _KartuSapaan();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: EpklColors.gradienUtama,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -12,
            child: Icon(
              Icons.account_balance,
              size: 96,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo,\nGuru Pembimbing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tetap semangat membimbing!',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}