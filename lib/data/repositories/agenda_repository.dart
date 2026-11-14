// Simpan di: lib/data/repositories/agenda_repository.dart
import '../../features/guru/agenda/agenda_data.dart';

class SiswaOpsi {
  final int id;
  final String nama;
  final String kelas;

  const SiswaOpsi({required this.id, required this.nama, required this.kelas});

  factory SiswaOpsi.fromJson(Map<String, dynamic> j) => SiswaOpsi(
        id: (j['id'] as num).toInt(),
        nama: j['nama']?.toString() ?? '-',
        kelas: j['kelas']?.toString() ?? '',
      );
}

/// Satu tempat PKL beserta siswa bimbingan yang ditempatkan di sana.
class TempatOpsi {
  final int instansiId;
  final String nama;
  final String alamat;
  final List<SiswaOpsi> siswa;

  const TempatOpsi({
    required this.instansiId,
    required this.nama,
    required this.alamat,
    required this.siswa,
  });

  factory TempatOpsi.fromJson(Map<String, dynamic> j) => TempatOpsi(
        instansiId: (j['instansi_id'] as num).toInt(),
        nama: j['nama']?.toString() ?? '-',
        alamat: j['alamat']?.toString() ?? '-',
        siswa: (j['siswa'] as List? ?? [])
            .whereType<Map>()
            .map((s) => SiswaOpsi.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
      );
}

abstract class AgendaRepository {
  /// Agenda dalam rentang tanggal, dikelompokkan per kunci yyyy-MM-dd.
  Future<Map<String, List<AgendaItem>>> ambilRentang(
    DateTime dari,
    DateTime sampai,
  );

  Future<List<TempatOpsi>> ambilOpsi();

  /// [jamMulai] dan [jamSelesai] berformat 24 jam "HH:mm".
  Future<AgendaItem> tambah({
    required int instansiId,
    required List<int> siswaIds,
    required DateTime tanggal,
    required String jamMulai,
    required String jamSelesai,
    String? catatan,
  });

  Future<AgendaItem> ubahStatus(int id, StatusAgenda status);

  Future<void> hapus(int id);
}