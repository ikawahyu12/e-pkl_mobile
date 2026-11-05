// lib/data/models/jurnal_model.dart

class JurnalModel {
  final String id;
  final String namaSiswa;
  final String kelas;
  final String tanggal;
  final String judulKegiatan;
  final String shiftKerja;
  final String laporanKegiatan;
  final String dokumentasi;
  String status; // 'Menunggu', 'Disetujui', 'Revisi'
  String? catatanPembimbing;

  JurnalModel({
    required this.id,
    required this.namaSiswa,
    required this.kelas,
    required this.tanggal,
    required this.judulKegiatan,
    required this.shiftKerja,
    required this.laporanKegiatan,
    required this.dokumentasi,
    required this.status,
    this.catatanPembimbing,
  });
}