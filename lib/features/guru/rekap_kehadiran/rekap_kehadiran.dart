import 'package:flutter/material.dart';

import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository_api.dart';
import '../../../shared/widgets/epkl_widgets.dart';
import '../common/guru_ui.dart';

class RekapKehadiranPage extends StatefulWidget {
  final SiswaBimbinganRepository? repository;

  const RekapKehadiranPage({super.key, this.repository});

  @override
  State<RekapKehadiranPage> createState() => _RekapKehadiranPageState();
}

class _RekapKehadiranPageState extends State<RekapKehadiranPage> {
  late final SiswaBimbinganRepository _repository =
      widget.repository ?? SiswaBimbinganRepositoryApi();

  List<SiswaBimbingan> _siswa = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await _repository.ambilDaftar();
      if (!mounted) return;
      setState(() {
        _siswa = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat rekap kehadiran. Periksa koneksi Anda.';
        _loading = false;
      });
    }
  }

  int get _jumlahHadir =>
      _siswa.where((siswa) => siswa.status == StatusKehadiran.hadir).length;

  int get _jumlahIzin =>
      _siswa.where((siswa) => siswa.status == StatusKehadiran.izin).length;

  int get _jumlahSakit =>
      _siswa.where((siswa) => siswa.status == StatusKehadiran.sakit).length;

  int get _jumlahAlpha =>
      _siswa.where((siswa) => siswa.status == StatusKehadiran.alpha).length;

  double get _rataRataKehadiran {
    if (_siswa.isEmpty) return 0;
    final total = _siswa.fold<int>(
      0,
      (jumlah, siswa) => jumlah + siswa.persentaseKehadiran,
    );
    return total / _siswa.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const EpklGradientAppBar(judul: 'Rekap Kehadiran'),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 160),
                  StatePesan(
                    icon: Icons.cloud_off_rounded,
                    pesan: _error!,
                    aksiLabel: 'Coba lagi',
                    onAksi: _muat,
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Hadir',
                          _jumlahHadir.toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Izin',
                          _jumlahIzin.toString(),
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Sakit',
                          _jumlahSakit.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Alpha',
                          _jumlahAlpha.toString(),
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRingkasanKehadiran(),
                  const SizedBox(height: 24),
                  const Text(
                    'Kehadiran Per Siswa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (_siswa.isEmpty)
                    const StatePesan(
                      icon: Icons.person_search_outlined,
                      pesan: 'Belum ada data siswa bimbingan.',
                    )
                  else
                    for (final siswa in _siswa) _buildSiswaRekapItem(siswa),
                ],
              ),
      ),
    );
  }

  Widget _buildRingkasanKehadiran() {
    final persentase = _rataRataKehadiran;
    final nilai = persentase.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: nilai / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Center(
                  child: Text(
                    '${persentase.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tingkat Kehadiran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_siswa.length} siswa bimbingan memiliki rata-rata '
                  'kehadiran ${persentase.toStringAsFixed(1)}% berdasarkan '
                  'data terbaru.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaRekapItem(SiswaBimbingan siswa) {
    final persentase = siswa.persentaseKehadiran.toDouble().clamp(0, 100);
    final warna = persentase >= 90
        ? Colors.green
        : persentase >= 75
        ? Colors.blue
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: Text(
                  siswa.inisial,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      siswa.kelas,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${siswa.persentaseKehadiran}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: warna,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: persentase / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(warna),
            ),
          ),
        ],
      ),
    );
  }
}
