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
    's02': Penilaian(
      siswaId: 's02',
      nilai: const [80, 82, 79, 81, 84],
      catatan: 'Perlu meningkatkan inisiatif dalam menyelesaikan tugas.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 3)),
    ),
    's03': Penilaian(
      siswaId: 's03',
      nilai: const [88, 85, 87, 84, 90],
      catatan: 'Kerja bagus dan teliti.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 3)),
    ),
    's04': Penilaian(
      siswaId: 's04',
      nilai: const [70, 72, 68, 70, 74],
      catatan: 'Perlu pendampingan lebih terkait kedisiplinan.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 4)),
    ),
    's05': Penilaian(
      siswaId: 's05',
      nilai: const [92, 90, 91, 89, 93],
      catatan: 'Sangat baik, aktif dan komunikatif.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 2)),
    ),
    's07': Penilaian(
      siswaId: 's07',
      nilai: const [84, 86, 83, 88, 85],
      catatan: 'Kreatif dalam mengerjakan desain.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 5)),
    ),
    's08': Penilaian(
      siswaId: 's08',
      nilai: const [76, 78, 75, 77, 80],
      catatan: 'Cukup baik, tingkatkan konsistensi.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 5)),
    ),
    's09': Penilaian(
      siswaId: 's09',
      nilai: const [89, 87, 90, 86, 91],
      catatan: 'Disiplin dan bertanggung jawab.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 6)),
    ),
    's10': Penilaian(
      siswaId: 's10',
      nilai: const [81, 79, 83, 80, 82],
      catatan: 'Perkembangan baik, terus tingkatkan.',
      disimpanPada: DateTime.now().subtract(const Duration(days: 6)),
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
