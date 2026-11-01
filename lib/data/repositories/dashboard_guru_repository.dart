import '../models/dashboard_guru_model.dart';

/// Kontrak data beranda guru. Page hanya bergantung pada kelas ini,
/// jadi tinggal ganti implementasi saat API sudah siap.
abstract class DashboardGuruRepository {
  Future<DashboardGuru> ambilDashboard();
}

/// Data dummy (sama dengan desain) supaya UI bisa jalan sebelum API tersedia.
/// TODO: buat DashboardGuruRepositoryApi (http/dio) dengan endpoint backend,
/// lalu ganti default di GuruHomePage.
class DashboardGuruRepositoryMock implements DashboardGuruRepository {
  final Duration jeda;

  const DashboardGuruRepositoryMock({
    this.jeda = const Duration(milliseconds: 700),
  });

  @override
  Future<DashboardGuru> ambilDashboard() async {
    await Future.delayed(jeda);
    return const DashboardGuru(
      jumlahSiswa: 12,
      persenKehadiran: 85,
      jumlahJurnal: 8,
      jumlahPenilaian: 10,
      jurnalMenunggu: 3,
      notifikasiBelumDibaca: 3,
    );
  }
}