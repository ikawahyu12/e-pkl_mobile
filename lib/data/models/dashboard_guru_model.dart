/// Ringkasan angka pada beranda guru pembimbing.
class DashboardGuru {
  final int jumlahSiswa;

  /// Persentase kehadiran siswa bimbingan (0-100).
  final int persenKehadiran;
  final int jumlahJurnal;
  final int jumlahPenilaian;

  /// Jurnal yang masih menunggu validasi guru.
  final int jurnalMenunggu;
  final int notifikasiBelumDibaca;

  const DashboardGuru({
    required this.jumlahSiswa,
    required this.persenKehadiran,
    required this.jumlahJurnal,
    required this.jumlahPenilaian,
    required this.jurnalMenunggu,
    required this.notifikasiBelumDibaca,
  });

  bool get adaNotifikasiBaru => notifikasiBelumDibaca > 0;

  /// Kalimat pada tile "Informasi Terbaru".
  String get infoTerbaru => jurnalMenunggu > 0
      ? 'Terdapat $jurnalMenunggu jurnal yang menunggu validasi.'
      : 'Tidak ada jurnal yang menunggu validasi.';

  /// Sesuaikan key dengan response API backend.
  factory DashboardGuru.fromJson(Map<String, dynamic> json) {
    int angka(String key) => (json[key] as num?)?.toInt() ?? 0;
    return DashboardGuru(
      jumlahSiswa: angka('jumlah_siswa'),
      persenKehadiran: angka('persen_kehadiran'),
      jumlahJurnal: angka('jumlah_jurnal'),
      jumlahPenilaian: angka('jumlah_penilaian'),
      jurnalMenunggu: angka('jurnal_menunggu'),
      notifikasiBelumDibaca: angka('notifikasi_belum_dibaca'),
    );
  }
}