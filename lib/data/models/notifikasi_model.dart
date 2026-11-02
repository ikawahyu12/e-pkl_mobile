import '../../shared/utils/format_waktu.dart';

enum TipeNotifikasi { jurnal, kehadiran, penilaian, informasi }

class Notifikasi {
  final String id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final TipeNotifikasi tipe;
  final bool dibaca;

  /// Diisi bila notifikasi terkait satu siswa tertentu (untuk navigasi).
  final String? siswaId;

  const Notifikasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.tipe,
    this.dibaca = false,
    this.siswaId,
  });

  bool get hariIni => sameDay(waktu, DateTime.now());

  String get labelWaktu => labelWaktuRelatif(waktu);

  Notifikasi copyWith({bool? dibaca}) {
    return Notifikasi(
      id: id,
      judul: judul,
      isi: isi,
      waktu: waktu,
      tipe: tipe,
      dibaca: dibaca ?? this.dibaca,
      siswaId: siswaId,
    );
  }

  /// Sesuaikan key dengan response API backend.
  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: '${json['id']}',
      judul: (json['judul'] ?? '') as String,
      isi: (json['isi'] ?? '') as String,
      waktu: DateTime.tryParse('${json['waktu']}') ?? DateTime.now(),
      tipe: TipeNotifikasi.values.firstWhere(
        (t) => t.name == json['tipe'],
        orElse: () => TipeNotifikasi.informasi,
      ),
      dibaca: (json['dibaca'] ?? false) as bool,
      siswaId: json['siswa_id']?.toString(),
    );
  }
}
