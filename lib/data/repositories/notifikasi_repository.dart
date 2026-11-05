import '../models/notifikasi_model.dart';

/// Kontrak data notifikasi guru. Page hanya bergantung pada kelas ini,
/// jadi tinggal ganti implementasi saat API sudah siap.
abstract class NotifikasiRepository {
  Future<List<Notifikasi>> ambilNotifikasi();
  Future<void> tandaiDibaca(String id);
  Future<void> tandaiSemuaDibaca();

  /// Jumlah notifikasi yang belum dibaca (untuk titik merah di lonceng).
  Future<int> jumlahBelumDibaca();
}

/// Data dummy supaya UI bisa jalan sebelum API tersedia.
/// Singleton, jadi status "dibaca" konsisten antar halaman.
/// TODO: buat NotifikasiRepositoryApi (http/dio) lalu ganti default di page.
class NotifikasiRepositoryMock implements NotifikasiRepository {
  static final NotifikasiRepositoryMock _instance =
      NotifikasiRepositoryMock._();
  factory NotifikasiRepositoryMock() => _instance;
  NotifikasiRepositoryMock._();

  static DateTime _hariIni(int jam, int menit) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, jam, menit);
  }

  static DateTime _hariLalu(int hari, int jam, int menit) {
    final n = DateTime.now().subtract(Duration(days: hari));
    return DateTime(n.year, n.month, n.day, jam, menit);
  }

  List<Notifikasi> _data = [
    Notifikasi(
      id: 'n1',
      judul: 'Jurnal menunggu validasi',
      isi: 'Dinda Aulia mengirim jurnal kegiatan minggu ke-4 untuk diperiksa.',
      waktu: _hariIni(8, 15),
      tipe: TipeNotifikasi.jurnal,
      siswaId: 's05',
    ),
    Notifikasi(
      id: 'n2',
      judul: 'Pembaruan kehadiran',
      isi:
          'Rekap pagi telah diperbarui. Kehadiran siswa bimbingan mencapai 92%.',
      waktu: _hariIni(7, 5),
      tipe: TipeNotifikasi.kehadiran,
    ),
    Notifikasi(
      id: 'n3',
      judul: 'Penilaian tersimpan',
      isi: 'Nilai praktik Arya Pratama berhasil disimpan pada Senin, 14.22.',
      waktu: _hariLalu(1, 14, 22),
      tipe: TipeNotifikasi.penilaian,
      dibaca: true,
      siswaId: 's06',
    ),
    Notifikasi(
      id: 'n4',
      judul: 'Informasi sekolah',
      isi:
          'Batas akhir verifikasi laporan PKL diperpanjang hingga 30 September.',
      waktu: _hariLalu(3, 10, 0),
      tipe: TipeNotifikasi.informasi,
      dibaca: true,
    ),
  ];

  @override
  Future<List<Notifikasi>> ambilNotifikasi() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.of(_data);
  }

  @override
  Future<void> tandaiDibaca(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _data = _data
        .map((n) => n.id == id ? n.copyWith(dibaca: true) : n)
        .toList();
  }

  @override
  Future<void> tandaiSemuaDibaca() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data = _data.map((n) => n.copyWith(dibaca: true)).toList();
  }

  @override
  Future<int> jumlahBelumDibaca() async {
    return _data.where((n) => !n.dibaca).length;
  }
}
