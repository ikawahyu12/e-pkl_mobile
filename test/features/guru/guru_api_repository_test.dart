import 'dart:convert';
import 'dart:typed_data';

import 'package:e_pkl/data/models/guru_auth_session.dart';
import 'package:e_pkl/data/repositories/agenda_repository_api.dart';
import 'package:e_pkl/data/repositories/guru_api_client.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/data/repositories/profil_guru_repository_api.dart';
import 'package:e_pkl/features/guru/agenda/agenda_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _AuthRepositoryFake implements GuruAuthRepository {
  @override
  Future<String?> bacaAccessToken() async => 'test-access-token';

  @override
  Future<GuruAuthSession?> pulihkanSesi() async => null;

  @override
  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> daftarGuru({
    required String nip,
    required String namaLengkap,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {}

  @override
  Future<void> kirimUlangVerifikasiGuru({required String email}) async {}

  @override
  Future<void> mintaResetPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {}

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {}

  @override
  Future<void> keluar() async {}
}

http.Response _response(Map<String, dynamic> body, {int statusCode = 200}) =>
    http.Response(
      jsonEncode(body),
      statusCode,
      headers: const {'content-type': 'application/json'},
    );

void main() {
  test(
    'profile API reads and updates profile without directly changing email',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') {
          return _response({
            'success': true,
            'data': {
              'nama': 'Guru Uji',
              'nip': '123',
              'sekolah': 'SMK',
              'bimbingan': '1 siswa',
              'email': 'guru@example.test',
              'no_hp': '08123456789',
            },
          });
        }
        return _response({
          'success': true,
          'data': {
            'nama': 'Guru Baru',
            'nip': '123',
            'sekolah': 'SMK',
            'bimbingan': '1 siswa',
            'email': 'guru@example.test',
            'no_hp': '08123456789',
          },
        });
      });
      final auth = _AuthRepositoryFake();
      final api = GuruApiClient(authRepository: auth, client: client);
      final repository = ProfilGuruRepositoryApi(
        authRepository: auth,
        api: api,
      );

      final original = await repository.ambilProfil();
      final updated = await repository.ubahProfil(
        nama: 'Guru Baru',
        noHp: '08123456789',
      );

      expect(original.email, 'guru@example.test');
      expect(updated.nama, 'Guru Baru');
      expect(requests.map((request) => request.url.path), [
        '/api/v1/guru/profil',
        '/api/v1/guru/profil',
      ]);
      expect(
        requests.every(
          (request) =>
              request.headers['authorization'] == 'Bearer test-access-token',
        ),
        isTrue,
      );
      expect(jsonDecode(requests.last.body), {
        'nama': 'Guru Baru',
        'no_hp': '08123456789',
      });
      client.close();
    },
  );

  test('profile API uploads a Guru photo as multipart data', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return _response({
        'success': true,
        'data': {
          'nama': 'Guru Baru',
          'nip': '123',
          'sekolah': 'SMK',
          'bimbingan': '1 siswa',
          'foto_url': 'http://127.0.0.1:8000/api/v1/foto/foto-guru/test.jpg',
        },
      });
    });
    final auth = _AuthRepositoryFake();
    final repository = ProfilGuruRepositoryApi(
      authRepository: auth,
      api: GuruApiClient(authRepository: auth, client: client),
    );

    final updated = await repository.ubahProfil(
      nama: 'Guru Baru',
      noHp: '08123456789',
      fotoBytes: Uint8List.fromList([137, 80, 78, 71]),
      fotoNama: 'foto-guru.png',
    );

    expect(updated.fotoUrl, contains('/foto/foto-guru/test.jpg'));
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url.path, '/api/v1/guru/profil');
    expect(captured!.headers['authorization'], 'Bearer test-access-token');
    expect(captured!.headers['content-type'], contains('multipart/form-data'));
    expect(captured!.bodyBytes, contains(137));
    client.close();
  });

  test(
    'agenda API uses the Guru routes and requires a cancellation reason',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return _response({
          'success': true,
          'data': {
            'id': 42,
            'tanggal': '2026-11-18',
            'jam_mulai': '09:00',
            'jam_selesai': '10:00',
            'status': 'dibatalkan',
            'alasan_pembatalan': 'Perusahaan tutup',
            'perusahaan': 'Instansi Uji',
            'alamat': 'Jalan Uji',
            'siswa': [
              {'id': 1, 'nama': 'Siswa Uji', 'kelas': 'XI RPL'},
            ],
          },
        });
      });
      final repository = AgendaRepositoryApi(
        authRepository: _AuthRepositoryFake(),
        api: GuruApiClient(
          authRepository: _AuthRepositoryFake(),
          client: client,
        ),
      );

      final agenda = await repository.ubahStatus(
        id: 42,
        status: StatusAgenda.dibatalkan,
        alasanPembatalan: 'Perusahaan tutup',
      );

      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.path, '/api/v1/guru/agenda/42/status');
      expect(jsonDecode(requests.single.body), {
        'status': 'dibatalkan',
        'alasan_pembatalan': 'Perusahaan tutup',
      });
      expect(agenda.id, 42);
      expect(agenda.status, StatusAgenda.dibatalkan);
      expect(agenda.siswa, 'Siswa Uji');
      client.close();
    },
  );
}
