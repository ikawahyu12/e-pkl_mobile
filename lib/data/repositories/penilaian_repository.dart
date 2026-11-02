import '../models/penilaian_model.dart';

abstract class PenilaianRepository {
  /// null bila siswa belum pernah dinilai.
  Future<Penilaian?> ambilPenilaian(String siswaId);

  /// Mengembalikan data yang sudah tersimpan (lengkap dengan waktu simpan).
  Future<Penilaian> simpanPenilaian(Penilaian penilaian);
}

/// Data dummy. Singleton, jadi nilai yang disimpan di form langsung
/// terlihat di halaman detail/hasil selama aplikasi berjalan.
/// TODO: buat PenilaianRepositoryApi lalu ganti default di page.
class PenilaianRepositoryMock implements PenilaianRepository {
  static final PenilaianRepositoryMock _instance = PenilaianRepositoryMock._();
  factory PenilaianRepositoryMock() => _instance;
  PenilaianRepositoryMock._();

  final Map<String, Penilaian> _data = {
    's01': Penilaian(
      siswaId: 's01',
      nilai: const [85, 78, 82, 80, 88],
      catatan:
          'Siswa menunjukkan sikap kerja yang sangat disiplin dan mampu '
          'bekerjasama dalam tim dengan baik. Pertahankan kinerjanya.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 2)),
    ),
    's06': Penilaian(
      siswaId: 's06',
      nilai: const [90, 86, 84, 88, 92],
      catatan: 'Praktik berjalan baik dan konsisten.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 1)),
    ),
  };

  @override
  Future<Penilaian?> ambilPenilaian(String siswaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data[siswaId];
  }

  @override
  Future<Penilaian> simpanPenilaian(Penilaian penilaian) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (penilaian.nilai.length != Penilaian.namaAspek.length ||
        penilaian.nilai.any((v) => !Penilaian.nilaiValid(v))) {
      throw ArgumentError('Nilai harus berada di rentang 0–100');
    }
    final tersimpan = Penilaian(
      siswaId: penilaian.siswaId,
      nilai: List.of(penilaian.nilai),
      catatan: penilaian.catatan,
      disimpanPada: DateTime.now(),
    );
    _data[penilaian.siswaId] = tersimpan;
    return tersimpan;
  }
}
