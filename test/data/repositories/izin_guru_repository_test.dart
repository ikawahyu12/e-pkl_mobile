import 'dart:convert';

import 'package:e_pkl/data/repositories/izin_guru_repository.dart';
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

  test('requests Guru permissions and parses attachment data', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/guru/izin');
      expect(request.headers['authorization'], 'Bearer token-guru');
      return _response({
        'success': true,
        'data': [
          {
            'id': 12,
            'jenis': 'izin',
            'tanggal_mulai': '2026-11-27',
            'tanggal_selesai': '2026-11-28',
            'alasan': 'Keperluan keluarga',
            'status': 'Menunggu',
            'siswa': {'nama_lengkap': 'Siswa Uji', 'nisn': '12345'},
            'lampiran': {
              'nama_file': 'surat.jpg',
              'mime_type': 'image/jpeg',
              'url': 'http://localhost/storage/izin/surat.jpg',
            },
          },
        ],
      });
    });
    final repository = IzinGuruRepositoryApi(client: client);

    final hasil = await repository.ambilDaftar();

    expect(hasil, hasLength(1));
    expect(hasil.single.namaSiswa, 'Siswa Uji');
    expect(hasil.single.status, 'Menunggu');
    expect(hasil.single.lampiran.single.isImage, isTrue);
    expect(
      hasil.single.lampiran.single.url,
      contains('/storage/izin/surat.jpg'),
    );
    expect(await repository.lampiranHeaders(), {
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
