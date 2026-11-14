// Simpan di: lib/features/guru/agenda/tambah_agenda_page.dart (timpa file lama)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/agenda_repository.dart';
import '../../../data/repositories/agenda_repository_api.dart';
import 'agenda_data.dart';

/// Hasil yang dikembalikan saat jadwal disimpan (lewat Navigator.pop).
class HasilTambahAgenda {
  final DateTime tanggal;
  final AgendaItem item;
  const HasilTambahAgenda(this.tanggal, this.item);
}

// ============================================================
// HALAMAN TAMBAH AGENDA
// ============================================================
class TambahAgendaPage extends StatefulWidget {
  /// Tanggal awal yang terisi di form (biasanya tanggal yang sedang dipilih).
  final DateTime tanggalAwal;

  /// Kalau null, memakai AgendaRepositoryApi.
  final AgendaRepository? repository;

  const TambahAgendaPage({
    super.key,
    required this.tanggalAwal,
    this.repository,
  });

  @override
  State<TambahAgendaPage> createState() => _TambahAgendaPageState();
}

class _TambahAgendaPageState extends State<TambahAgendaPage> {
  static const _biru = Color(0xFF1D6FFF);
  static const _gelap = Color(0xFF0F172A);
  static const _abu = Color(0xFF64748B);

  late final AgendaRepository _repo;

  List<TempatOpsi> _opsi = const [];
  bool _memuat = true;
  String? _error;

  TempatOpsi? _tempat;
  Set<int> _siswaDipilih = {};
  late DateTime _tanggal = widget.tanggalAwal;
  TimeOfDay _mulai = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selesai = const TimeOfDay(hour: 10, minute: 0);
  final _catatan = TextEditingController();
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AgendaRepositoryApi();
    _muatOpsi();
  }

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _muatOpsi() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final opsi = await _repo.ambilOpsi();
      if (!mounted) return;
      setState(() {
        _opsi = opsi;
        _memuat = false;
        if (opsi.isNotEmpty) _pilihTempat(opsi.first);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
        _error = _pesan(e);
      });
    }
  }

  String _pesan(Object e) => e.toString().replaceFirst('Exception: ', '');

  String _fmtJam(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  /// Format 24 jam untuk dikirim ke server: "09:00".
  String _jam24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _menit(TimeOfDay t) => t.hour * 60 + t.minute;

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  /// Pilih tempat dan otomatis centang semua siswanya.
  void _pilihTempat(TempatOpsi t) {
    _tempat = t;
    _siswaDipilih = t.siswa.map((s) => s.id).toSet();
  }

  void _gantiTempat(TempatOpsi? baru) {
    if (baru == null) return;
    setState(() => _pilihTempat(baru));
  }

  void _toggleSiswa(int id) {
    setState(() {
      if (!_siswaDipilih.remove(id)) _siswaDipilih.add(id);
    });
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam({required bool mulai}) async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: mulai ? _mulai : _selesai,
    );
    if (hasil == null) return;
    setState(() => mulai ? _mulai = hasil : _selesai = hasil);
  }

  Future<void> _simpan() async {
    final tempat = _tempat;
    if (tempat == null) {
      _snack('Pilih tempat PKL terlebih dahulu.');
      return;
    }
    if (_siswaDipilih.isEmpty) {
      _snack('Pilih minimal satu siswa.');
      return;
    }
    if (_menit(_selesai) <= _menit(_mulai)) {
      _snack('Waktu selesai harus setelah waktu mulai.');
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final catatan = _catatan.text.trim();
      final item = await _repo.tambah(
        instansiId: tempat.instansiId,
        siswaIds: _siswaDipilih.toList(),
        tanggal: _tanggal,
        jamMulai: _jam24(_mulai),
        jamSelesai: _jam24(_selesai),
        catatan: catatan.isEmpty ? null : catatan,
      );
      if (!mounted) return;
      Navigator.pop(context, HasilTambahAgenda(_tanggal, item));
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      _snack(_pesan(e));
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Tambah Agenda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1D6FFF), Color(0xFF5BB0FF)],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_memuat) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return _PesanTengah(
        pesan: _error!,
        aksi: FilledButton(onPressed: _muatOpsi, child: const Text('Coba lagi')),
      );
    }

    if (_opsi.isEmpty) {
      return const _PesanTengah(
        pesan: 'Belum ada tempat PKL dengan siswa bimbingan Anda.\n'
            'Agenda kunjungan bisa dibuat setelah siswa ditempatkan.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildBanner(),
        const SizedBox(height: 14),
        _buildKartuTujuan(),
        const SizedBox(height: 14),
        _buildKartuWaktu(),
        const SizedBox(height: 14),
        _buildKartuCatatan(),
        const SizedBox(height: 18),
        _buildTombolSimpan(),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Jadwal akan ditambahkan ke Agenda Monitoring.',
            style: TextStyle(fontSize: 11, color: _abu),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3E4FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_calendar_outlined, size: 22, color: _biru),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dampingi siswa, rencanakan kunjungan.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _gelap,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lengkapi isian bertanda * untuk menyimpan.',
                  style: TextStyle(fontSize: 11, color: _abu),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu 1: tujuan kunjungan ----------
  Widget _buildKartuTujuan() {
    final tempat = _tempat!;
    return _Kartu(
      judul: 'Tujuan kunjungan',
      children: [
        const _Label('Tempat PKL', wajib: true),
        const SizedBox(height: 6),
        _Kotak(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TempatOpsi>(
              value: tempat,
              isExpanded: true,
              itemHeight: 64,
              icon: const Icon(Icons.keyboard_arrow_down, color: _gelap),
              onChanged: _menyimpan ? null : _gantiTempat,
              items: _opsi
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          const _IkonKotak(Icons.apartment),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.nama,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _gelap,
                                  ),
                                ),
                                Text(
                                  t.alamat,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: _abu),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const _Label('Siswa bimbingan', wajib: true),
            const Spacer(),
            Text(
              '${_siswaDipilih.length} dipilih',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _biru,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Pilih siswa yang akan dikunjungi di tempat ini.',
          style: TextStyle(fontSize: 11, color: _abu),
        ),
        const SizedBox(height: 8),
        ...tempat.siswa.map(_buildBarisSiswa),
      ],
    );
  }

  Widget _buildBarisSiswa(SiswaOpsi s) {
    final inisial = s.nama
        .split(' ')
        .where((k) => k.isNotEmpty)
        .take(2)
        .map((k) => k[0].toUpperCase())
        .join();

    return InkWell(
      onTap: _menyimpan ? null : () => _toggleSiswa(s.id),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Text(
                inisial,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _biru,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _gelap,
                    ),
                  ),
                  Text(
                    s.kelas,
                    style: const TextStyle(fontSize: 11, color: _abu),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: _siswaDipilih.contains(s.id),
              onChanged: _menyimpan ? null : (_) => _toggleSiswa(s.id),
              activeColor: _biru,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Kartu 2: waktu kunjungan ----------
  Widget _buildKartuWaktu() {
    return _Kartu(
      judul: 'Waktu kunjungan',
      children: [
        const _Label('Tanggal kunjungan', wajib: true),
        const SizedBox(height: 6),
        _Kotak(
          onTap: _menyimpan ? null : _pilihTanggal,
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  size: 20, color: _biru),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DateFormat('EEEE, d MMMM y', 'id_ID').format(_tanggal),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _gelap,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: _gelap),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildKolomJam(
                label: 'Waktu mulai',
                jam: _mulai,
                onTap: _menyimpan ? null : () => _pilihJam(mulai: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKolomJam(
                label: 'Waktu selesai',
                jam: _selesai,
                onTap: _menyimpan ? null : () => _pilihJam(mulai: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKolomJam({
    required String label,
    required TimeOfDay jam,
    required VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label, wajib: true),
        const SizedBox(height: 6),
        _Kotak(
          onTap: onTap,
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: _biru),
              const SizedBox(width: 8),
              Text(
                _fmtJam(jam),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _gelap,
                ),
              ),
              const SizedBox(width: 4),
              const Text('WIB', style: TextStyle(fontSize: 10, color: _abu)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Kartu 3: catatan ----------
  Widget _buildKartuCatatan() {
    return _Kartu(
      children: [
        const Text(
          'Catatan (opsional)',
          style: TextStyle(fontSize: 12, color: _abu),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _catatan,
          enabled: !_menyimpan,
          maxLines: 4,
          maxLength: 300,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Tambahkan tujuan atau hal yang perlu disiapkan saat '
                'kunjungan...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _biru),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTombolSimpan() {
    return GestureDetector(
      onTap: _menyimpan ? null : _simpan,
      child: Opacity(
        opacity: _menyimpan ? 0.7 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF1D6FFF), Color(0xFF5BB0FF)],
            ),
          ),
          child: _menyimpan
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Simpan Jadwal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================================
// KOMPONEN KECIL (khusus halaman ini)
// ============================================================
class _PesanTengah extends StatelessWidget {
  final String pesan;
  final Widget? aksi;

  const _PesanTengah({required this.pesan, this.aksi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pesan, textAlign: TextAlign.center),
            if (aksi != null) ...[const SizedBox(height: 12), aksi!],
          ],
        ),
      ),
    );
  }
}

class _Kartu extends StatelessWidget {
  final String? judul;
  final List<Widget> children;

  const _Kartu({this.judul, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (judul != null) ...[
            Text(
              judul!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String teks;
  final bool wajib;

  const _Label(this.teks, {this.wajib = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: teks,
        children: [
          if (wajib)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFF1D6FFF)),
            ),
        ],
      ),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }
}

class _Kotak extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Kotak({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: child,
      ),
    );
  }
}

class _IkonKotak extends StatelessWidget {
  final IconData ikon;
  const _IkonKotak(this.ikon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(ikon, size: 20, color: const Color(0xFF1D6FFF)),
    );
  }
}