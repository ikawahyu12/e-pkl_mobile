import 'package:flutter/material.dart';

class RekapKehadiranPage extends StatefulWidget {
  const RekapKehadiranPage({Key? key}) : super(key: key);

  @override
  State<RekapKehadiranPage> createState() => _RekapKehadiranPageState();
}

class _RekapKehadiranPageState extends State<RekapKehadiranPage> {
  // State untuk tab filter (0 = Minggu Ini, 1 = Bulan Ini)
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Warna background abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: const Color(0xFF48A2E6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rekap Kehadiran",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TAB FILTER (Minggu Ini / Bulan Ini)
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterTab("Minggu ini", 0),
                    _buildFilterTab("Bulan ini", 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. GRID STATISTIK (Hadir, Terlambat, Izin, Alpha)
            Row(
              children: [
                Expanded(child: _buildStatCard("Hadir", "45", Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard("Terlambat", "8", Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard("Izin", "3", Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Alpha", "2", Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            // 3. CARD TINGKAT KEHADIRAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Lingkaran Progress (Menggunakan Stack untuk simulasi visual)
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 0.77, // 77%
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                        const Center(
                          child: Text(
                            "77%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Teks Keterangan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tingkat Kehadiran",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Kehadiran kumulatif siswa di PT. Informatika Solusi Nusantara mencapai 77.6% semester ini.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. HEADER LIST SISWA
            const Text(
              "Kehadiran Per Siswa",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // 5. LIST SISWA DENGAN PROGRESS BAR
            _buildSiswaRekapItem(
              nama: "Ahmad Rizky Pratama",
              kelas: "XI RPL 1",
              persentase: 77.6,
              persentaseText: "77.6%",
              warnaPersentase: Colors.blue,
            ),
            _buildSiswaRekapItem(
              nama: "Budi Setiawan",
              kelas: "XI RPL 1",
              persentase: 96.5,
              persentaseText: "96.5%",
              warnaPersentase: Colors.green,
            ),
            _buildSiswaRekapItem(
              nama: "Citra Lestari",
              kelas: "XI RPL 2",
              persentase: 86.2,
              persentaseText: "86.2%",
              warnaPersentase: Colors.blue,
            ),
            _buildSiswaRekapItem(
              nama: "Deni Prasetyo",
              kelas: "XI RPL 2",
              persentase: 68.9,
              persentaseText: "68.9%",
              warnaPersentase: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Widget Tab Filter
  Widget _buildFilterTab(String text, int index) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1677FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget Kotak Statistik
  Widget _buildStatCard(String title, String count, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titik warna kecil di pojok kiri atas
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget List Siswa
  Widget _buildSiswaRekapItem({
    required String nama,
    required String kelas,
    required double persentase,
    required String persentaseText,
    required Color warnaPersentase,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar Inisial
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: Text(
                  nama.substring(0, 1),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nama & Kelas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kelas,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Persentase Text
              Text(
                persentaseText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: warnaPersentase,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar Multivarna (Simulasi visual seperti di Figma)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (persentase * 10).toInt(),
                    child: Container(color: Colors.green),
                  ),
                  Expanded(flex: 10, child: Container(color: Colors.orange)),
                  Expanded(flex: 5, child: Container(color: Colors.red)),
                  Expanded(
                    flex: 15,
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
