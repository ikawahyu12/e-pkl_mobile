import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/agenda_repository_api.dart';
import '../../../data/repositories/guru_auth_repository_api.dart';
import 'agenda_data.dart';
import 'agenda_widgets.dart';
import 'tambah_agenda_page.dart';

class AgendaPage extends StatefulWidget {
  final AgendaRepository? repository;

  const AgendaPage({super.key, this.repository});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final AgendaRepository _repository =
      widget.repository ??
      AgendaRepositoryApi(authRepository: GuruAuthRepositoryApi());

  DateTime _dipilih = DateTime.now();
  List<AgendaItem> _agendaMinggu = [];
  bool _memuat = true;
  String? _error;
  int _muatId = 0;

  DateTime _awalMinggu(DateTime date) =>
      DateTime(date.year, date.month, date.day - date.weekday + 1);

  List<AgendaItem> get _agendaTerpilih => _agendaMinggu
      .where((item) => kunciTanggal(item.tanggal) == kunciTanggal(_dipilih))
      .toList();

  Set<String> get _tanggalDenganAgenda =>
      _agendaMinggu.map((item) => kunciTanggal(item.tanggal)).toSet();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final muatId = ++_muatId;
    final awal = _awalMinggu(_dipilih);
    setState(() {
      _memuat = true;
      _error = null;
    });

    try {
      final agenda = await _repository.ambilAgenda(
        dari: awal,
        sampai: awal.add(const Duration(days: 6)),
      );
      if (!mounted || muatId != _muatId) return;
      setState(() => _agendaMinggu = agenda);
    } catch (error) {
      if (!mounted || muatId != _muatId) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted && muatId == _muatId) {
        setState(() => _memuat = false);
      }
    }
  }

  void _pilihTanggal(DateTime tanggal) {
    final perluMuat =
        kunciTanggal(_awalMinggu(tanggal)) !=
        kunciTanggal(_awalMinggu(_dipilih));
    setState(
      () => _dipilih = DateTime(tanggal.year, tanggal.month, tanggal.day),
    );
    if (perluMuat) _muat();
  }

  void _geserMinggu(int arah) {
    _pilihTanggal(_dipilih.add(Duration(days: 7 * arah)));
  }

  Future<void> _tambahJadwal() async {
    final hasil = await Navigator.push<AgendaItem>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TambahAgendaPage(tanggalAwal: _dipilih, repository: _repository),
      ),
    );
    if (hasil == null || !mounted) return;

    setState(() => _dipilih = hasil.tanggal);
    await _muat();
    if (!mounted) return;
    _snack('Agenda kunjungan berhasil ditambahkan.');
  }

  Future<void> _tandaiSelesai(AgendaItem item) async {
    try {
      await _repository.ubahStatus(id: item.id, status: StatusAgenda.selesai);
      await _muat();
      if (mounted) _snack('Agenda ditandai selesai.');
    } catch (error) {
      if (mounted) _snack(error.toString(), error: true);
    }
  }

  Future<void> _batalkan(AgendaItem item) async {
    final controller = TextEditingController();
    final alasan = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan agenda'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 2000,
          decoration: const InputDecoration(
            labelText: 'Alasan pembatalan',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Batalkan agenda'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (alasan == null || alasan.trim().isEmpty) return;

    try {
      await _repository.ubahStatus(
        id: item.id,
        status: StatusAgenda.dibatalkan,
        alasanPembatalan: alasan,
      );
      await _muat();
      if (mounted) _snack('Agenda dibatalkan dan disimpan dalam histori.');
    } catch (error) {
      if (mounted) _snack(error.toString(), error: true);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red.shade700 : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final agenda = _agendaTerpilih;
    final adalahHariIni =
        kunciTanggal(_dipilih) == kunciTanggal(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          RingkasanAgendaCard(agenda: agenda, adalahHariIni: adalahHariIni),
          const SizedBox(height: 18),
          StripTanggalAgenda(
            dipilih: _dipilih,
            onPilihTanggal: _pilihTanggal,
            onGeserMinggu: _geserMinggu,
            onHariIni: () => _pilihTanggal(DateTime.now()),
            tanggalDenganAgenda: _tanggalDenganAgenda,
          ),
          const SizedBox(height: 18),
          _buildJudulHari(agenda.length),
          if (_memuat)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _muat, child: const Text('Coba lagi')),
                ],
              ),
            )
          else if (agenda.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada kunjungan di tanggal ini.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ...agenda.map(
              (item) => KartuAgenda(
                item: item,
                onSelesai: () => _tandaiSelesai(item),
                onBatalkan: () => _batalkan(item),
              ),
            ),
          const SizedBox(height: 16),
          TombolTambahJadwal(onTap: _tambahJadwal),
        ],
      ),
    );
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
