import 'dart:convert';

import 'package:e_pkl/data/repositories/jurnal_guru_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'guru_access_token': 'token-guru',
    });
  });

  test('list request uses the Guru token and parses journal fields', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/guru/jurnal');
      expect(request.headers['authorization'], 'Bearer token-guru');
      return _response({
        'success': true,
        'data': [_sampleJournal()],
      });
    });
    final repository = JurnalGuruRepositoryApi(client: client);

    final journals = await repository.ambilDaftar();

    expect(journals, hasLength(1));
    expect(journals.single.namaSiswa, 'Siswa Uji');
    expect(journals.single.kegiatan, 'Kegiatan siswa');
    expect(journals.single.dokumentasi.single.url, contains('/lampiran/9'));
  });

  test('detail request fetches the selected journal id', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/guru/jurnal/42');
      return _response({'success': true, 'data': _sampleJournal(id: 42)});
    });
    final repository = JurnalGuruRepositoryApi(client: client);

    final journal = await repository.ambilDetail('42');

    expect(journal.id, '42');
    expect(journal.hasil, 'Hasil siswa');
    expect(journal.kendala, 'Kendala siswa');
  });

  test('documentation requests carry the same Guru bearer token', () async {
    final client = MockClient((_) async => _response({'success': true}));
    final repository = JurnalGuruRepositoryApi(client: client);

    expect(await repository.dokumentasiHeaders(), {
      'Accept': 'image/*',
      'Authorization': 'Bearer token-guru',
    });
  });
}

http.Response _response(Map<String, dynamic> body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: const {'content-type': 'application/json'},
  );
}

Map<String, dynamic> _sampleJournal({int id = 3}) {
  return {
    'id': id,
    'penempatan_id': 7,
    'tanggal': '2026-11-15',
    'judul': 'Jurnal siswa',
    'kegiatan': 'Kegiatan siswa',
    'hasil': 'Hasil siswa',
    'kendala': 'Kendala siswa',
    'siswa': {'id': 8, 'nama_lengkap': 'Siswa Uji', 'nisn': '12345'},
    'dokumentasi': [
      {
        'id': 9,
        'nama_file': 'foto.jpg',
        'mime_type': 'image/jpeg',
        'url': 'http://localhost/api/v1/guru/jurnal/$id/lampiran/9',
      },
    ],
  };
}
