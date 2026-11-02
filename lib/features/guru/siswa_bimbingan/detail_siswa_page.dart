import 'package:flutter/material.dart';

import '../../../data/models/penilaian_model.dart';
import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../../../shared/utils/format_waktu.dart';
import '../common/guru_ui.dart';
import '../penilaian/form_penilaian_page.dart';
import '../penilaian/hasil_penilaian_page.dart';

/// Detail siswa. Cukup menerima [siswaId], jadi bisa dibuka dari daftar
/// siswa maupun dari notifikasi.
class DetailSiswaPage extends StatefulWidget {
  final String siswaId;
  final SiswaBimbinganRepository? siswaRepository;
  final PenilaianRepository? penilaianRepository;

  const DetailSiswaPage({
    super.key,
    required this.siswaId,
    this.siswaRepository,
    this.penilaianRepository,
  });

  @override
  State<DetailSiswaPage> createState() => _DetailSiswaPageState();
}

class _DetailSiswaPageState extends State<DetailSiswaPage> {
  late final SiswaBimbinganRepository _repo =
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
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final siswa = await _repo.ambilDetail(widget.siswaId);
      final nilai = await _nilaiRepo.ambilPenilaian(widget.siswaId);
      if (!mounted) return;
      setState(() {
        _siswa = siswa;
        _nilai = nilai;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat data siswa. Periksa koneksi Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _beriNilai() async {
    final hasil = await Navigator.push<Penilaian>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPenilaianPage(
          siswa: _siswa!,
          penilaianAwal: _nilai,
          repository: _nilaiRepo,
        ),
      ),
    );
    if (hasil != null && mounted) setState(() => _nilai = hasil);
  }

  void _lihatHasil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HasilPenilaianPage(
          siswaId: widget.siswaId,
          siswa: _siswa,
          penilaian: _nilai,
          siswaRepository: _repo,
          penilaianRepository: _nilaiRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLatarAbu,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kTeks,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Detail Siswa',
          style: TextStyle(
            color: kTeks,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(child: _isi()),
    );
  }

  Widget _isi() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _siswa == null) {
      return StatePesan(
        icon: Icons.cloud_off_rounded,
        pesan: _error ?? 'Data siswa tidak ditemukan.',
        aksiLabel: 'Coba lagi',
        onAksi: _muat,
      );
    }

    final s = _siswa!;
    final n = _nilai;
    final pad = hPadding(context);

    return ResponsiveCenter(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KartuPutih(
              child: Row(
                children: [
                  AvatarInisial(inisial: s.inisial, radius: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kTeks,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIS: ${s.nis} • ${s.kelas}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kTeksSekunder,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusKehadiranChip(status: s.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            KartuPutih(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi PKL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTeks,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BarisInfo(label: 'Instansi', nilai: s.instansi),
                  _BarisInfo(
                    label: 'Pembimbing industri',
                    nilai: s.pembimbingIndustri,
                  ),
                  _BarisInfo(label: 'Periode PKL', nilai: s.periodePkl),
                  _BarisInfo(
                    label: 'Kehadiran',
                    nilai: '${s.persentaseKehadiran}%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            KartuPutih(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Penilaian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTeks,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (n == null)
                    const Row(
                      children: [
                        Icon(Icons.star_outline_rounded, color: kTeksSekunder),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Siswa ini belum dinilai.',
                            style: TextStyle(color: kTeksSekunder),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rata-rata nilai',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: kTeksSekunder,
                                ),
                              ),
                              Text(
                                n.rataRata.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: kBiru,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PredikatChip(predikat: n.predikat, rata: n.rataRata),
                      ],
                    ),
                    if (n.disimpanPada != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Disimpan ${formatTanggalJam(n.disimpanPada!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTeksSekunder,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: n == null ? 'Beri Penilaian' : 'Ubah Penilaian',
              onPressed: _beriNilai,
            ),
            if (n != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _lihatHasil,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBiru,
                    side: const BorderSide(color: kBiru),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Lihat Hasil Penilaian'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const _BarisInfo({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: kTeksSekunder),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              nilai,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: kTeks,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
