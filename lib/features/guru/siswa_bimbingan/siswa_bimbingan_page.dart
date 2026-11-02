import 'package:flutter/material.dart';

import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../common/guru_ui.dart';
import 'detail_siswa_page.dart';

enum _Urutan {
  terbaru('Terbaru'),
  namaAz('Nama A–Z'),
  kelas('Kelas');

  final String label;
  const _Urutan(this.label);
}

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
  _Urutan _urutan = _Urutan.terbaru;
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

    switch (_urutan) {
      case _Urutan.terbaru:
        break; // urutan asli dari repository
      case _Urutan.namaAz:
        hasil.sort(
          (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
        );
      case _Urutan.kelas:
        hasil.sort((a, b) {
          final c = a.kelas.compareTo(b.kelas);
          return c != 0
              ? c
              : a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
        });
    }
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
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
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
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Siswa Bimbingan',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kTeks,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _kolomCari()),
              const SizedBox(width: 12),
              _tombolFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total $jumlah siswa',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: kTeksSekunder,
                  ),
                ),
              ),
              _menuUrutan(),
            ],
          ),
          const SizedBox(height: 14),
        ],
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
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
        fillColor: kLatarField,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _tombolFilter() {
    return Material(
      color: kLatarField,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _bukaFilter,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.tune_rounded, color: kTeks),
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
    );
  }

  Widget _menuUrutan() {
    return PopupMenuButton<_Urutan>(
      initialValue: _urutan,
      onSelected: (u) => setState(() => _urutan = u),
      itemBuilder: (_) => _Urutan.values
          .map((u) => PopupMenuItem<_Urutan>(value: u, child: Text(u.label)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _urutan.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTeks,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: kTeks,
            ),
          ],
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
                const Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: kBiru,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: kBiru),
                    Spacer(),
                    Icon(Icons.chevron_right_rounded, color: kTeksSekunder),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
