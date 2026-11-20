import 'package:intl/intl.dart';

enum StatusAgenda { terjadwal, selesai, dibatalkan }

class AgendaItem {
  final int id;
  final DateTime tanggal;
  final String jam;
  final String perusahaan;
  final String alamat;
  final String siswa;
  final String kelas;
  final StatusAgenda status;
  final String? catatan;
  final String? alasanPembatalan;

  const AgendaItem({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.perusahaan,
    required this.alamat,
    required this.siswa,
    required this.kelas,
    required this.status,
    this.catatan,
    this.alasanPembatalan,
  });

  /// Key mengikuti respons AgendaController di Laravel.
  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    final daftarSiswa = (json['siswa'] as List? ?? const [])
        .whereType()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final nama = daftarSiswa
        .map((s) => s['nama']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(' & ');

    final classes = daftarSiswa
        .map((s) => s['kelas']?.toString() ?? '')
        .where((k) => k.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final catatan = json['catatan']?.toString().trim();
    final alasan = json['alasan_pembatalan']?.toString().trim();
    final tanggalRaw = json['tanggal']?.toString();

    return AgendaItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tanggal: (tanggalRaw != null && tanggalRaw.isNotEmpty)
          ? DateTime.parse(tanggalRaw)
          : hariIni(),
      jam: '${_jam(json['jam_mulai'])}-${_jam(json['jam_selesai'])} WIB',
      perusahaan: json['perusahaan']?.toString() ?? '-',
      alamat: json['alamat']?.toString() ?? '-',
      siswa: nama.isEmpty ? '-' : nama,
      kelas: classes.join(', '),
      status: switch (json['status']) {
        'selesai' => StatusAgenda.selesai,
        'dibatalkan' => StatusAgenda.dibatalkan,
        _ => StatusAgenda.terjadwal,
      },
      catatan: (catatan == null || catatan.isEmpty) ? null : catatan,
      alasanPembatalan: (alasan == null || alasan.isEmpty) ? null : alasan,
    );
  }

  AgendaItem copyWith({
    int? id,
    DateTime? tanggal,
    String? jam,
    String? perusahaan,
    String? alamat,
    String? siswa,
    String? kelas,
    StatusAgenda? status,
    String? catatan,
    String? alasanPembatalan,
  }) =>
      AgendaItem(
        id: id ?? this.id,
        tanggal: tanggal ?? this.tanggal,
        jam: jam ?? this.jam,
        perusahaan: perusahaan ?? this.perusahaan,
        alamat: alamat ?? this.alamat,
        siswa: siswa ?? this.siswa,
        kelas: kelas ?? this.kelas,
        status: status ?? this.status,
        catatan: catatan ?? this.catatan,
        alasanPembatalan: alasanPembatalan ?? this.alasanPembatalan,
      );
}

/// "09:00:00" atau "09:00" -> "09.00"
String _jam(dynamic nilai) {
  final s = nilai?.toString() ?? '';
  final hhmm = s.length >= 5 ? s.substring(0, 5) : s;
  return hhmm.replaceAll(':', '.');
}

/// Tanggal hari ini (dibuat fungsi supaya selalu terbaru).
DateTime hariIni() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Kunci tanggal untuk map agenda, formatnya yyyy-MM-dd.
String kunciTanggal(DateTime date) => DateFormat('yyyy-MM-dd').format(date);