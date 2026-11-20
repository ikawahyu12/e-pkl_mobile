import 'dart:convert';

import 'package:e_pkl/data/repositories/instansi_repository.dart';
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

  test('loads active master instansi from the Guru API', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/guru/instansi');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['authorization'], 'Bearer token-guru');

      return _response({
        'success': true,
        'data': [
          {'id': 1, 'nama': 'PT Contoh'},
          {'id': 2, 'nama': 'CV Contoh'},
        ],
      });
    });
    final repository = InstansiRepository(client: client);

    final instansi = await repository.ambilDaftar();
    expect(instansi.map((item) => item.id), [1, 2]);
    expect(instansi.map((item) => item.nama), ['PT Contoh', 'CV Contoh']);
    client.close();
  });

  test('parses Laravel paginated data response', () async {
    final client = MockClient(
      (_) async => _response({
        'success': true,
        'data': {
          'data': [
            {'id': 1, 'nama': 'Instansi Paginasi'},
          ],
        },
      }),
    );
    final repository = InstansiRepository(client: client);

    final instansi = await repository.ambilDaftar();
    expect(instansi.single.id, 1);
    expect(instansi.single.nama, 'Instansi Paginasi');
    client.close();
  });

  test('allows an empty active master instansi list', () async {
    final client = MockClient(
      (_) async => _response({'success': true, 'data': []}),
    );
    final repository = InstansiRepository(client: client);

    expect(await repository.ambilDaftar(), isEmpty);
    client.close();
  });

  test('reports API failure instead of returning sample instansi', () async {
    final client = MockClient(
      (_) async => _response({
        'success': false,
        'message': 'Endpoint tidak ditemukan.',
      }, statusCode: 404),
    );
    final repository = InstansiRepository(client: client);

    await expectLater(
      repository.ambilDaftar(),
      throwsA(
        isA<InstansiException>().having(
          (error) => error.message,
          'message',
          'Endpoint tidak ditemukan.',
        ),
      ),
    );
    client.close();
  });
}

http.Response _response(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}
