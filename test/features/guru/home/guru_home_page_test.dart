import 'package:e_pkl/data/models/dashboard_guru_model.dart';
import 'package:e_pkl/data/repositories/dashboard_guru_repository.dart';
import 'package:e_pkl/features/guru/home/guru_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _data = DashboardGuru(
  jumlahSiswa: 12,
  persenKehadiran: 85,
  jumlahJurnal: 8,
  jumlahPenilaian: 10,
  jurnalMenunggu: 3,
  notifikasiBelumDibaca: 3,
);

class _RepoFake implements DashboardGuruRepository {
  final Future<DashboardGuru> Function() _ambil;
  _RepoFake(this._ambil);

  @override
  Future<DashboardGuru> ambilDashboard() => _ambil();
}

/// Pasang beranda di dalam MaterialApp. Halaman tujuan diganti halaman
/// polos yang menampilkan nama rutenya.
Future<List<int>> _pasang(
  WidgetTester tester, {
  DashboardGuruRepository? repo,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final tabDipilih = <int>[];
  await tester.pumpWidget(MaterialApp(
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (_) => settings.name == '/'
          ? GuruHomePage(
              repository: repo ?? _RepoFake(() async => _data),
              onPindahTab: tabDipilih.add,
            )
          : Scaffold(body: Text('Halaman ${settings.name}')),
    ),
  ));
  await tester.pumpAndSettle();
  return tabDipilih;
}

void main() {
  group('GuruHomePage', () {
    testWidgets('menampilkan sapaan, statistik, menu cepat, dan info',
        (tester) async {
      await _pasang(tester);

      expect(find.text('Halo,\nGuru Pembimbing'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Siswa Bimbingan'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Kehadiran'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Menu Cepat'), findsOneWidget);
      expect(find.text('Absensi'), findsOneWidget);
      expect(find.text('Validasi Jurnal'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Informasi Terbaru'), findsOneWidget);
      expect(find.text('Terdapat 3 jurnal yang menunggu validasi.'),
          findsOneWidget);
      expect(find.text('Lihat detail'), findsNWidgets(4));
    });

    testWidgets('titik notifikasi hanya muncul jika ada yang belum dibaca',
        (tester) async {
      await _pasang(tester);
      expect(find.byKey(const ValueKey('titik-notifikasi')), findsOneWidget);

      await _pasang(
        tester,
        repo: _RepoFake(() async => const DashboardGuru(
              jumlahSiswa: 1,
              persenKehadiran: 100,
              jumlahJurnal: 0,
              jumlahPenilaian: 0,
              jurnalMenunggu: 0,
              notifikasiBelumDibaca: 0,
            )),
      );
      expect(find.byKey(const ValueKey('titik-notifikasi')), findsNothing);
      expect(find.text('Tidak ada jurnal yang menunggu validasi.'),
          findsOneWidget);
    });

    testWidgets('pintasan tab memindahkan tab tanpa membuka halaman baru',
        (tester) async {
      final tab = await _pasang(tester);

      await tester.tap(find.text('Siswa Bimbingan'));
      await tester.tap(find.text('Kehadiran'));
      await tester.tap(find.text('Penilaian').first); // tile statistik
      await tester.pumpAndSettle();

      expect(tab, [1, 2, 1]);
      expect(find.textContaining('Halaman /guru'), findsNothing);
    });

    testWidgets('pintasan halaman membuka rute yang benar', (tester) async {
      Future<void> uji(Finder tombol, String rute) async {
        await _pasang(tester);
        await tester.tap(tombol);
        await tester.pumpAndSettle();
        expect(find.text('Halaman $rute'), findsOneWidget);
      }

      await uji(find.byTooltip('Notifikasi'), '/guru/notifikasi');
      await uji(find.text('Absensi'), '/guru/presensi');
      await uji(find.text('Validasi Jurnal'), '/guru/jurnal');
      await uji(find.text('Jurnal'), '/guru/jurnal'); // tile statistik
      await uji(find.text('Informasi Terbaru'), '/guru/jurnal');
    });

    testWidgets('avatar membuka tab Profil', (tester) async {
      final tab = await _pasang(tester);
      await tester.tap(find.byTooltip('Profil'));
      await tester.pumpAndSettle();
      expect(tab, [3]);
    });

    testWidgets('tap berulang cepat tidak membuat halaman dobel',
        (tester) async {
      await _pasang(tester);

      final lonceng = find.byTooltip('Notifikasi');
      await tester.tap(lonceng);
      await tester.tap(lonceng); // tanpa pump: halaman pertama sudah di atas
      await tester.pumpAndSettle();
      expect(find.text('Halaman /guru/notifikasi'), findsOneWidget);

      // Cukup satu kali kembali untuk sampai ke beranda.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Halo,\nGuru Pembimbing'), findsOneWidget);
    });

    testWidgets('Agenda menampilkan snackbar (belum ada halamannya)',
        (tester) async {
      await _pasang(tester);
      await tester.tap(find.text('Agenda'));
      await tester.pump();
      expect(find.text('Fitur ini segera hadir'), findsOneWidget);
    });

    testWidgets('gagal memuat -> tombol Coba lagi memuat ulang',
        (tester) async {
      var panggilan = 0;
      await _pasang(
        tester,
        repo: _RepoFake(() async {
          panggilan++;
          if (panggilan == 1) throw Exception('offline');
          return _data;
        }),
      );

      expect(find.text('Gagal memuat beranda. Periksa koneksi Anda.'),
          findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Halo,\nGuru Pembimbing'), findsOneWidget);
      expect(panggilan, 2);
    });

    testWidgets('layar sempit 320dp tidak overflow', (tester) async {
      await _pasang(tester);
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('DashboardGuru', () {
    test('fromJson membaca angka & default 0', () {
      final d = DashboardGuru.fromJson({
        'jumlah_siswa': 12,
        'persen_kehadiran': 85.0,
        'jurnal_menunggu': 2,
      });
      expect(d.jumlahSiswa, 12);
      expect(d.persenKehadiran, 85);
      expect(d.jumlahJurnal, 0);
      expect(d.infoTerbaru, 'Terdapat 2 jurnal yang menunggu validasi.');
      expect(d.adaNotifikasiBaru, isFalse);
    });
  });
}