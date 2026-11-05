import 'package:flutter/material.dart';
import 'buat_presensi.dart';
import '../monitoring/monitoring_page.dart';
class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  bool _isLoading = false;
  String _infoMessage = 'Presensi hari ini dapat diisi sampai pukul 16.00 WIB.';
  bool _isPresensiHariIniSelesai = false;

  @override
  void initState() {
    super.initState();
    _fetchDataPresensi();
  }

  Future<void> _fetchDataPresensi() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _isPresensiHariIniSelesai = false;
      _infoMessage = 'Presensi hari ini dapat diisi sampai pukul 16.00 WIB.';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF48A2E6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Presensi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDataPresensi,
          ),
        ],
      ),
      body: Column(
        children: [
          // ... (SISA KODE BODY TETAP SAMA SEPERTI SEBELUMNYA) ...
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: const Color(0xFF48A2E6),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MONITORING",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Pilih kebutuhan presensi siswa bimbingan.",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildOptionCard(
                        context,
                        icon: Icons.assignment_turned_in_outlined,
                        title: "Buat Presensi",
                        subtitle: _isPresensiHariIniSelesai
                            ? "Presensi hari ini sudah dibuat."
                            : "Catat kehadiran seluruh siswa untuk hari ini.",
                        onTap: _isPresensiHariIniSelesai
                            ? null
                            : () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BuatPresensiPage(),
                                  ),
                                );
                                _fetchDataPresensi();
                              },
                      ),
                      const SizedBox(height: 16),
                      _buildOptionCard(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: "Rekap Kehadiran",
                        subtitle:
                            "Lihat ringkasan dan riwayat kehadiran siswa.",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Halaman Rekap Kehadiran belum tersedia.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isPresensiHariIniSelesai
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPresensiHariIniSelesai
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              color: _isPresensiHariIniSelesai
                                  ? Colors.green
                                  : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isPresensiHariIniSelesai
                                    ? "Presensi untuk hari ini telah berhasil disimpan."
                                    : _infoMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isPresensiHariIniSelesai
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF48A2E6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
