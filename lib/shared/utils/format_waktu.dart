const List<String> _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const List<String> _namaBulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _dua(int n) => n.toString().padLeft(2, '0');

/// Contoh: 14.22
String formatJam(DateTime t) => '${_dua(t.hour)}.${_dua(t.minute)}';

/// Contoh: 2 Nov 2026
String formatTanggal(DateTime t) =>
    '${t.day} ${_namaBulan[t.month - 1]} ${t.year}';

/// Contoh: 2 Nov 2026, 14.22
String formatTanggalJam(DateTime t) => '${formatTanggal(t)}, ${formatJam(t)}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Hari ini -> jam, kemarin -> "Kemarin", <7 hari -> nama hari, lainnya -> tanggal.
String labelWaktuRelatif(DateTime t, {DateTime? sekarang}) {
  final now = sekarang ?? DateTime.now();
  final selisih = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(t.year, t.month, t.day)).inDays;
  if (selisih <= 0) return formatJam(t);
  if (selisih == 1) return 'Kemarin';
  if (selisih < 7) return _namaHari[t.weekday - 1];
  return formatTanggal(t);
}
