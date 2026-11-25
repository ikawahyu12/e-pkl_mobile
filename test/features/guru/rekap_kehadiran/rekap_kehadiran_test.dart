import 'package:e_pkl/data/models/siswa_bimbingan_model.dart';
import 'package:e_pkl/data/repositories/siswa_bimbingan_repository.dart';
import 'package:e_pkl/features/guru/rekap_kehadiran/rekap_kehadiran.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SiswaRepositoryFake implements SiswaBimbinganRepository {
  final List<SiswaBimbingan> data;

  _SiswaRepositoryFake(this.data);

  @override
  Future<List<SiswaBimbingan>> ambilDaftar() async => data;

  @override
  Future<SiswaBimbingan> ambilDetail(String id) async =>
      data.firstWhere((siswa) => siswa.id == id);
}

void main() {
  testWidgets('menampilkan rekap dari repository, bukan data dummy', (
    tester,
  ) async {
    const data = [
      SiswaBimbingan(
        id: '1',
        nama: 'Siswa Real',
        nis: '001',
        kelas: 'XI RPL',
        instansi: 'PT Real',
        status: StatusKehadiran.hadir,
        persentaseKehadiran: 90,
      ),
      SiswaBimbingan(
        id: '2',
        nama: 'Siswa Izin',
        nis: '002',
        kelas: 'XI TKJ',
        instansi: 'CV Real',
        status: StatusKehadiran.izin,
        persentaseKehadiran: 80,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: RekapKehadiranPage(
          repository: _SiswaRepositoryFake(data),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siswa Real'), findsOneWidget);
    expect(find.text('Siswa Izin'), findsOneWidget);
    expect(find.text('85.0%'), findsOneWidget);
    expect(find.text('Ahmad Rizky Pratama'), findsNothing);
  });
}
