import 'package:e_pkl/features/guru/agenda/agenda_page.dart';
import 'package:flutter/material.dart';

import '../../../data/models/dashboard_guru_model.dart';
import '../../../data/repositories/dashboard_guru_repository.dart';
import '../../../data/repositories/agenda_repository_api.dart';
import '../../../shared/utils/guru_navigasi.dart';
import '../../../shared/widgets/epkl_widgets.dart';
import '../informasi_jurnal/informasi_jurnal_page.dart';
import '../penilaian/daftar_penilaian.dart';
import '../presensi/buat_presensi.dart';

/// Beranda guru pembimbing: sapaan, ringkasan statistik, menu cepat,
/// dan informasi terbaru.
///
/// Halaman ini hanya isi tab "Beranda". Bottom navigation dipasang oleh shell,
/// yang cukup memberi [onPindahTab] agar pintasan ke tab Siswa / Monitoring /
/// Profil berpindah tab (bukan membuka halaman baru).
class GuruHomePage extends StatefulWidget {
  final DashboardGuruRepository? repository;
  final AgendaRepository? agendaRepository;

  /// Dipanggil saat pintasan menuju sebuah tab (index mengikuti
  /// [GuruTujuan.tab]: Siswa=1, Monitoring=2, Profil=3).
  final GuruPindahTab? onPindahTab;
  final bool tampilkanAppBar;
  final ValueChanged<bool>? onAdaNotifikasiBaru;

  const GuruHomePage({
    super.key,
    this.repository,
    this.agendaRepository,
    this.onPindahTab,
    this.tampilkanAppBar = true,
    this.onAdaNotifikasiBaru,
  });

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
      widget.onAdaNotifikasiBaru?.call(data.adaNotifikasiBaru);
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
      ..showSnackBar(
        SnackBar(content: Text(pesan), behavior: SnackBarBehavior.floating),
      );
  }

  void _buka(GuruTujuan tujuan) {
    GuruNavigasi.buka(context, tujuan, onPindahTab: widget.onPindahTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.tampilkanAppBar
          ? EpklHomeAppBar(
              adaNotifikasiBaru: _data?.adaNotifikasiBaru ?? false,
              onNotifikasi: () => _buka(GuruTujuan.notifikasi),
              onProfil: () => _buka(GuruTujuan.profil),
            )
          : null,
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
              const Icon(
                Icons.error_outline,
                size: 40,
                color: EpklColors.teksSekunder,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Data tidak tersedia',
                textAlign: TextAlign.center,
              ),
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
              label: 'Siswa Bimbingan',
              onTap: () => _buka(GuruTujuan.siswaBimbingan),
            ),
            EpklStatTile(
              icon: Icons.how_to_reg,
              warnaIkon: EpklColors.hijau,
              latarIkon: EpklColors.hijauSoft,
              label: 'Kehadiran',
              onTap: () => _buka(GuruTujuan.monitoring),
            ),
          ),
          const SizedBox(height: 12),
          _barisTile(
            EpklStatTile(
              icon: Icons.description,
              label: 'Jurnal',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InformasiJurnalPage(),
                  ),
                );
              },
            ),
            EpklStatTile(
              icon: Icons.star,
              warnaIkon: EpklColors.kuning,
              latarIkon: EpklColors.kuningSoft,
              label: 'Penilaian',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DaftarPenilaianPage(),
                  ),
                );
              },
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
                  MaterialPageRoute<void>(builder: (_) => BuatPresensiPage()),
                ),
              ),
              EpklMenuCepatItem(
                icon: Icons.description_outlined,
                label: 'Informasi Jurnal',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InformasiJurnalPage(),
                    ),
                  );
                },
              ),
              EpklMenuCepatItem(
                icon: Icons.star_border_rounded,
                label: 'Penilaian',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DaftarPenilaianPage(),
                    ),
                  );
                },
              ),
              EpklMenuCepatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Agenda',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AgendaPage(repository: widget.agendaRepository),
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: EpklColors.gradienUtama,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 28,
            top: -54,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -36,
            bottom: -54,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x26FFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.fromBorderSide(
                          BorderSide(color: Color(0x40FFFFFF)),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        child: Text(
                          'PENDAMPING PKL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Halo,\nGuru Pembimbing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tetap semangat membimbing!',
                      style: TextStyle(
                        color: Color(0xEFFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 78,
                height: 88,
                child: CustomPaint(painter: _SiluetGuruPainter()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SiluetGuruPainter extends CustomPainter {
  const _SiluetGuruPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 78, size.height / 88);

    final aksen = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(const Offset(49, 45), 36, aksen);
    canvas.drawCircle(
      const Offset(68, 15),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );

    final papan = RRect.fromRectAndRadius(
      const Rect.fromLTWH(43, 20, 29, 34),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      papan,
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    canvas.drawRRect(
      papan,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      const Offset(49, 30),
      const Offset(64, 30),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(49, 36),
      const Offset(60, 36),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    final siluet = Paint()..color = const Color(0xFFF4FAFF);
    canvas.drawCircle(const Offset(27, 25), 9, siluet);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(23, 32, 8, 10),
        const Radius.circular(3),
      ),
      siluet,
    );

    final badan = Path()
      ..moveTo(18, 42)
      ..quadraticBezierTo(26, 37, 34, 42)
      ..lineTo(39, 49)
      ..lineTo(34, 55)
      ..lineTo(32, 51)
      ..lineTo(33, 82)
      ..lineTo(14, 82)
      ..lineTo(16, 54)
      ..lineTo(11, 51)
      ..close();
    canvas.drawPath(badan, siluet);

    final lenganMenunjuk = Path()
      ..moveTo(31, 45)
      ..lineTo(39, 39)
      ..lineTo(47, 27)
      ..quadraticBezierTo(49, 24, 52, 27)
      ..lineTo(45, 45)
      ..lineTo(36, 54)
      ..close();
    canvas.drawPath(lenganMenunjuk, siluet);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SiluetGuruPainter oldDelegate) => false;
}
