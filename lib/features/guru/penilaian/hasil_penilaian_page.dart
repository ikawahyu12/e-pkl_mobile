import 'package:flutter/material.dart';

import '../../../data/models/penilaian_model.dart';
import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../../../shared/utils/format_waktu.dart';
import '../common/guru_ui.dart';

/// Menampilkan hasil penilaian + status penyimpanan.
/// Cukup menerima [siswaId] (mis. dari notifikasi); [siswa] dan [penilaian]
/// opsional untuk melewati proses loading bila datanya sudah ada.
class HasilPenilaianPage extends StatefulWidget {
  final String siswaId;
  final SiswaBimbingan? siswa;
  final Penilaian? penilaian;

  /// true bila halaman dibuka tepat setelah menekan "Simpan Nilai".
  final bool baruDisimpan;
  final SiswaBimbinganRepository? siswaRepository;
  final PenilaianRepository? penilaianRepository;

  const HasilPenilaianPage({
    super.key,
    required this.siswaId,
    this.siswa,
    this.penilaian,
    this.baruDisimpan = false,
    this.siswaRepository,
    this.penilaianRepository,
  });

  @override
  State<HasilPenilaianPage> createState() => _HasilPenilaianPageState();
}

class _HasilPenilaianPageState extends State<HasilPenilaianPage> {
  late final SiswaBimbinganRepository _siswaRepo =
      widget.siswaRepository ?? SiswaBimbinganRepositoryMock();
  late final PenilaianRepository _nilaiRepo =
      widget.penilaianRepository ?? PenilaianRepositoryMock();

  SiswaBimbingan? _siswa;
  Penilaian? _nilai;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _siswa = widget.siswa;
    _nilai = widget.penilaian;
    if (_siswa != null && _nilai != null) {
      _loading = false;
    } else {
      _muat();
    }
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final siswa = _siswa ?? await _siswaRepo.ambilDetail(widget.siswaId);
      final nilai = _nilai ?? await _nilaiRepo.ambilPenilaian(widget.siswaId);
      if (!mounted) return;
      setState(() {
        _siswa = siswa;
        _nilai = nilai;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Gagal memuat hasil penilaian. Periksa koneksi Anda.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLatarAbu,
      appBar: const GradientAppBar(title: 'Hasil Penilaian'),
      body: SafeArea(child: _isi()),
    );
  }

  Widget _isi() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return StatePesan(
        icon: Icons.cloud_off_rounded,
        pesan: _error!,
        aksiLabel: 'Coba lagi',
        onAksi: _muat,
      );
    }
    final siswa = _siswa;
    final n = _nilai;
    if (siswa == null) {
      return const StatePesan(
        icon: Icons.person_off_outlined,
        pesan: 'Data siswa tidak ditemukan.',
      );
    }
    if (n == null) {
      return const StatePesan(
        icon: Icons.star_outline_rounded,
        pesan: 'Siswa ini belum memiliki penilaian.',
      );
    }

    final pad = hPadding(context);
    return ResponsiveCenter(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BannerStatus(
              baruDisimpan: widget.baruDisimpan,
              waktu: n.disimpanPada,
            ),
            const SizedBox(height: 16),
            RingkasanSiswaCard(siswa: siswa),
            const SizedBox(height: 16),
            KartuPutih(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aspek Penilaian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTeks,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < Penilaian.namaAspek.length; i++)
                    _BarisNilai(
                      label: Penilaian.namaAspek[i],
                      nilai: i < n.nilai.length ? n.nilai[i] : 0,
                      terakhir: i == Penilaian.namaAspek.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RataRataCard(rata: n.rataRata, predikat: n.predikat),
            const SizedBox(height: 16),
            KartuPutih(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan Penilaian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTeks,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    n.catatan.isEmpty ? 'Tidak ada catatan.' : n.catatan,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: n.catatan.isEmpty ? kTeksSekunder : kTeks,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Selesai',
              onPressed: () => Navigator.maybePop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerStatus extends StatelessWidget {
  final bool baruDisimpan;
  final DateTime? waktu;

  const _BannerStatus({required this.baruDisimpan, required this.waktu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB7E9CB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baruDisimpan ? 'Nilai berhasil disimpan' : 'Nilai tersimpan',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF166534),
                  ),
                ),
                if (waktu != null)
                  Text(
                    formatTanggalJam(waktu!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF15803D),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisNilai extends StatelessWidget {
  final String label;
  final int nilai;
  final bool terakhir;

  const _BarisNilai({
    required this.label,
    required this.nilai,
    required this.terakhir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: terakhir ? 0 : 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: kTeks,
                  ),
                ),
              ),
              Text(
                '$nilai',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kTeks,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (nilai / 100).clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: kLatarField,
              valueColor: const AlwaysStoppedAnimation<Color>(kBiru),
            ),
          ),
        ],
      ),
    );
  }
}
