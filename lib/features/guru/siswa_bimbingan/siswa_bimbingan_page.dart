import 'package:flutter/material.dart';

import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../../../shared/widgets/epkl_colors.dart';
import '../common/guru_ui.dart';
import 'detail_siswa_page.dart';

class SiswaBimbinganPage extends StatefulWidget {
  final SiswaBimbinganRepository? repository;
  final PenilaianRepository? penilaianRepository;

  const SiswaBimbinganPage({
    super.key,
    this.repository,
    this.penilaianRepository,
  });

  @override
  State<SiswaBimbinganPage> createState() => _SiswaBimbinganPageState();
}

class _SiswaBimbinganPageState extends State<SiswaBimbinganPage> {
  late final SiswaBimbinganRepository _repo =
      widget.repository ?? SiswaBimbinganRepositoryMock();
  late final PenilaianRepository _nilaiRepo =
      widget.penilaianRepository ?? PenilaianRepositoryMock();

  final _cari = TextEditingController();

  List<SiswaBimbingan> _semua = [];
  bool _loading = true;
  String? _error;
  StatusKehadiran? _filterStatus;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Future<void> _muat({bool tampilLoading = true}) async {
    if (tampilLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _repo.ambilDaftar();
      if (!mounted) return;
      setState(() {
        _semua = data;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Gagal memuat daftar siswa. Periksa koneksi Anda.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<SiswaBimbingan> get _tampil {
    final q = _cari.text.trim().toLowerCase();
    final hasil = _semua.where((s) {
      if (_filterStatus != null && s.status != _filterStatus) return false;
      if (q.isEmpty) return true;
      return s.nama.toLowerCase().contains(q) ||
          s.kelas.toLowerCase().contains(q) ||
          s.instansi.toLowerCase().contains(q);
    }).toList();

    return hasil;
  }

  void _bukaDetail(SiswaBimbingan s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSiswaPage(
          siswaId: s.id,
          siswaRepository: _repo,
          penilaianRepository: _nilaiRepo,
        ),
      ),
    );
  }

  void _bukaFilter() {
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
              const Text(
                'Filter status kehadiran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kTeks,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chipFilter(ctx, 'Semua', null),
                  ...StatusKehadiran.values.map(
                    (s) => _chipFilter(ctx, s.label, s),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipFilter(BuildContext ctx, String label, StatusKehadiran? nilai) {
    final terpilih = _filterStatus == nilai;
    return ChoiceChip(
      label: Text(label),
      selected: terpilih,
      selectedColor: kBiruLembut,
      backgroundColor: Colors.white,
      side: BorderSide(color: terpilih ? kBiru : kBorder),
      labelStyle: TextStyle(
        color: terpilih ? kBiru : kTeks,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() => _filterStatus = nilai);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: ResponsiveCenter(maxWidth: 900, child: _isi())),
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

    return LayoutBuilder(
      builder: (context, c) {
        final lebar = c.maxWidth >= 640;
        return RefreshIndicator(
          onRefresh: () => _muat(tampilLoading: false),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(pad, data.length)),
              if (data.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: StatePesan(
                    icon: Icons.search_off_rounded,
                    pesan:
                        'Tidak ada siswa yang cocok dengan pencarian atau filter.',
                  ),
                )
              else if (lebar)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 440,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent:
                          150 *
                          MediaQuery.textScalerOf(
                            context,
                          ).scale(1).clamp(1.0, 1.4).toDouble(),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _KartuSiswa(
                        siswa: data[i],
                        onTap: () => _bukaDetail(data[i]),
                      ),
                      childCount: data.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _KartuSiswa(
                          siswa: data[i],
                          onTap: () => _bukaDetail(data[i]),
                        ),
                      ),
                      childCount: data.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(double pad, int jumlah) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: EpklColors.gradienUtama,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1677FF).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1677FF),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4FA8).withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$jumlah siswa',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16427A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Siswa Bimbingan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kolomCari()),
                const SizedBox(width: 10),
                _tombolFilter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kolomCari() {
    return TextField(
      controller: _cari,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari nama siswa, kelas, atau instansi...',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, color: kTeksSekunder),
        suffixIcon: _cari.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _cari.clear();
                  setState(() {});
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBiru, width: 1.4),
        ),
      ),
    );
  }

  Widget _tombolFilter() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _bukaFilter,
        child: SizedBox(
          width: 52,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6F2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.tune_rounded, color: kBiru),
                if (_filterStatus != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kBiru,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuSiswa extends StatelessWidget {
  final SiswaBimbingan siswa;
  final VoidCallback onTap;

  const _KartuSiswa({required this.siswa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: kBiruLembut,
                      child: Icon(Icons.person_outline_rounded, color: kBiru),
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
                                  siswa.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: kTeks,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusKehadiranChip(status: siswa.status),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            siswa.kelas,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: kTeksSekunder,
                            ),
                          ),
                          Text(
                            siswa.instansi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: kTeksSekunder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: kBorder),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kBiruLembut,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: kBiru,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: kBiru,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
