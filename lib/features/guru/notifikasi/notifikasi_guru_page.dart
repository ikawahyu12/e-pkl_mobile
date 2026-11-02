import 'package:flutter/material.dart';

import '../../../data/models/notifikasi_model.dart';
import '../../../data/repositories/notifikasi_repository.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../common/guru_ui.dart';
import '../penilaian/hasil_penilaian_page.dart';
import '../siswa_bimbingan/detail_siswa_page.dart';

/// Daftar notifikasi guru pembimbing.
///
/// Navigasi saat notifikasi diketuk:
/// - penilaian  -> HasilPenilaianPage siswa terkait
/// - jurnal     -> [onBukaValidasiJurnal] bila diisi, jika tidak DetailSiswaPage
/// - kehadiran  -> [onBukaMonitoring] bila diisi, jika tidak DetailSiswaPage
///                 (atau pesan "belum tersedia" bila tak ada siswa terkait)
/// - informasi  -> bottom sheet isi lengkap
class NotifikasiGuruPage extends StatefulWidget {
  final NotifikasiRepository? repository;
  final SiswaBimbinganRepository? siswaRepository;
  final PenilaianRepository? penilaianRepository;

  /// Sambungkan ke halaman validasi jurnal / monitoring milik anggota lain.
  final void Function(Notifikasi notifikasi)? onBukaValidasiJurnal;
  final void Function(Notifikasi notifikasi)? onBukaMonitoring;

  const NotifikasiGuruPage({
    super.key,
    this.repository,
    this.siswaRepository,
    this.penilaianRepository,
    this.onBukaValidasiJurnal,
    this.onBukaMonitoring,
  });

  @override
  State<NotifikasiGuruPage> createState() => _NotifikasiGuruPageState();
}

class _NotifikasiGuruPageState extends State<NotifikasiGuruPage> {
  late final NotifikasiRepository _repo =
      widget.repository ?? NotifikasiRepositoryMock();
  late final SiswaBimbinganRepository _siswaRepo =
      widget.siswaRepository ?? SiswaBimbinganRepositoryMock();
  late final PenilaianRepository _nilaiRepo =
      widget.penilaianRepository ?? PenilaianRepositoryMock();

  List<Notifikasi> _data = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat({bool tampilLoading = true}) async {
    if (tampilLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _repo.ambilNotifikasi();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat notifikasi. Periksa koneksi Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _tandaiSemua() async {
    final lama = _data;
    setState(() => _data = _data.map((n) => n.copyWith(dibaca: true)).toList());
    try {
      await _repo.tandaiSemuaDibaca();
    } catch (_) {
      if (!mounted) return;
      setState(() => _data = lama);
      tampilkanSnack(
        context,
        'Gagal menandai notifikasi. Coba lagi.',
        error: true,
      );
    }
  }

  void _buka(Notifikasi n) {
    if (!n.dibaca) {
      setState(() {
        _data = _data
            .map((x) => x.id == n.id ? x.copyWith(dibaca: true) : x)
            .toList();
      });
      _repo.tandaiDibaca(n.id).catchError((_) {});
    }

    switch (n.tipe) {
      case TipeNotifikasi.penilaian:
        if (n.siswaId != null) {
          _push(
            HasilPenilaianPage(
              siswaId: n.siswaId!,
              siswaRepository: _siswaRepo,
              penilaianRepository: _nilaiRepo,
            ),
          );
        }
      case TipeNotifikasi.jurnal:
        if (widget.onBukaValidasiJurnal != null) {
          widget.onBukaValidasiJurnal!(n);
        } else {
          _bukaDetailAtauPesan(n);
        }
      case TipeNotifikasi.kehadiran:
        if (widget.onBukaMonitoring != null) {
          widget.onBukaMonitoring!(n);
        } else {
          _bukaDetailAtauPesan(n);
        }
      case TipeNotifikasi.informasi:
        _tampilInfo(n);
    }
  }

  void _bukaDetailAtauPesan(Notifikasi n) {
    if (n.siswaId != null) {
      _push(
        DetailSiswaPage(
          siswaId: n.siswaId!,
          siswaRepository: _siswaRepo,
          penilaianRepository: _nilaiRepo,
        ),
      );
    } else {
      tampilkanSnack(context, 'Halaman terkait belum tersedia.');
    }
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _tampilInfo(Notifikasi n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kTeks,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                n.labelWaktu,
                style: const TextStyle(fontSize: 12, color: kTeksSekunder),
              ),
              const SizedBox(height: 12),
              Text(
                n.isi,
                style: const TextStyle(fontSize: 14, height: 1.5, color: kTeks),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adaBaru = _data.any((n) => !n.dibaca);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              _header(adaBaru),
              const Divider(height: 1, color: kBorder),
              Expanded(child: _isi()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool adaBaru) {
    final pad = hPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad - 6, 12),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: kBorder),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => Navigator.maybePop(context),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 26,
                    color: kTeks,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          const Expanded(
            child: Text(
              'Notifikasi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTeks,
              ),
            ),
          ),
          TextButton(
            onPressed: adaBaru ? _tandaiSemua : null,
            child: const Text(
              'Tandai dibaca',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _isi() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return StatePesan(
        icon: Icons.cloud_off_rounded,
        pesan: _error!,
        aksiLabel: 'Coba lagi',
        onAksi: () => _muat(),
      );
    }
    if (_data.isEmpty) {
      return const StatePesan(
        icon: Icons.notifications_none_rounded,
        pesan: 'Belum ada notifikasi.',
      );
    }

    final hariIni = _data.where((n) => n.hariIni).toList();
    final sebelumnya = _data.where((n) => !n.hariIni).toList();
    final baru = hariIni.where((n) => !n.dibaca).length;
    final pad = hPadding(context);

    return RefreshIndicator(
      onRefresh: () => _muat(tampilLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        children: [
          if (hariIni.isNotEmpty) ...[
            _JudulSeksi(
              judul: 'Hari ini',
              badge: baru > 0 ? '$baru baru' : null,
            ),
            const SizedBox(height: 12),
            ...hariIni.map(_kartu),
          ],
          if (sebelumnya.isNotEmpty) ...[
            if (hariIni.isNotEmpty) const SizedBox(height: 8),
            const _JudulSeksi(judul: 'Sebelumnya'),
            const SizedBox(height: 12),
            ...sebelumnya.map(_kartu),
          ],
        ],
      ),
    );
  }

  Widget _kartu(Notifikasi n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _KartuNotifikasi(notifikasi: n, onTap: () => _buka(n)),
    );
  }
}

class _JudulSeksi extends StatelessWidget {
  final String judul;
  final String? badge;

  const _JudulSeksi({required this.judul, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            judul,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kTeks,
            ),
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDDEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0369A1),
              ),
            ),
          ),
      ],
    );
  }
}

class _KartuNotifikasi extends StatelessWidget {
  final Notifikasi notifikasi;
  final VoidCallback onTap;

  const _KartuNotifikasi({required this.notifikasi, required this.onTap});

  (IconData, Color, Color) get _ikon {
    switch (notifikasi.tipe) {
      case TipeNotifikasi.jurnal:
        return (
          Icons.assignment_turned_in_outlined,
          const Color(0xFFDCEBFF),
          kBiru,
        );
      case TipeNotifikasi.kehadiran:
        return (
          Icons.how_to_reg_outlined,
          const Color(0xFFD7F5E3),
          const Color(0xFF16A34A),
        );
      case TipeNotifikasi.penilaian:
        return (
          Icons.star_outline_rounded,
          const Color(0xFFFFEFC2),
          const Color(0xFFF59E0B),
        );
      case TipeNotifikasi.informasi:
        return (
          Icons.campaign_outlined,
          const Color(0xFFF1F3F6),
          kTeksSekunder,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final belum = !notifikasi.dibaca;
    final (ikon, bgIkon, warnaIkon) = _ikon;

    return Material(
      color: belum ? const Color(0xFFEAF4FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: belum ? const Color(0xFFBFDDFF) : kBorder),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgIkon,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(ikon, color: warnaIkon, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notifikasi.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kTeks,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notifikasi.labelWaktu,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: belum
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: belum ? kBiru : kTeksSekunder,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notifikasi.isi,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: kTeksSekunder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (belum)
              Positioned(
                top: 10,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kBiru,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
