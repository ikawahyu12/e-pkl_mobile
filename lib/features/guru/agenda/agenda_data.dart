import 'package:intl/intl.dart';

enum StatusAgenda { terjadwal, selesai }

class AgendaItem {
  final String jam;
  final String perusahaan;
  final String alamat;
  final String siswa;
  final String kelas;
  final StatusAgenda status;
  final String? catatan;

  const AgendaItem({
    required this.jam,
    required this.perusahaan,
    required this.alamat,
    required this.siswa,
    required this.kelas,
    required this.status,
    this.catatan,
  });
}

// ============================================================
// DATA PALSU (sementara). Nanti ganti dengan data dari backend.
// ============================================================

/// "Hari ini" versi dummy, supaya sama dengan desain (Rabu, 18 November 2026).
/// Saat backend siap, ganti dengan DateTime.now().
final DateTime hariIniDummy = DateTime(2026, 11, 18);

/// Kunci tanggal untuk map agenda, formatnya yyyy-MM-dd.
String kunciTanggal(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

// Bukan const supaya jadwal baru bisa ditambahkan (sementara, tanpa backend).
final Map<String, List<AgendaItem>> dummyAgenda = {
  '2026-11-16': [
    AgendaItem(
      jam: '09.00-10.00 WIB',
      perusahaan: 'PT Digital Nusantara',
      alamat: 'Jl. Asia Afrika No. 10, Bandung',
      siswa: 'Rani Putri & Dika Saputra',
      kelas: 'XI RPL',
      status: StatusAgenda.selesai,
    ),
  ],
  '2026-11-18': [
    AgendaItem(
      jam: '09.00-10.00 WIB',
      perusahaan: 'PT Telkom Indonesia',
      alamat: 'Jl. Merdeka No. 21, Bandung',
      siswa: 'Andi Pratama & Siti Aisyah',
      kelas: 'XI TJKT',
      status: StatusAgenda.selesai,
    ),
    AgendaItem(
      jam: '11.00-12.00 WIB',
      perusahaan: 'CV Kreasi Digital',
      alamat: 'Jl. Dago No. 45, Bandung',
      siswa: 'Rizky Ramadhan & Nabila Putri',
      kelas: 'XI RPL',
      status: StatusAgenda.terjadwal,
    ),
    AgendaItem(
      jam: '14.00-15.00 WIB',
      perusahaan: 'PT Inovasi Teknologi',
      alamat: 'Jl. Soekarno Hatta No. 88, Bandung',
      siswa: 'Dimas Saputra & Fajar Maulana',
      kelas: 'XI TJKT',
      status: StatusAgenda.terjadwal,
    ),
  ],
  '2026-11-19': [
    AgendaItem(
      jam: '10.00-11.00 WIB',
      perusahaan: 'PT Mitra Solusi',
      alamat: 'Jl. Cihampelas No. 7, Bandung',
      siswa: 'Lina Marlina & Bayu Aji',
      kelas: 'XI RPL',
      status: StatusAgenda.terjadwal,
    ),
  ],
  '2026-11-20': [
    AgendaItem(
      jam: '13.00-14.00 WIB',
      perusahaan: 'CV Karya Teknik',
      alamat: 'Jl. Buah Batu No. 120, Bandung',
      siswa: 'Eko Prasetyo & Intan Sari',
      kelas: 'XI TJKT',
      status: StatusAgenda.terjadwal,
    ),
  ],
  '2026-11-22': [
    AgendaItem(
      jam: '09.30-10.30 WIB',
      perusahaan: 'PT Bandung Cloud',
      alamat: 'Jl. Pasteur No. 33, Bandung',
      siswa: 'Gilang Ramadhan & Putri Ayu',
      kelas: 'XI RPL',
      status: StatusAgenda.terjadwal,
    ),
  ],
};