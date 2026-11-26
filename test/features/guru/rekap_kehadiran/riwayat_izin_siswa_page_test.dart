import 'package:e_pkl/data/models/pengajuan_izin_model.dart';
import 'package:e_pkl/data/repositories/izin_guru_repository.dart';
import 'package:e_pkl/features/guru/rekap_kehadiran/riwayat_izin_siswa_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _IzinRepositoryFake implements IzinGuruRepository {
  @override
  Future<List<PengajuanIzinModel>> ambilDaftar() async => const [
    PengajuanIzinModel(
      id: '1',
      namaSiswa: 'Siswa Izin',
      nisn: '001',
      jenis: 'izin',
      tanggalMulai: '2026-11-27',
      tanggalSelesai: '2026-11-27',
      alasan: 'Keperluan keluarga',
      status: 'Menunggu',
      lampiran: [],
    ),
    PengajuanIzinModel(
      id: '2',
      namaSiswa: 'Siswa Sakit',
      nisn: '002',
      jenis: 'sakit',
      tanggalMulai: '2026-11-28',
      tanggalSelesai: '2026-11-28',
      alasan: 'Demam',
      status: 'Menunggu',
      lampiran: [],
    ),
  ];

  @override
  Future<Map<String, String>> lampiranHeaders() async => const {};
}

void main() {
  testWidgets('loads API data and filters by selected permission type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RiwayatIzinSiswaPage(
          statusIzin: 'izin',
          repository: _IzinRepositoryFake(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siswa Izin'), findsOneWidget);
    expect(find.text('Keperluan keluarga'), findsOneWidget);
    expect(find.text('Siswa Sakit'), findsNothing);
  });
}
