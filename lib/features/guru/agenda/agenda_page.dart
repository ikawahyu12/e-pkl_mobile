// Simpan di: lib/features/guru/agenda/agenda_page.dart (timpa file lama)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/agenda_repository.dart';
import '../../../data/repositories/agenda_repository_api.dart';
import 'agenda_data.dart';
import 'agenda_widgets.dart';
import 'tambah_agenda_page.dart';

class AgendaPage extends StatefulWidget {
  /// Kalau null, memakai AgendaRepositoryApi.
  final AgendaRepository? repository;

  const AgendaPage({super.key, this.repository});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final AgendaRepository _repo;
  DateTime _dipilih = hariIni();

  /// Agenda per tanggal (yyyy-MM-dd), diisi dari server per minggu.
  final Map<String, List<AgendaItem>> _cache = {};
  String? _mingguDimuat; // kunci hari Senin minggu yang sudah dimuat
  bool _memuat = false;
  String? _error;

  List<AgendaItem> get _agendaTerpilih =>
      _cache[kunciTanggal(_dipilih)] ?? const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AgendaRepositoryApi();
    _muatMinggu();
  }

  DateTime _senin(DateTime d) => DateTime(d.year, d.month, d.day)
      .subtract(Duration(days: d.weekday - 1));

  Future<void> _muatMinggu({bool paksa = false}) async {
    final senin = _senin(_dipilih);
    final kunci = kunciTanggal(senin);
    if (!paksa && kunci == _mingguDimuat) return;

    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final hasil = await _repo.ambilRentang(
        senin,
        senin.add(const Duration(days: 6)),
      );
      if (!mounted) return;
      // Abaikan respons lama kalau pengguna sudah pindah minggu.
      if (kunci != kunciTanggal(_senin(_dipilih))) return;
      setState(() {
        for (var i = 0; i < 7; i++) {
          _cache.remove(kunciTanggal(senin.add(Duration(days: i))));
        }
        _cache.addAll(hasil);
        _mingguDimuat = kunci;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (kunci != kunciTanggal(_senin(_dipilih))) return;
      setState(() {
        _memuat = false;
        _error = _pesan(e);
      });
    }
  }

  String _pesan(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _pilihTanggal(DateTime tgl) {
    setState(() => _dipilih = tgl);
    _muatMinggu();
  }

  void _geserMinggu(int arah) => _pilihTanggal(
        _dipilih.add(Duration(days: 7 * arah)),
      );

  Future<void> _tambahJadwal() async {
    final hasil = await Navigator.push<HasilTambahAgenda>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahAgendaPage(
          tanggalAwal: _dipilih,
          repository: _repo,
        ),
      ),
    );
    if (hasil == null || !mounted) return;

    setState(() => _dipilih = hasil.tanggal); // tampilkan tanggal jadwal baru
    await _muatMinggu(paksa: true);
    if (mounted) _snack('Jadwal berhasil ditambahkan');
  }

  // ---------- aksi pada kartu ----------

  Future<void> _aksiKartu(AgendaItem item) async {
    final id = item.id;
    if (id == null) return;
    final selesai = item.status == StatusAgenda.selesai;

    final aksi = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                selesai ? Icons.event_repeat_outlined : Icons.check_circle_outline,
                color: const Color(0xFF1D6FFF),
              ),
              title: Text(selesai ? 'Tandai belum selesai' : 'Tandai selesai'),
              onTap: () => Navigator.pop(ctx, 'status'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFE0245E)),
              title: const Text('Hapus jadwal'),
              onTap: () => Navigator.pop(ctx, 'hapus'),
            ),
          ],
        ),
      ),
    );

    if (aksi == 'status') {
      await _ubahStatus(item, id, selesai ? StatusAgenda.terjadwal : StatusAgenda.selesai);
    } else if (aksi == 'hapus') {
      await _hapus(id);
    }
  }

  Future<void> _ubahStatus(AgendaItem item, int id, StatusAgenda baru) async {
    try {
      final hasil = await _repo.ubahStatus(id, baru);
      if (!mounted) return;
      setState(() {
        final daftar = _cache[kunciTanggal(_dipilih)];
        if (daftar == null) return;
        final i = daftar.indexWhere((a) => a.id == id);
        if (i != -1) daftar[i] = hasil;
      });
    } catch (e) {
      if (mounted) _snack(_pesan(e));
    }
  }

  Future<void> _hapus(int id) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jadwal?'),
        content: const Text('Jadwal kunjungan ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      await _repo.hapus(id);
      if (!mounted) return;
      setState(() {
        _cache[kunciTanggal(_dipilih)]?.removeWhere((a) => a.id == id);
      });
      _snack('Jadwal dihapus');
    } catch (e) {
      if (mounted) _snack(_pesan(e));
    }
  }

  // ---------- tampilan ----------

  @override
  Widget build(BuildContext context) {
    final agenda = _agendaTerpilih;
    final adalahHariIni = kunciTanggal(_dipilih) == kunciTanggal(hariIni());
    final tanggalAdaAgenda = _cache.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toSet();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _muatMinggu(paksa: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            RingkasanAgendaCard(agenda: agenda, adalahHariIni: adalahHariIni),
            const SizedBox(height: 18),
            StripTanggalAgenda(
              dipilih: _dipilih,
              tanggalAdaAgenda: tanggalAdaAgenda,
              onPilihTanggal: _pilihTanggal,
              onGeserMinggu: _geserMinggu,
              onHariIni: () => _pilihTanggal(hariIni()),
            ),
            const SizedBox(height: 18),
            _buildJudulHari(agenda.length),
            if (_memuat)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ..._buildIsi(agenda),
            const SizedBox(height: 16),
            TombolTambahJadwal(onTap: _tambahJadwal),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIsi(List<AgendaItem> agenda) {
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _muatMinggu(paksa: true),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ];
    }
    if (agenda.isEmpty) {
      if (_memuat) return const [SizedBox(height: 40)];
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'Belum ada kunjungan di tanggal ini.',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
        ),
      ];
    }
    return agenda
        .map((a) => KartuAgenda(item: a, onTap: () => _aksiKartu(a)))
        .toList();
  }

  Widget _buildJudulHari(int jumlah) {
    return Row(
      children: [
        Expanded(
          child: Text(
            DateFormat('EEEE, d MMMM', 'id_ID').format(_dipilih),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$jumlah kunjungan',
          maxLines: 1,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: const Text(
        'Agenda',
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
    );
  }
}