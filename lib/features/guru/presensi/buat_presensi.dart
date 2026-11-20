import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

<<<<<<< HEAD
import '../../../data/repositories/agenda_repository_api.dart';
import '../../../data/repositories/guru_auth_repository_api.dart';
import '../../../data/repositories/instansi_repository.dart';
=======
import '../../../shared/widgets/epkl_widgets.dart';
>>>>>>> d55eb30 (Upgrade Ui)

class BuatPresensiPage extends StatefulWidget {
  final AgendaRepository? agendaRepository;
  final InstansiRepository? instansiRepository;

  const BuatPresensiPage({
    super.key,
    this.agendaRepository,
    this.instansiRepository,
  });

  @override
  State<BuatPresensiPage> createState() => _BuatPresensiPageState();
}

class _BuatPresensiPageState extends State<BuatPresensiPage> {
  late final AgendaRepository _agendaRepository =
      widget.agendaRepository ??
      AgendaRepositoryApi(authRepository: GuruAuthRepositoryApi());
  late final InstansiRepository _instansiRepository =
      widget.instansiRepository ?? InstansiRepository();

  List<InstansiOption> _instansiList = [];
  List<AgendaInstansiOption> _opsiInstansiSiswa = [];
  int? _selectedInstansiId;
  bool _memuatInstansi = true;
  bool _memuatSiswa = true;
  String? _errorInstansi;
  String? _errorSiswa;
  final Set<int> _siswaHadir = {};
  int _siswaLoadId = 0;

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _jamCheckIn = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _jamCheckOut = const TimeOfDay(hour: 12, minute: 0);

  AgendaInstansiOption? get _instansiSiswaTerpilih {
    for (final opsi in _opsiInstansiSiswa) {
      if (opsi.id == _selectedInstansiId) return opsi;
    }
    return null;
  }

  List<AgendaSiswaOption> get _siswaList =>
      _instansiSiswaTerpilih?.siswa ?? const [];

  @override
  void initState() {
    super.initState();
    _muatInstansi();
    _muatSiswa();
  }

  Future<void> _muatInstansi() async {
    setState(() {
      _memuatInstansi = true;
      _errorInstansi = null;
    });
    try {
      final instansi = await _instansiRepository.ambilDaftar();
      if (!mounted) return;
      setState(() {
        _instansiList = instansi;
        if (!_instansiList.any((item) => item.id == _selectedInstansiId)) {
          _selectedInstansiId = _instansiList.isEmpty
              ? null
              : _instansiList.first.id;
        }
        _siswaHadir.addAll(_siswaList.map((siswa) => siswa.id));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorInstansi = error.toString());
    } finally {
      if (mounted) setState(() => _memuatInstansi = false);
    }
  }

  Future<void> _muatSiswa() async {
    final loadId = ++_siswaLoadId;
    setState(() {
      _memuatSiswa = true;
      _errorSiswa = null;
      _opsiInstansiSiswa = [];
      _siswaHadir.clear();
    });
    try {
      final options = await _agendaRepository.ambilOpsi(_selectedDate);
      if (!mounted || loadId != _siswaLoadId) return;
      setState(() {
        _opsiInstansiSiswa = options;
        _siswaHadir.addAll(_siswaList.map((siswa) => siswa.id));
      });
    } catch (error) {
      if (!mounted || loadId != _siswaLoadId) return;
      setState(() => _errorSiswa = error.toString());
    } finally {
      if (mounted && loadId == _siswaLoadId) {
        setState(() => _memuatSiswa = false);
      }
    }
  }

  void _pilihInstansi(int? instansiId) {
    if (instansiId == null) return;
    setState(() {
      _selectedInstansiId = instansiId;
      _siswaHadir
        ..clear()
        ..addAll(_siswaList.map((siswa) => siswa.id));
    });
  }

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
    if (mounted && picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _muatSiswa();
    }
  }

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

    if (mounted && picked != null) {
      setState(() {
        if (isCheckIn) {
          _jamCheckIn = picked;
        } else {
          _jamCheckOut = picked;
        }
      });
    }
  }

  void _simpanPresensi() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend belum tersedia'),
        content: const Text(
          'Form ini masih berupa prototipe. Data presensi belum disimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
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
      appBar: const EpklGradientAppBar(judul: 'Buat Presensi'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLabel("PILIH INSTANSI"),
          DropdownButtonFormField<int>(
            key: ValueKey(_selectedInstansiId),
            initialValue: _selectedInstansiId,
            isExpanded: true,
            hint: Text(
              _memuatInstansi
                  ? 'Memuat instansi...'
                  : _instansiList.isEmpty
                  ? 'Tidak ada instansi aktif'
                  : 'Pilih instansi',
            ),
            decoration: _inputDecoration(),
            icon: const Icon(Icons.business, color: Colors.blue),
            items: _instansiList.map((instansi) {
              return DropdownMenuItem<int>(
                value: instansi.id,
                child: Text(
                  instansi.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: _memuatInstansi || _instansiList.isEmpty
                ? null
                : _pilihInstansi,
          ),
          if (_errorInstansi != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorInstansi!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _muatInstansi,
                child: const Text('Coba lagi'),
              ),
            ),
          ],
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
                  Expanded(
                    child: Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(_selectedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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

          _responsivePair(
            _buildTimeInfo(
              "BATAS CHECK-IN",
              timeCheckInStr,
              () => _pilihJam(true),
            ),
            _buildTimeInfo(
              "BATAS CHECK-OUT",
              timeCheckOutStr,
              () => _pilihJam(false),
            ),
          ),
          const SizedBox(height: 24),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLabel("PILIH SISWA"),
              TextButton(
                onPressed: () {
                  final allSelected = _siswaList.every(
                    (siswa) => _siswaHadir.contains(siswa.id),
                  );
                  setState(() {
                    if (allSelected) {
                      _siswaHadir.clear();
                    } else {
                      _siswaHadir.addAll(_siswaList.map((siswa) => siswa.id));
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
          const SizedBox(height: 8),
          if (_memuatSiswa)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorSiswa != null)
            Column(
              children: [
                Text(
                  _errorSiswa!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                TextButton(
                  onPressed: _muatSiswa,
                  child: const Text('Coba lagi'),
                ),
              ],
            )
          else if (_siswaList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                _selectedInstansiId == null
                    ? 'Pilih instansi untuk melihat daftar siswa.'
                    : 'Tidak ada siswa untuk instansi ini pada tanggal terpilih.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._siswaList.map(_buildSiswaCard),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _simpanPresensi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48A2E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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

  Widget _responsivePair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                Expanded(
                  child: Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.edit, size: 14, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaCard(AgendaSiswaOption siswa) {
    final nama = siswa.nama.trim();
    final initials = nama.isEmpty
        ? '?'
        : nama.substring(0, nama.length < 2 ? nama.length : 2).toUpperCase();
    final detail = [
      if (siswa.nis != null && siswa.nis!.isNotEmpty) 'NIS. ${siswa.nis}',
      if (siswa.kelas != null && siswa.kelas!.isNotEmpty) siswa.kelas!,
    ].join(' • ');
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
            backgroundColor: const Color(0xFF48A2E6).withValues(alpha: 0.2),
            child: Text(
              initials,
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
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Checkbox(
            value: _siswaHadir.contains(siswa.id),
            activeColor: const Color(0xFF48A2E6),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _siswaHadir.add(siswa.id);
                } else {
                  _siswaHadir.remove(siswa.id);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
