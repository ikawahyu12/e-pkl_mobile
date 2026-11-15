import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/jurnal_model.dart';
import '../../../data/repositories/jurnal_guru_repository.dart';

class DetailInformasiJurnalPage extends StatefulWidget {
  final String jurnalId;
  final JurnalGuruRepository? repository;

  const DetailInformasiJurnalPage({
    super.key,
    required this.jurnalId,
    this.repository,
  });

  @override
  State<DetailInformasiJurnalPage> createState() =>
      _DetailInformasiJurnalPageState();
}

class _DetailInformasiJurnalPageState extends State<DetailInformasiJurnalPage> {
  late final JurnalGuruRepository _repository =
      widget.repository ?? JurnalGuruRepositoryApi();

  JurnalModel? _jurnal;
  Map<String, String> _imageHeaders = const {};
  String? _error;
  bool _loading = true;

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
      final jurnal = await _repository.ambilDetail(widget.jurnalId);
      final imageHeaders = await _repository.dokumentasiHeaders();
      if (!mounted) return;
      setState(() {
        _jurnal = jurnal;
        _imageHeaders = imageHeaders;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is JurnalGuruException
            ? error.message
            : 'Gagal memuat detail jurnal. Periksa koneksi Anda.';
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
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Detail Informasi Jurnal',
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

    final error = _error;
    if (error != null) {
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
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _muat, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    final jurnal = _jurnal;
    if (jurnal == null) {
      return const Center(child: Text('Informasi jurnal tidak tersedia.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jurnal.namaSiswa.isEmpty
                      ? 'Nama siswa tidak tersedia'
                      : jurnal.namaSiswa,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF182238),
                  ),
                ),
                if (jurnal.nisn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'NISN ${jurnal.nisn}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8493AA),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _information(
                  'TANGGAL KEGIATAN',
                  _formatTanggal(jurnal.tanggal),
                ),
                const SizedBox(height: 16),
                _divider(),
                const SizedBox(height: 16),
                _section('JUDUL JURNAL', jurnal.judul),
                const SizedBox(height: 16),
                _section('KEGIATAN', jurnal.kegiatan),
                if (_hasText(jurnal.hasil)) ...[
                  const SizedBox(height: 16),
                  _section('HASIL KEGIATAN', jurnal.hasil!),
                ],
                if (_hasText(jurnal.kendala)) ...[
                  const SizedBox(height: 16),
                  _section('KENDALA', jurnal.kendala!),
                ],
              ],
            ),
          ),
          if (jurnal.dokumentasi.isNotEmpty) ...[
            const SizedBox(height: 16),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _judulBagian('DOKUMENTASI KEGIATAN'),
                  const SizedBox(height: 12),
                  for (final lampiran in jurnal.dokumentasi) ...[
                    if (lampiran.url.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          lampiran.url,
                          headers: _imageHeaders,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fotoTidakTersedia(),
                        ),
                      )
                    else
                      _fotoTidakTersedia(),
                    if (lampiran.namaFile.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        lampiran.namaFile,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7084A3),
                        ),
                      ),
                    ],
                    if (lampiran != jurnal.dokumentasi.last)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }

  Widget _information(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _judulBagian(title),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF182238),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _judulBagian(title),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF506078),
          ),
        ),
      ],
    );
  }

  Widget _judulBagian(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7084A3),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: const Color(0xFFEDF1F6));

  Widget _fotoTidakTersedia() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF7084A3)),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _formatTanggal(String tanggal) {
    final parsed = DateTime.tryParse(tanggal);
    return parsed == null
        ? (tanggal.isEmpty ? 'Tanggal tidak tersedia' : tanggal)
        : DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
  }
}
