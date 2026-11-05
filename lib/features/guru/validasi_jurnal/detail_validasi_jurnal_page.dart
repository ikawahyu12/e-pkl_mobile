import 'package:flutter/material.dart';

class DetailValidasiJurnalPage extends StatefulWidget {
  final Map<String, dynamic> jurnalData;

  const DetailValidasiJurnalPage({super.key, required this.jurnalData});

  @override
  State<DetailValidasiJurnalPage> createState() =>
      _DetailValidasiJurnalPageState();
}

class _DetailValidasiJurnalPageState extends State<DetailValidasiJurnalPage> {
  late String selectedStatus;

  final TextEditingController catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedStatus = widget.jurnalData['status'] ?? 'Menunggu';

    catatanController.text = widget.jurnalData['catatan'] ?? '';
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.jurnalData;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Detail',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMASI SISWA
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['namaSiswa'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF182238),
                          ),
                        ),
                      ),
                      _buildStatusBadge(data['status'] ?? 'Menunggu'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['kelas']} • ${data['tanggal']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8493AA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['judul'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF506078),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DETAIL KEGIATAN
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInformation(
                          'TANGGAL KEGIATAN',
                          _formatTanggal(data['tanggal']),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInformation(
                          'SHIFT KERJA',
                          data['shift'] ?? '-',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),

                  _buildSectionTitle('LAPORAN KEGIATAN'),

                  const SizedBox(height: 8),

                  Text(
                    data['laporan'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF506078),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 16),

                  _buildSectionTitle('DOKUMENTASI KEGIATAN'),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File dokumentasi belum terhubung.'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 30,
                            color: Color(0xFF7084A3),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              data['dokumentasi'] ?? 'Tidak ada dokumentasi',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF7084A3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FORM VALIDASI
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('VALIDASI GURU PEMBIMBING'),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDecisionButton(
                          title: 'Setujui Jurnal',
                          icon: Icons.check_circle_outline,
                          status: 'Disetujui',
                          activeColor: const Color(0xFF00A875),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDecisionButton(
                          title: 'Butuh Revisi',
                          icon: Icons.error_outline,
                          status: 'Revisi',
                          activeColor: const Color(0xFFE49A36),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildSectionTitle('CATATAN PEMBIMBING (OPSIONAL)'),

                  const SizedBox(height: 10),

                  TextField(
                    controller: catatanController,
                    maxLines: 4,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Tulis saran atau instruksi revisi di sini...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9BAAC0),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDCE3EE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDCE3EE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1677FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _kirimKeputusan,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF1677FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kirim Keputusan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // CARD
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }

  // INFORMASI
  Widget _buildInformation(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7084A3),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF182238),
          ),
        ),
      ],
    );
  }

  // JUDUL BAGIAN
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7084A3),
        letterSpacing: 0.3,
      ),
    );
  }

  // PEMBATAS
  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFEDF1F6));
  }

  // BADGE STATUS
  Widget _buildStatusBadge(String status) {
    Color background;
    Color foreground;
    String label;

    if (status == 'Disetujui') {
      background = const Color(0xFFE9FAF2);
      foreground = const Color(0xFF009B70);
      label = 'Disetujui';
    } else if (status == 'Revisi') {
      background = const Color(0xFFFFF0F0);
      foreground = const Color(0xFFE83C46);
      label = 'Perlu Revisi';
    } else {
      background = const Color(0xFFFFF5E9);
      foreground = const Color(0xFFE96B16);
      label = 'Menunggu';
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
          Icon(Icons.circle, size: 7, color: foreground),
          const SizedBox(width: 5),
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

  // TOMBOL KEPUTUSAN
  Widget _buildDecisionButton({
    required String title,
    required IconData icon,
    required String status,
    required Color activeColor,
  }) {
    final bool isSelected = selectedStatus == status;

    return SizedBox(
      height: 43,
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() {
            selectedStatus = status;
          });
        },
        icon: Icon(
          icon,
          size: 17,
          color: isSelected ? activeColor : const Color(0xFF7084A3),
        ),
        label: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? activeColor : const Color(0xFF34445F),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: isSelected
              ? activeColor.withOpacity(0.06)
              : Colors.white,
          side: BorderSide(
            color: isSelected ? activeColor : const Color(0xFFDCE3EE),
            width: isSelected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // FORMAT TANGGAL
  String _formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';

    return tanggal.toString().startsWith('Selasa,')
        ? tanggal.toString()
        : 'Selasa, ${tanggal.toString()}';
  }

  // KIRIM KEPUTUSAN
  void _kirimKeputusan() {
    if (selectedStatus == 'Revisi' && catatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi catatan revisi terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, <String, dynamic>{
      'status': selectedStatus,
      'catatan': catatanController.text.trim(),
    });
  }
}
