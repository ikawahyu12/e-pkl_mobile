import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuatPresensiPage extends StatefulWidget {
  const BuatPresensiPage({Key? key}) : super(key: key);

  @override
  State<BuatPresensiPage> createState() => _BuatPresensiPageState();
}

class _BuatPresensiPageState extends State<BuatPresensiPage> {
  // --- STATE INTERAKTIF ---
  String _selectedInstansi = 'SMK Negeri 1 Bandung';
  final List<String> _instansiList = [
    'SMK Negeri 1 Bandung',
    'SMK Negeri 2 Bandung',
    'SMK Negeri 3 Bandung',
  ];

  DateTime _selectedDate = DateTime.now();

  String _selectedShift = 'Pagi';

  // UBAH TIPE DATA MENJADI TimeOfDay AGAR BISA DIUBAH
  TimeOfDay _jamCheckIn = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _jamCheckOut = const TimeOfDay(hour: 12, minute: 0);

  bool _isSaving = false;

  // Data siswa
  final List<Map<String, dynamic>> _siswaList = [
    {
      'id': 1,
      'nama': 'Ahmad Rizky Pratama',
      'nis': '1234567890',
      'kelas': 'XI RPL 1',
      'hadir': true,
    },
    {
      'id': 2,
      'nama': 'Budi Santoso',
      'nis': '1234567891',
      'kelas': 'XI RPL 1',
      'hadir': true,
    },
    {
      'id': 3,
      'nama': 'Citra Lestari',
      'nis': '1234567892',
      'kelas': 'XI RPL 2',
      'hadir': false,
    },
  ];

  // --- FUNGSI PILIH TANGGAL ---
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF48A2E6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- FUNGSI BARU: PILIH JAM (CHECK-IN / CHECK-OUT) ---
  Future<void> _pilihJam(bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _jamCheckIn : _jamCheckOut,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF48A2E6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _jamCheckIn = picked;
        } else {
          _jamCheckOut = picked;
        }
      });
    }
  }

  void _tambahSiswa() {
    showDialog(
      context: context,
      builder: (context) {
        String newNama = '';
        String newNis = '';
        return AlertDialog(
          title: const Text('Tambah Siswa Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nama Siswa'),
                onChanged: (val) => newNama = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'NIS'),
                onChanged: (val) => newNis = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newNama.isNotEmpty && newNis.isNotEmpty) {
                  setState(() {
                    _siswaList.add({
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'nama': newNama,
                      'nis': newNis,
                      'kelas': 'Manual',
                      'hadir': true,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpanPresensi() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSaving = false);

    if (mounted) {
      // Format jam ke string untuk dikirim ke API
      String formattedCheckIn =
          '${_jamCheckIn.hour.toString().padLeft(2, '0')}:${_jamCheckIn.minute.toString().padLeft(2, '0')}';
      String formattedCheckOut =
          '${_jamCheckOut.hour.toString().padLeft(2, '0')}:${_jamCheckOut.minute.toString().padLeft(2, '0')}';

      print("=== DATA YANG DIKIRIM ===");
      print("Instansi: $_selectedInstansi");
      print("Tanggal : ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
      print("Shift   : $_selectedShift");
      print("Batas Check-In : $formattedCheckIn");
      print("Batas Check-Out: $formattedCheckOut");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Data presensi berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu ke string untuk ditampilkan di UI
    final timeCheckInStr =
        '${_jamCheckIn.hour.toString().padLeft(2, '0')}:${_jamCheckIn.minute.toString().padLeft(2, '0')}';
    final timeCheckOutStr =
        '${_jamCheckOut.hour.toString().padLeft(2, '0')}:${_jamCheckOut.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF48A2E6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Presensi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLabel("PILIH INSTANSI"),
          DropdownButtonFormField<String>(
            value: _selectedInstansi,
            decoration: _inputDecoration(),
            icon: const Icon(Icons.business, color: Colors.blue),
            items: _instansiList.map((String instansi) {
              return DropdownMenuItem<String>(
                value: instansi,
                child: Text(instansi, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _selectedInstansi = newValue!);
            },
          ),
          const SizedBox(height: 16),

          _buildLabel("TANGGAL ABSENSI"),
          InkWell(
            onTap: _pilihTanggal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: _boxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildLabel("PILIH SHIFT"),
          Row(
            children: [
              Expanded(
                child: _buildShiftCard(
                  "Shift Pagi",
                  "07:00 - 12:00",
                  _selectedShift == 'Pagi',
                  () => setState(() {
                    _selectedShift = 'Pagi';
                    // Opsional: Reset jam ke default jika ganti shift
                    _jamCheckIn = const TimeOfDay(hour: 7, minute: 30);
                    _jamCheckOut = const TimeOfDay(hour: 12, minute: 0);
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShiftCard(
                  "Shift Sore",
                  "13:00 - 17:00",
                  _selectedShift == 'Sore',
                  () => setState(() {
                    _selectedShift = 'Sore';
                    // Opsional: Reset jam ke default jika ganti shift
                    _jamCheckIn = const TimeOfDay(hour: 12, minute: 0);
                    _jamCheckOut = const TimeOfDay(hour: 17, minute: 0);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- BAGIAN JAM YANG SUDAH DINAMIS ---
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  "BATAS CHECK-IN",
                  timeCheckInStr,
                  () => _pilihJam(true), // Panggil fungsi ubah jam Check-In
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeInfo(
                  "BATAS CHECK-OUT",
                  timeCheckOutStr,
                  () => _pilihJam(false), // Panggil fungsi ubah jam Check-Out
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("PILIH SISWA"),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _tambahSiswa,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Tambah", style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () {
                      bool allSelected = _siswaList.every(
                        (s) => s['hadir'] == true,
                      );
                      setState(() {
                        for (var s in _siswaList) {
                          s['hadir'] = !allSelected;
                        }
                      });
                    },
                    child: const Text(
                      "Pilih Semua",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._siswaList.map((siswa) => _buildSiswaCard(siswa)).toList(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _simpanPresensi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48A2E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Simpan Absensi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF48A2E6)),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildShiftCard(
    String title,
    String time,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF48A2E6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF48A2E6) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF48A2E6)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? const Color(0xFF48A2E6) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFIKASI: WIDGET JAM KINI BISA DIKLIK (onTap) ---
  Widget _buildTimeInfo(String title, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.blue,
                ), // Ikon tambahan sebagai penanda bisa diedit
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaCard(Map<String, dynamic> siswa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF48A2E6).withOpacity(0.2),
            child: Text(
              siswa['nama'].substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF48A2E6),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa['nama'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "NIS. ${siswa['nis']} • ${siswa['kelas']}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Checkbox(
            value: siswa['hadir'],
            activeColor: const Color(0xFF48A2E6),
            onChanged: (val) {
              setState(() {
                siswa['hadir'] = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
