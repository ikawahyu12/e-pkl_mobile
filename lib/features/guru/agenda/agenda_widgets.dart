import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'agenda_data.dart';

/// Kartu gradasi biru di bagian atas: jumlah kunjungan, terjadwal, selesai.
class RingkasanAgendaCard extends StatelessWidget {
  final List<AgendaItem> agenda;
  final bool adalahHariIni;

  const RingkasanAgendaCard({
    super.key,
    required this.agenda,
    required this.adalahHariIni,
  });

  @override
  Widget build(BuildContext context) {
    final terjadwal =
        agenda.where((a) => a.status == StatusAgenda.terjadwal).length;
    final selesai =
        agenda.where((a) => a.status == StatusAgenda.selesai).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D6FFF), Color(0xFF5BB0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adalahHariIni ? 'Kunjungan hari ini' : 'Kunjungan',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pantau progres, dampingi siswa.',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x40FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Angka(angka: agenda.length, label: 'Kunjungan'),
              _Angka(angka: terjadwal, label: 'Terjadwal'),
              _Angka(angka: selesai, label: 'Selesai'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Angka extends StatelessWidget {
  final int angka;
  final String label;

  const _Angka({required this.angka, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$angka',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Header bulan (dengan panah minggu & "Hari ini") + strip 7 hari.
class StripTanggalAgenda extends StatelessWidget {
  final DateTime dipilih;
  final ValueChanged<DateTime> onPilihTanggal;
  final ValueChanged<int> onGeserMinggu; // -1 = minggu lalu, 1 = minggu depan
  final VoidCallback onHariIni;

  const StripTanggalAgenda({
    super.key,
    required this.dipilih,
    required this.onPilihTanggal,
    required this.onGeserMinggu,
    required this.onHariIni,
  });

  static const _biru = Color(0xFF1D6FFF);
  static const _gelap = Color(0xFF0F172A);
  static const _abu = Color(0xFF64748B);

  // Senin pada minggu tanggal yang dipilih
  DateTime get _awalMinggu =>
      dipilih.subtract(Duration(days: dipilih.weekday - 1));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderBulan(),
        const SizedBox(height: 12),
        _buildStrip(),
      ],
    );
  }

  Widget _buildHeaderBulan() {
    return Row(
      children: [
        Flexible(
          child: Text(
            DateFormat('MMMM y', 'id_ID').format(dipilih),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _gelap,
            ),
          ),
        ),
        const Icon(Icons.keyboard_arrow_down, size: 20, color: _gelap),
        const Spacer(),
        GestureDetector(
          onTap: () => onGeserMinggu(-1),
          child: const Icon(Icons.chevron_left, size: 20, color: _gelap),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onHariIni,
          child: const Text(
            'Hari ini',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _biru,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onGeserMinggu(1),
          child: const Icon(Icons.chevron_right, size: 20, color: _gelap),
        ),
      ],
    );
  }

  Widget _buildStrip() {
    final awal = _awalMinggu;

    return Row(
      children: List.generate(7, (i) {
        final tgl = awal.add(Duration(days: i));
        final terpilih = kunciTanggal(tgl) == kunciTanggal(dipilih);
        final adaAgenda = dummyAgenda.containsKey(kunciTanggal(tgl));

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
            child: GestureDetector(
              onTap: () => onPilihTanggal(tgl),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: terpilih ? _biru : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: terpilih ? _biru : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'id_ID').format(tgl),
                      style: TextStyle(
                        fontSize: 11,
                        color: terpilih ? Colors.white : _abu,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tgl.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: terpilih ? Colors.white : _gelap,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !adaAgenda
                            ? Colors.transparent
                            : (terpilih ? Colors.white : _biru),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Satu kartu kunjungan: jam, status, perusahaan, alamat, siswa, kelas.
class KartuAgenda extends StatelessWidget {
  final AgendaItem item;
  final VoidCallback? onTap;

  const KartuAgenda({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final selesai = item.status == StatusAgenda.selesai;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _buildJamStatus(selesai),
            const SizedBox(height: 12),
            _buildPerusahaan(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            _buildSiswa(),
          ],
        ),
      ),
    );
  }

  Widget _buildJamStatus(bool selesai) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 15, color: Color(0xFF1D6FFF)),
        const SizedBox(width: 6),
        Text(
          item.jam,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: selesai ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selesai) ...[
                const Icon(Icons.check, size: 12, color: Color(0xFF047857)),
                const SizedBox(width: 3),
              ],
              Text(
                selesai ? 'Selesai' : 'Terjadwal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selesai
                      ? const Color(0xFF047857)
                      : const Color(0xFF1D6FFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerusahaan() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.apartment, size: 20, color: Color(0xFF1D6FFF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.perusahaan,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.alamat,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      ],
    );
  }

  Widget _buildSiswa() {
    return Row(
      children: [
        const Icon(Icons.people_outline, size: 15, color: Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.siswa,
            style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
          ),
        ),
        Text(
          item.kelas,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class TombolTambahJadwal extends StatelessWidget {
  final VoidCallback onTap;

  const TombolTambahJadwal({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF1D6FFF), Color(0xFF5BB0FF)],
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Tambah Jadwal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}