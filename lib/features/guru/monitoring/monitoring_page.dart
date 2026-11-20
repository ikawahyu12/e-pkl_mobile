import 'package:flutter/material.dart';

import '../../../shared/widgets/epkl_colors.dart';
import '../agenda/agenda_page.dart';
import '../informasi_jurnal/informasi_jurnal_page.dart';
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
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _kartuHeaderMonitoring(),
                      const SizedBox(height: 18),
                      const Text(
                        'Aktivitas Monitoring',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _biruGelap,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Pilih menu untuk mengelola kegiatan siswa.',
                        style: TextStyle(fontSize: 11, color: _abu),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _MenuCard(
                                ikon: Icons.event_note_outlined,
                                warnaIkon: const Color(0xFFD97706),
                                bgIkon: const Color(0xFFFEF3C7),
                                judul: 'Agenda',
                                deskripsi:
                                    'Kelola agenda kunjungan ke tempat PKL siswa.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AgendaPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _MenuCard(
                                ikon: Icons.event_available_outlined,
                                warnaIkon: const Color(0xFF059669),
                                bgIkon: const Color(0xFFD1FAE5),
                                judul: 'Presensi',
                                deskripsi:
                                    'Buat presensi dan lihat rekap kehadiran siswa.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PresensiPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _MenuCard(
                                ikon: Icons.menu_book_outlined,
                                warnaIkon: const Color(0xFF2563EB),
                                bgIkon: const Color(0xFFDBEAFE),
                                judul: 'Jurnal Kegiatan',
                                deskripsi:
                                    'Tinjau jurnal harian dan progres kegiatan PKL.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InformasiJurnalPage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kartuHeaderMonitoring() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: EpklColors.gradienUtama,
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 21,
                  color: Color(0xFF1677FF),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pantau presensi dan aktivitas PKL siswa bimbingan Anda.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan hari ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: _abu,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '$dummyJumlahSiswaTerpantau siswa terpantau',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: _biruGelap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    size: 23,
                    color: Color(0xFF1677FF),
                  ),
                ),
              ],
            ),
          ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7EDF5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF183153).withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgIkon,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(ikon, color: warnaIkon, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F6FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8291A5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
