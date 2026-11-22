import '../models/penilaian_model.dart';

abstract class PenilaianRepository {
  /// Mengambil data penilaian siswa berdasarkan ID siswa.
  /// Mengembalikan null jika siswa belum pernah dinilai.
  Future<Penilaian?> ambilPenilaian(String siswaId);

  /// Menyimpan atau memperbarui penilaian melalui backend Laravel.
  /// Mengembalikan data penilaian yang berhasil disimpan.
  Future<Penilaian> simpanPenilaian(Penilaian penilaian);
}
