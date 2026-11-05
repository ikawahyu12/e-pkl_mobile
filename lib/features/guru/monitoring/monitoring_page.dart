import 'package:flutter/material.dart';
import '../agenda/agenda_page.dart';
import '../presensi/presensi.dart';
// ============================================================
// DATA PALSU (sementara). Nanti ganti dengan data dari backend.
// ============================================================
const int dummyJumlahSiswaTerpantau = 10;

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  static const _biruGelap = Color(0xFF0F172A);
  static const _abu = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              'Monitoring',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _biruGelap,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau presensi dan aktivitas PKL siswa bimbingan Anda.',
              style: TextStyle(fontSize: 12, color: _abu),
            ),
            const SizedBox(height: 16),
            _buildRingkasan(),
            const SizedBox(height: 16),
            _MenuCard(
              ikon: Icons.event_note_outlined,
              warnaIkon: const Color(0xFFD97706),
              bgIkon: const Color(0xFFFEF3C7),
              judul: 'Agenda',
              deskripsi: 'Kelola agenda kunjungan ke tempat PKL siswa.',
              onTap: () => Navigator.push( context,
            MaterialPageRoute(builder: (_) => const AgendaPage()),
            ),
            ),
            _MenuCard(
              ikon: Icons.event_available_outlined,
              warnaIkon: const Color(0xFF059669),
              bgIkon: const Color(0xFFD1FAE5),
              judul: 'Presensi',
              deskripsi: 'Buat presensi dan lihat rekap kehadiran siswa.',
              onTap: () => Navigator.push( context,
            MaterialPageRoute(builder: (_) => const PresensiPage()),
            ),
            ),
            _MenuCard(
              ikon: Icons.menu_book_outlined,
              warnaIkon: const Color(0xFF2563EB),
              bgIkon: const Color(0xFFDBEAFE),
              judul: 'Jurnal Kegiatan',
              deskripsi: 'Tinjau jurnal harian dan progres kegiatan PKL.',
              onTap: () => _buka(context, 'Jurnal Kegiatan'),
            ),
          ],
        ),
      ),
    );
  }

  // Sementara hanya menampilkan snackbar. Ganti dengan Navigator.push
  // ke halaman tujuan saat halamannya sudah dibuat.
  void _buka(BuildContext context, String nama) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buka halaman $nama')),
    );
  }

  Widget _buildRingkasan() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0284C7), Color(0xFF7DD3FC)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ringkasan hari ini',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '$dummyJumlahSiswaTerpantau\nsiswa\nterpantau',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.show_chart, size: 40, color: Colors.white),
        ],
      ),
    );
  }
}

// ============================================================
// KOMPONEN KARTU MENU
// ============================================================
class _MenuCard extends StatelessWidget {
  final IconData ikon;
  final Color warnaIkon;
  final Color bgIkon;
  final String judul;
  final String deskripsi;
  final VoidCallback onTap;

  const _MenuCard({
    required this.ikon,
    required this.warnaIkon,
    required this.bgIkon,
    required this.judul,
    required this.deskripsi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF0FBFF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgIkon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikon, color: warnaIkon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deskripsi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}