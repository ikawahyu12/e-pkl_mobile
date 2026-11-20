import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/agenda_repository_api.dart';
import '../../../data/repositories/guru_auth_repository_api.dart';
import '../../../shared/widgets/epkl_widgets.dart';
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
  late final AgendaRepository _repository =
      widget.repository ??
      AgendaRepositoryApi(authRepository: GuruAuthRepositoryApi());

  DateTime _dipilih = hariIni();
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
      setState(() => _error = _pesan(error));
    } finally {
      if (mounted && muatId == _muatId) {
        setState(() => _memuat = false);
      }
    }
  }

  String _pesan(Object e) => e.toString().replaceFirst('Exception: ', '');

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

  // ---------- aksi pada kartu ----------

  Future<void> _aksiKartu(AgendaItem item) async {
    final selesai = item.status == StatusAgenda.selesai;
    final dibatalkan = item.status == StatusAgenda.dibatalkan;

    final aksi = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!dibatalkan)
              ListTile(
                leading: Icon(
                  selesai
                      ? Icons.event_repeat_outlined
                      : Icons.check_circle_outline,
                  color: const Color(0xFF1D6FFF),
                ),
                title: Text(selesai ? 'Tandai belum selesai' : 'Tandai selesai'),
                onTap: () => Navigator.pop(ctx, 'status'),
              ),
            if (!dibatalkan && !selesai)
              ListTile(
                leading: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.orange,
                ),
                title: const Text('Batalkan agenda'),
                onTap: () => Navigator.pop(ctx, 'batalkan'),
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFE0245E),
              ),
              title: const Text('Hapus jadwal'),
              onTap: () => Navigator.pop(ctx, 'hapus'),
            ),
          ],
        ),
      ),
    );

    if (aksi == 'status') {
      await _ubahStatus(
        item,
        selesai ? StatusAgenda.terjadwal : StatusAgenda.selesai,
      );
    } else if (aksi == 'batalkan') {
      await _batalkan(item);
    } else if (aksi == 'hapus') {
      await _hapus(item.id);
    }
  }

  Future<void> _ubahStatus(AgendaItem item, StatusAgenda baru) async {
    try {
      await _repository.ubahStatus(id: item.id, status: baru);
      await _muat();
      if (mounted) {
        _snack(
          baru == StatusAgenda.selesai
              ? 'Agenda ditandai selesai.'
              : 'Agenda ditandai terjadwal.',
        );
      }
    } catch (error) {
      if (mounted) _snack(_pesan(error), error: true);
    }
  }

  Future<void> _tandaiSelesai(AgendaItem item) =>
      _ubahStatus(item, StatusAgenda.selesai);

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
      if (mounted) _snack(_pesan(error), error: true);
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
      await _repository.hapus(id);
      await _muat();
      if (mounted) _snack('Jadwal dihapus.');
    } catch (error) {
      if (mounted) _snack(_pesan(error), error: true);
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

  // ---------- tampilan ----------

  @override
  Widget build(BuildContext context) {
    final agenda = _agendaTerpilih;
    final adalahHariIni = kunciTanggal(_dipilih) == kunciTanggal(hariIni());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            RingkasanAgendaCard(agenda: agenda, adalahHariIni: adalahHariIni),
            const SizedBox(height: 18),
            StripTanggalAgenda(
              dipilih: _dipilih,
              onPilihTanggal: _pilihTanggal,
              onGeserMinggu: _geserMinggu,
              onHariIni: () => _pilihTanggal(hariIni()),
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
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _muat,
                      child: const Text('Coba lagi'),
                    ),
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
    return const EpklGradientAppBar(judul: 'Agenda');
  }
}