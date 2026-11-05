import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'agenda_data.dart';
import 'agenda_widgets.dart';
import 'tambah_agenda_page.dart';


class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _dipilih = hariIniDummy;

  List<AgendaItem> get _agendaTerpilih =>
      dummyAgenda[kunciTanggal(_dipilih)] ?? const [];

  void _geserMinggu(int arah) {
    setState(() => _dipilih = _dipilih.add(Duration(days: 7 * arah)));
  }

  Future<void> _tambahJadwal() async {
    final hasil = await Navigator.push<HasilTambahAgenda>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahAgendaPage(tanggalAwal: _dipilih),
      ),
    );
    if (hasil == null || !mounted) return;

    setState(() {
      final daftar =
          dummyAgenda.putIfAbsent(kunciTanggal(hasil.tanggal), () => []);
      daftar.add(hasil.item);
      daftar.sort((a, b) => a.jam.compareTo(b.jam));
      _dipilih = hasil.tanggal; // langsung tampilkan tanggal jadwal baru
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agenda = _agendaTerpilih;
    final adalahHariIni = kunciTanggal(_dipilih) == kunciTanggal(hariIniDummy);

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
            onPilihTanggal: (tgl) => setState(() => _dipilih = tgl),
            onGeserMinggu: _geserMinggu,
            onHariIni: () => setState(() => _dipilih = hariIniDummy),
          ),
          const SizedBox(height: 18),
          _buildJudulHari(agenda.length),
          if (agenda.isEmpty)
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
            ...agenda.map((a) => KartuAgenda(item: a)),
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
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Ganti dengan EpklGradientAppBar(judul: 'Agenda') kalau mau seragam.
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