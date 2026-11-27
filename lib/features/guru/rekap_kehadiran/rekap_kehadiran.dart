import 'package:flutter/material.dart';

import '../../../data/models/pengajuan_izin_model.dart';
import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/izin_guru_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository.dart';
import '../../../data/repositories/siswa_bimbingan_repository_api.dart';
import '../../../shared/widgets/epkl_widgets.dart';
import '../common/guru_ui.dart';
import 'riwayat_izin_siswa_page.dart';

class RekapKehadiranPage extends StatefulWidget {
  final SiswaBimbinganRepository? repository;
  final IzinGuruRepository? izinRepository;

  const RekapKehadiranPage({super.key, this.repository, this.izinRepository});

  @override
  State<RekapKehadiranPage> createState() => _RekapKehadiranPageState();
}

class _RekapKehadiranPageState extends State<RekapKehadiranPage> {
  late final SiswaBimbinganRepository _repository =
      widget.repository ?? SiswaBimbinganRepositoryApi();
  late final IzinGuruRepository _izinRepository =
      widget.izinRepository ?? IzinGuruRepositoryApi();

  List<SiswaBimbingan> _siswa = [];
  List<PengajuanIzinModel> _pengajuanIzin = [];
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
      var dataSiswa = <SiswaBimbingan>[];
      var dataIzin = <PengajuanIzinModel>[];
      await Future.wait<void>([
        () async {
          dataSiswa = await _repository.ambilDaftar();
        }(),
        () async {
          dataIzin = await _izinRepository.ambilDaftar();
        }(),
      ]);
      if (!mounted) return;
      setState(() {
        _siswa = dataSiswa;
        _pengajuanIzin = dataIzin;
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

  int get _jumlahIzin => _pengajuanIzin
      .where((izin) => izin.jenis.trim().toLowerCase() == 'izin')
      .length;

  int get _jumlahSakit => _pengajuanIzin
      .where((izin) => izin.jenis.trim().toLowerCase() == 'sakit')
      .length;

  int get _totalKehadiran =>
      _siswa.fold(0, (total, siswa) => total + siswa.jumlahHadir);

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Hadir',
                          _jumlahHadir.toString(),
                          Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => DaftarSiswaHadirPage(
                                  siswa: _siswa
                                      .where(
                                        (siswa) =>
                                            siswa.status ==
                                            StatusKehadiran.hadir,
                                      )
                                      .toList(growable: false),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Izin',
                          _jumlahIzin.toString(),
                          Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => RiwayatIzinSiswaPage(
                                  statusIzin: 'izin',
                                  repository: widget.izinRepository,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Sakit',
                          _jumlahSakit.toString(),
                          Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => RiwayatIzinSiswaPage(
                                  statusIzin: 'sakit',
                                  repository: widget.izinRepository,
                                ),
                              ),
                            );
                          },
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
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$_totalKehadiran',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jumlah Kehadiran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_totalKehadiran kali hadir tercatat dari '
                  '${_siswa.length} siswa bimbingan.',
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

  Widget _buildStatCard(
    String title,
    String count,
    Color dotColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
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
      ),
    );
  }

  Widget _buildSiswaRekapItem(SiswaBimbingan siswa) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${siswa.jumlahHadir}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'kali hadir',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DaftarSiswaHadirPage extends StatelessWidget {
  final List<SiswaBimbingan> siswa;

  const DaftarSiswaHadirPage({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Siswa Hadir')),
      body: siswa.isEmpty
          ? const Center(
              child: StatePesan(
                icon: Icons.event_busy_outlined,
                pesan: 'Belum ada siswa yang hadir.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: siswa.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = siswa[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(child: Text(item.inisial)),
                    title: Text(item.nama),
                    subtitle: Text('${item.kelas} - ${item.instansi}'),
                    trailing: Text('${item.jumlahHadir} kali hadir'),
                  ),
                );
              },
            ),
    );
  }
}
