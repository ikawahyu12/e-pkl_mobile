import 'package:flutter/material.dart';
import 'detail_validasi_jurnal_page.dart';

class ValidasiJurnalPage extends StatefulWidget {
  const ValidasiJurnalPage({super.key});

  @override
  State<ValidasiJurnalPage> createState() => _ValidasiJurnalPageState();
}

class _ValidasiJurnalPageState extends State<ValidasiJurnalPage> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> listJurnal = [
    {
      'id': '1',
      'namaSiswa': 'Ahmad Rizky Pratama',
      'kelas': 'Kelas XI RPL 1',
      'tanggal': '13 Jan 2026',
      'judul': 'Redesign layout login page & setting database',
      'shift': 'Shift Pagi (07:00-12:00)',
      'laporan':
          'Melakukan integrasi API login, perbaikan state management token JWT, serta testing manual fungsionalitas tombol navigasi pada 3 browser berbeda di lingkungan staging.',
      'dokumentasi': 'Dokumentasi_PKL_13_Jan.png',
      'status': 'Menunggu',
      'catatan': '',
    },
    {
      'id': '2',
      'namaSiswa': 'Budi Santoso',
      'kelas': 'Kelas XI RPL 1',
      'tanggal': '13 Jan 2026',
      'judul': 'Slicing UI dashboard siswa menggunakan Tailwind...',
      'shift': 'Shift Pagi (07:00-12:00)',
      'laporan':
          'Membuat tampilan antarmuka dashboard siswa menggunakan Tailwind CSS dan melakukan penyesuaian responsif.',
      'dokumentasi': 'dokumentasi_budi.png',
      'status': 'Disetujui',
      'catatan': '',
    },
    {
      'id': '3',
      'namaSiswa': 'Citra Lestari',
      'kelas': 'Kelas XI RPL 2',
      'tanggal': '12 Jan 2026',
      'judul': 'Fixing bug route API middleware auth dan testing...',
      'shift': 'Shift Siang (13:00-17:00)',
      'laporan':
          'Memperbaiki bug pada middleware autentikasi dan melakukan pengujian API.',
      'dokumentasi': 'dokumentasi_citra.png',
      'status': 'Revisi',
      'catatan': 'Perbaiki kembali validasi autentikasi API.',
    },
    {
      'id': '4',
      'namaSiswa': 'Dika Pratama',
      'kelas': 'Kelas XI RPL 1',
      'tanggal': '12 Jan 2026',
      'judul': 'Setup Docker container untuk environment testing...',
      'shift': 'Shift Pagi (07:00-12:00)',
      'laporan':
          'Melakukan konfigurasi Docker container untuk kebutuhan environment testing aplikasi.',
      'dokumentasi': 'dokumentasi_dika.png',
      'status': 'Disetujui',
      'catatan': '',
    },
  ];

  List<Map<String, dynamic>> get filteredList {
    if (selectedTab == 1) {
      return listJurnal.where((j) => j['status'] == 'Menunggu').toList();
    }

    if (selectedTab == 2) {
      return listJurnal.where((j) => j['status'] == 'Disetujui').toList();
    }

    if (selectedTab == 3) {
      return listJurnal.where((j) => j['status'] == 'Revisi').toList();
    }

    return listJurnal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ], // Sesuaikan gradasi birunya
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors
                .transparent, // Bikin transparan supaya gradasinya kelihatan
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Jurnal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Semua', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Menunggu', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Disetujui', 2),
                  const SizedBox(width: 8),
                  _buildTabButton('Revisi', 3),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada jurnal',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final result =
                              await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailValidasiJurnalPage(
                                        jurnalData: item,
                                      ),
                                ),
                              );

                          if (result != null && mounted) {
                            setState(() {
                              item['status'] = result['status'];
                              item['catatan'] = result['catatan'] ?? '';
                            });

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['status'] == 'Disetujui'
                                        ? 'Jurnal berhasil disetujui'
                                        : 'Jurnal dikirim untuk revisi',
                                  ),
                                  backgroundColor:
                                      result['status'] == 'Disetujui'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.035),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['namaSiswa'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF182238),
                                      ),
                                    ),
                                  ),
                                  _buildBadgeStatus(item['status']),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['kelas']} • ${item['tanggal']}',
                                style: const TextStyle(
                                  color: Color(0xFF8493AA),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['judul'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF506078),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1677FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1677FF)
                : const Color(0xFFDCE3EE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF34445F),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeStatus(String status) {
    Color background;
    Color foreground;
    String label;
    IconData icon;

    switch (status) {
      case 'Disetujui':
        background = const Color(0xFFE9FAF2);
        foreground = const Color(0xFF009B70);
        label = 'Disetujui';
        icon = Icons.circle;
        break;

      case 'Revisi':
        background = const Color(0xFFFFF0F0);
        foreground = const Color(0xFFE83C46);
        label = 'Perlu Revisi';
        icon = Icons.circle;
        break;

      default:
        background = const Color(0xFFFFF5E9);
        foreground = const Color(0xFFE96B16);
        label = 'Menunggu';
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 7, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
