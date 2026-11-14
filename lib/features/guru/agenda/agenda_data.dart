// Simpan di: lib/features/guru/agenda/agenda_data.dart (timpa file lama)
import 'package:intl/intl.dart';

enum StatusAgenda { terjadwal, selesai }

class AgendaItem {
  final int? id;
  final String jam;
  final String perusahaan;
  final String alamat;
  final String siswa;
  final String kelas;
  final StatusAgenda status;
  final String? catatan;

  const AgendaItem({
    this.id,
    required this.jam,
    required this.perusahaan,
    required this.alamat,
    required this.siswa,
    required this.kelas,
    required this.status,
    this.catatan,
  });

  /// Key mengikuti respons AgendaController di Laravel.
  factory AgendaItem.fromJson(Map<String, dynamic> j) {
    final daftarSiswa = (j['siswa'] as List? ?? []).whereType<Map>().toList();

    final nama = daftarSiswa
        .map((s) => s['nama']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(' & ');
    final kelas = daftarSiswa
        .map((s) => s['kelas']?.toString() ?? '')
        .where((k) => k.isNotEmpty)
        .toSet()
        .join(', ');

    final catatan = j['catatan']?.toString().trim();

    return AgendaItem(
      id: (j['id'] as num?)?.toInt(),
      jam: '${_jam(j['jam_mulai'])}-${_jam(j['jam_selesai'])} WIB',
      perusahaan: j['perusahaan']?.toString() ?? '-',
      alamat: j['alamat']?.toString() ?? '-',
      siswa: nama.isEmpty ? '-' : nama,
      kelas: kelas,
      status: j['status'] == 'selesai'
          ? StatusAgenda.selesai
          : StatusAgenda.terjadwal,
      catatan: (catatan == null || catatan.isEmpty) ? null : catatan,
    );
  }

  AgendaItem copyWith({StatusAgenda? status}) => AgendaItem(
        id: id,
        jam: jam,
        perusahaan: perusahaan,
        alamat: alamat,
        siswa: siswa,
        kelas: kelas,
        status: status ?? this.status,
        catatan: catatan,
      );
}

/// "09:00" -> "09.00"
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
String kunciTanggal(DateTime d) => DateFormat('yyyy-MM-dd').format(d);