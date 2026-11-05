import 'package:flutter/material.dart';

import '../../../data/models/penilaian_model.dart';
import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../common/guru_ui.dart';
import 'form_penilaian_page.dart';

enum _Saring {
  semua('Semua'),
  belum('Belum dinilai'),
  sudah('Sudah dinilai');

  final String label;
  const _Saring(this.label);
}

/// Halaman "Penilaian": daftar siswa bimbingan beserta status nilainya.
/// Ketuk siswa untuk membuka Formulir Penilaian.
///
/// Dibuka dari tombol Penilaian di Beranda:
///   Navigator.of(context).push(
///     MaterialPageRoute<void>(builder: (_) => const DaftarPenilaianPage()),
///   );
class DaftarPenilaianPage extends StatefulWidget {
  final SiswaBimbinganRepository? siswaRepository;
  final PenilaianRepository? penilaianRepository;

  const DaftarPenilaianPage({
    super.key,
    this.siswaRepository,
    this.penilaianRepository,
  });

  @override
  State<DaftarPenilaianPage> createState() => _DaftarPenilaianPageState();
}

class _DaftarPenilaianPageState extends State<DaftarPenilaianPage> {
  late final SiswaBimbinganRepository _siswaRepo =
      widget.siswaRepository ?? SiswaBimbinganRepositoryMock();
  late final PenilaianRepository _nilaiRepo =
      widget.penilaianRepository ?? PenilaianRepositoryMock();

  List<SiswaBimbingan> _siswa = [];
  Map<String, Penilaian> _nilai = {};
  bool _loading = true;
  String? _error;
  _Saring _saring = _Saring.semua;

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
      final siswa = await _siswaRepo.ambilDaftar();
      final hasil = await Future.wait(
        siswa.map((s) => _nilaiRepo.ambilPenilaian(s.id)),
      );
      final peta = <String, Penilaian>{};
      for (var i = 0; i < siswa.length; i++) {
        final n = hasil[i];
        if (n != null) peta[siswa[i].id] = n;
      }
      if (!mounted) return;
      setState(() {
        _siswa = siswa;
        _nilai = peta;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Gagal memuat data penilaian. Periksa koneksi Anda.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<SiswaBimbingan> get _tampil {
    return _siswa.where((s) {
      final sudah = _nilai.containsKey(s.id);
      switch (_saring) {
        case _Saring.semua:
          return true;
        case _Saring.belum:
          return !sudah;
        case _Saring.sudah:
          return sudah;
      }
    }).toList();
  }

  Future<void> _bukaForm(SiswaBimbingan s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPenilaianPage(
          siswa: s,
          penilaianAwal: _nilai[s.id],
          repository: _nilaiRepo,
        ),
      ),
    );
    if (!mounted) return;
    await _muat(tampilLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLatarAbu,
      appBar: const GradientAppBar(title: 'Penilaian'),
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
        onAksi: () => _muat(),
      );
    }

    final pad = hPadding(context);
    final data = _tampil;
    final sudah = _nilai.length;

    return ResponsiveCenter(
      child: RefreshIndicator(
        onRefresh: () => _muat(tampilLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
          children: [
            KartuPutih(
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: kBiru, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$sudah dari ${_siswa.length} siswa sudah dinilai',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kTeks,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Ketuk siswa untuk memberi atau mengubah nilai',
                          style: TextStyle(fontSize: 12, color: kTeksSekunder),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _Saring.values.map(_chip).toList(),
            ),
            const SizedBox(height: 14),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: StatePesan(
                  icon: Icons.search_off_rounded,
                  pesan: 'Tidak ada siswa pada kategori ini.',
                ),
              )
            else
              ...data.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KartuPenilaian(
                    siswa: s,
                    nilai: _nilai[s.id],
                    onTap: () => _bukaForm(s),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(_Saring f) {
    final terpilih = _saring == f;
    return ChoiceChip(
      label: Text(f.label),
      selected: terpilih,
      selectedColor: kBiruLembut,
      backgroundColor: Colors.white,
      side: BorderSide(color: terpilih ? kBiru : kBorder),
      labelStyle: TextStyle(
        color: terpilih ? kBiru : kTeks,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => setState(() => _saring = f),
    );
  }
}

class _KartuPenilaian extends StatelessWidget {
  final SiswaBimbingan siswa;
  final Penilaian? nilai;
  final VoidCallback onTap;

  const _KartuPenilaian({
    required this.siswa,
    required this.nilai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = nilai;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AvatarInisial(inisial: siswa.inisial, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: kTeks,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${siswa.kelas} • ${siswa.instansi}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: kTeksSekunder,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (n == null)
                  const _Lencana(
                    teks: 'Belum dinilai',
                    latar: kLatarField,
                    warna: kTeksSekunder,
                  )
                else
                  _Lencana(
                    teks: '${n.rataRata.toStringAsFixed(1)} • ${n.predikat}',
                    latar: const Color(0xFFE8F8EF),
                    warna: const Color(0xFF16A34A),
                  ),
                const Icon(Icons.chevron_right_rounded, color: kTeksSekunder),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Lencana extends StatelessWidget {
  final String teks;
  final Color latar;
  final Color warna;

  const _Lencana({
    required this.teks,
    required this.latar,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: warna,
        ),
      ),
    );
  }
}
