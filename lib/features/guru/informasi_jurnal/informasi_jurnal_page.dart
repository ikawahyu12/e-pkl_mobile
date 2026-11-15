import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/jurnal_model.dart';
import '../../../data/repositories/jurnal_guru_repository.dart';
import 'detail_informasi_jurnal_page.dart';

class InformasiJurnalPage extends StatefulWidget {
  final JurnalGuruRepository? repository;

  const InformasiJurnalPage({super.key, this.repository});

  @override
  State<InformasiJurnalPage> createState() => _InformasiJurnalPageState();
}

class _InformasiJurnalPageState extends State<InformasiJurnalPage> {
  late final JurnalGuruRepository _repository =
      widget.repository ?? JurnalGuruRepositoryApi();

  List<JurnalModel> _jurnal = [];
  Map<String, String> _imageHeaders = const {};
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
      final jurnal = await _repository.ambilDaftar();
      final imageHeaders = await _repository.dokumentasiHeaders();
      if (!mounted) return;
      setState(() {
        _jurnal = jurnal;
        _imageHeaders = imageHeaders;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is JurnalGuruException
            ? error.message
            : 'Gagal memuat informasi jurnal. Periksa koneksi Anda.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Informasi Jurnal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _jurnal.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _muat, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _muat(tampilLoading: false),
      child: _jurnal.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Belum ada jurnal siswa',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _jurnal.length + (_error == null ? 0 : 1),
              itemBuilder: (context, index) {
                if (_error != null && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                final jurnalIndex = index - (_error == null ? 0 : 1);
                return _kartuJurnal(_jurnal[jurnalIndex]);
              },
            ),
    );
  }

  Widget _kartuJurnal(JurnalModel jurnal) {
    final lampiran = jurnal.dokumentasi.isEmpty
        ? null
        : jurnal.dokumentasi.first;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => DetailInformasiJurnalPage(
              jurnalId: jurnal.id,
              repository: _repository,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lampiran != null && lampiran.url.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lampiran.url,
                  headers: _imageHeaders,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholderFoto(),
                ),
              )
            else
              _placeholderFoto(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jurnal.namaSiswa.isEmpty
                        ? 'Nama siswa tidak tersedia'
                        : jurnal.namaSiswa,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182238),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTanggal(jurnal.tanggal),
                    style: const TextStyle(
                      color: Color(0xFF8493AA),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jurnal.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF34445F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jurnal.kegiatan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF506078),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderFoto() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.description_outlined, color: Color(0xFF7084A3)),
    );
  }

  String _formatTanggal(String tanggal) {
    final parsed = DateTime.tryParse(tanggal);
    return parsed == null
        ? (tanggal.isEmpty ? 'Tanggal tidak tersedia' : tanggal)
        : DateFormat('d MMM yyyy', 'id_ID').format(parsed);
  }
}
