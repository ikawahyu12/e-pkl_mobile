import 'package:e_pkl/data/models/siswa_bimbingan_model.dart';
import 'package:e_pkl/data/models/pengajuan_izin_model.dart';
import 'package:e_pkl/data/repositories/izin_guru_repository.dart';
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

class _IzinRepositoryFake implements IzinGuruRepository {
  final List<PengajuanIzinModel> data;

  _IzinRepositoryFake(this.data);

  @override
  Future<List<PengajuanIzinModel>> ambilDaftar() async => data;

  @override
  Future<Map<String, String>> lampiranHeaders() async => const {};
}

void main() {
  test('mem-parsing jumlah kehadiran dari respons API', () {
    final siswa = SiswaBimbingan.fromJson({
      'siswa_id': 1,
      'nama_lengkap': 'Siswa Real',
      'status_kehadiran': 'hadir',
      'jumlah_hadir': 7,
    });

    expect(siswa.jumlahHadir, 7);
  });

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
        jumlahHadir: 3,
      ),
      SiswaBimbingan(
        id: '2',
        nama: 'Siswa Izin',
        nis: '002',
        kelas: 'XI TKJ',
        instansi: 'CV Real',
        status: StatusKehadiran.izin,
        persentaseKehadiran: 80,
        jumlahHadir: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: RekapKehadiranPage(
          repository: _SiswaRepositoryFake(data),
          izinRepository: _IzinRepositoryFake(const [
            PengajuanIzinModel(
              id: 'izin-1',
              namaSiswa: 'Siswa Pengajuan Izin',
              nisn: '004',
              jenis: 'izin',
              tanggalMulai: '2026-11-27',
              tanggalSelesai: '2026-11-27',
              alasan: 'Keperluan keluarga',
              status: 'disetujui',
              lampiran: [],
            ),
            PengajuanIzinModel(
              id: 'sakit-1',
              namaSiswa: 'Siswa Pengajuan Sakit',
              nisn: '005',
              jenis: 'sakit',
              tanggalMulai: '2026-11-27',
              tanggalSelesai: '2026-11-27',
              alasan: 'Demam',
              status: 'menunggu',
              lampiran: [],
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siswa Real'), findsOneWidget);
    expect(find.text('Siswa Izin'), findsOneWidget);
    expect(find.text('Jumlah Kehadiran'), findsOneWidget);
    expect(
      find.text('4 kali hadir tercatat dari 2 siswa bimbingan.'),
      findsOneWidget,
    );
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Ahmad Rizky Pratama'), findsNothing);
    expect(find.text('Alpha'), findsNothing);
    final izinCard = find
        .ancestor(of: find.text('Izin'), matching: find.byType(InkWell))
        .first;
    expect(
      find.descendant(of: izinCard, matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('kartu Izin membuka halaman riwayat izin', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RekapKehadiranPage(
          repository: _SiswaRepositoryFake(const []),
          izinRepository: _IzinRepositoryFake(const [
            PengajuanIzinModel(
              id: 'sakit-1',
              namaSiswa: 'Siswa Sakit',
              nisn: '003',
              jenis: 'sakit',
              tanggalMulai: '2026-11-27',
              tanggalSelesai: '2026-11-27',
              alasan: 'Demam',
              status: 'menunggu',
              lampiran: [],
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Izin'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Izin'), findsOneWidget);
    expect(find.text('Belum ada pengajuan izin.'), findsOneWidget);
  });

  testWidgets('kartu Hadir membuka daftar siswa yang hadir', (tester) async {
    const data = [
      SiswaBimbingan(
        id: '1',
        nama: 'Siswa Hadir',
        nis: '001',
        kelas: 'XI RPL',
        instansi: 'PT Real',
        status: StatusKehadiran.hadir,
        persentaseKehadiran: 90,
        jumlahHadir: 3,
      ),
      SiswaBimbingan(
        id: '2',
        nama: 'Siswa Sakit',
        nis: '002',
        kelas: 'XI TKJ',
        instansi: 'CV Real',
        status: StatusKehadiran.sakit,
        persentaseKehadiran: 80,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: RekapKehadiranPage(
          repository: _SiswaRepositoryFake(data),
          izinRepository: _IzinRepositoryFake(const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hadir'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Siswa Hadir'),
      ),
      findsOneWidget,
    );
    expect(find.text('3 kali hadir'), findsOneWidget);
    expect(find.text('Siswa Sakit'), findsNothing);
  });

  testWidgets('kartu Sakit membuka riwayat sakit dan menampilkan datanya', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RekapKehadiranPage(
          repository: _SiswaRepositoryFake(const []),
          izinRepository: _IzinRepositoryFake(const [
            PengajuanIzinModel(
              id: 'sakit-1',
              namaSiswa: 'Siswa Sakit',
              nisn: '003',
              jenis: 'sakit',
              tanggalMulai: '2026-11-27',
              tanggalSelesai: '2026-11-27',
              alasan: 'Demam',
              status: 'menunggu',
              lampiran: [],
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sakit'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Sakit'), findsOneWidget);
    expect(find.text('Siswa Sakit'), findsOneWidget);
    expect(find.text('Demam'), findsOneWidget);
  });
}
