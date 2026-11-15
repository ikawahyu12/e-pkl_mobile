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

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    final siswa = (json['siswa'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final classes =
        siswa
            .map((item) => item['kelas']?.toString())
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return AgendaItem(
      id: (json['id'] as num).toInt(),
      tanggal: DateTime.parse(json['tanggal'].toString()),
      jam: '${json['jam_mulai']}-${json['jam_selesai']} WIB',
      perusahaan: json['perusahaan']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      siswa: siswa.map((item) => item['nama']?.toString() ?? '').join(', '),
      kelas: classes.join(', '),
      status: switch (json['status']) {
        'selesai' => StatusAgenda.selesai,
        'dibatalkan' => StatusAgenda.dibatalkan,
        _ => StatusAgenda.terjadwal,
      },
      catatan: json['catatan']?.toString(),
      alasanPembatalan: json['alasan_pembatalan']?.toString(),
    );
  }
}

String kunciTanggal(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
