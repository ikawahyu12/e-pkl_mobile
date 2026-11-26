import 'package:flutter/material.dart';

import '../../../data/models/pengajuan_izin_model.dart';
import '../../../data/repositories/izin_guru_repository.dart';

class RiwayatIzinSiswaPage extends StatefulWidget {
  final String statusIzin;
  final IzinGuruRepository? repository;

  const RiwayatIzinSiswaPage({
    super.key,
    required this.statusIzin,
    this.repository,
  });

  @override
  State<RiwayatIzinSiswaPage> createState() => _RiwayatIzinSiswaPageState();
}

class _RiwayatIzinSiswaPageState extends State<RiwayatIzinSiswaPage> {
  late final IzinGuruRepository _repository =
      widget.repository ?? IzinGuruRepositoryApi();

  List<PengajuanIzinModel> _pengajuan = [];
  Map<String, String> _lampiranHeaders = const {};
  bool _loading = true;
  String? _error;

  String get _jenis => widget.statusIzin.trim().toLowerCase();
  String get _judul => _jenis == 'sakit' ? 'Riwayat Sakit' : 'Riwayat Izin';

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
      final hasil = await _repository.ambilDaftar();
      final headers = await _repository.lampiranHeaders();
      if (!mounted) return;
      setState(() {
        _pengajuan = hasil
            .where((item) => item.jenis.trim().toLowerCase() == _jenis)
            .toList();
        _lampiranHeaders = headers;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text(_judul)),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: _loading
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 260),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  Center(child: Text(_error!, textAlign: TextAlign.center)),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _muat,
                      child: const Text('Coba lagi'),
                    ),
                  ),
                ],
              )
            : _pengajuan.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Icon(
                    Icons.event_busy_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Belum ada pengajuan ${_jenis == 'sakit' ? 'sakit' : 'izin'}.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _pengajuan.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _KartuPengajuanIzin(
                  pengajuan: _pengajuan[index],
                  imageHeaders: _lampiranHeaders,
                ),
              ),
      ),
    );
  }
}

class _KartuPengajuanIzin extends StatelessWidget {
  final PengajuanIzinModel pengajuan;
  final Map<String, String> imageHeaders;

  const _KartuPengajuanIzin({
    required this.pengajuan,
    required this.imageHeaders,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pengajuan.namaSiswa.isEmpty ? 'Siswa' : pengajuan.namaSiswa,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text(_labelStatus(pengajuan.status))),
              ],
            ),
            if (pengajuan.nisn.isNotEmpty) Text('NISN: ${pengajuan.nisn}'),
            const SizedBox(height: 8),
            Text(
              pengajuan.tanggalSelesai.isEmpty
                  ? pengajuan.tanggalMulai
                  : '${pengajuan.tanggalMulai} s.d. ${pengajuan.tanggalSelesai}',
            ),
            if (pengajuan.alasan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(pengajuan.alasan),
            ],
            for (final lampiran in pengajuan.lampiran) ...[
              const SizedBox(height: 12),
              if (lampiran.isImage)
                GestureDetector(
                  onTap: () => _tampilkanFoto(context, lampiran.url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      lampiran.url,
                      headers: imageHeaders,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, _, _) => _lampiranTidakTersedia(),
                    ),
                  ),
                )
              else
                _lampiranFile(lampiran),
            ],
          ],
        ),
      ),
    );
  }

  String _labelStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return 'Menunggu';
      case 'disetujui':
      case 'approved':
        return 'Disetujui';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      default:
        return status.isEmpty ? 'Status tidak tersedia' : status;
    }
  }

  Widget _lampiranFile(IzinLampiranModel lampiran) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lampiran.namaFile.isEmpty ? 'Lampiran' : lampiran.namaFile,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lampiranTidakTersedia() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }

  void _tampilkanFoto(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            url,
            headers: imageHeaders,
            errorBuilder: (_, _, _) =>
                const SizedBox(height: 200, child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}
