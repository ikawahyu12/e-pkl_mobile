import 'package:e_pkl/data/models/jurnal_model.dart';
import 'package:e_pkl/data/repositories/jurnal_guru_repository.dart';
import 'package:e_pkl/features/guru/informasi_jurnal/informasi_jurnal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('shows server journal information and opens read-only detail', (
    tester,
  ) async {
    final repository = _FakeJurnalRepository();
    await tester.pumpWidget(
      MaterialApp(home: InformasiJurnalPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siswa Uji'), findsOneWidget);
    expect(find.text('Judul dari API'), findsOneWidget);
    expect(find.text('Kegiatan dari API'), findsOneWidget);
    expect(find.text('Menunggu'), findsNothing);
    expect(find.text('Setujui Jurnal'), findsNothing);

    await tester.tap(find.text('Judul dari API'));
    await tester.pumpAndSettle();

    expect(repository.detailId, '42');
    expect(find.text('Detail Informasi Jurnal'), findsOneWidget);
    expect(find.text('Hasil kegiatan lengkap'), findsOneWidget);
    expect(find.text('Kendala kegiatan'), findsOneWidget);
    expect(find.text('Catatan Pembimbing'), findsNothing);
    expect(find.text('Tolak Jurnal'), findsNothing);
  });

  testWidgets('shows an empty state when API returns no journals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InformasiJurnalPage(
          repository: _FakeJurnalRepository(empty: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada jurnal siswa'), findsOneWidget);
  });

  testWidgets('shows an error state when loading the API fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InformasiJurnalPage(
          repository: _FakeJurnalRepository(listError: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Gagal memuat informasi jurnal. Periksa koneksi Anda.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}

class _FakeJurnalRepository implements JurnalGuruRepository {
  final bool empty;
  final bool listError;
  String? detailId;

  _FakeJurnalRepository({this.empty = false, this.listError = false});

  @override
  Future<List<JurnalModel>> ambilDaftar() async {
    if (listError) throw Exception('network unavailable');
    return empty ? [] : [_jurnal()];
  }

  @override
  Future<JurnalModel> ambilDetail(String id) async {
    detailId = id;
    return _jurnal(
      hasil: 'Hasil kegiatan lengkap',
      kendala: 'Kendala kegiatan',
    );
  }

  @override
  Future<Map<String, String>> dokumentasiHeaders() async => const {};

  JurnalModel _jurnal({String? hasil, String? kendala}) {
    return JurnalModel(
      id: '42',
      penempatanId: 7,
      namaSiswa: 'Siswa Uji',
      nisn: '12345',
      tanggal: '2026-11-15',
      judul: 'Judul dari API',
      kegiatan: 'Kegiatan dari API',
      hasil: hasil,
      kendala: kendala,
      dokumentasi: const [],
    );
  }
}
