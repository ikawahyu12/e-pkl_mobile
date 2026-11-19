import 'dart:typed_data';

import '../models/profil_guru_model.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository.dart';
import 'profil_guru_repository.dart';

class ProfilGuruRepositoryApi implements ProfilGuruRepository {
  final GuruAuthRepository _authRepository;
  final GuruApiClient _api;

  ProfilGuruRepositoryApi({
    required GuruAuthRepository authRepository,
    GuruApiClient? api,
  }) : _authRepository = authRepository,
       _api = api ?? GuruApiClient(authRepository: authRepository);

  @override
  Future<ProfilGuru> ambilProfil() async {
    final response = await _api.send(method: 'GET', path: 'guru/profil');
    return ProfilGuru.fromJson(_data(response));
  }

  @override
  Future<ProfilGuru> ubahProfil({
    required String nama,
    String? noHp,
    Uint8List? fotoBytes,
    String? fotoNama,
  }) async {
    final Map<String, dynamic> body = {'nama': nama};
    if (noHp != null) body['no_hp'] = noHp;

    final Map<String, dynamic> response;
    if (fotoBytes == null) {
      response = await _api.send(
        method: 'PATCH',
        path: 'guru/profil',
        body: body,
      );
    } else {
      response = await _api.sendMultipart(
        method: 'POST',
        path: 'guru/profil',
        fields: {
          for (final entry in body.entries)
            if (entry.value != null) entry.key: entry.value.toString(),
        },
        fileBytes: fotoBytes,
        fileField: 'foto',
        fileName: fotoNama ?? 'foto-profil.jpg',
      );
    }
    return ProfilGuru.fromJson(_data(response));
  }

  @override
  Future<void> ajukanPerubahanEmail(String emailBaru) async {
    await _api.send(
      method: 'POST',
      path: 'guru/profil/email-change',
      body: {'email': emailBaru.trim()},
    );
  }

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    await _authRepository.gantiPassword(
      passwordLama: passwordLama,
      passwordBaru: passwordBaru,
      passwordBaruConfirmation: passwordBaru,
    );
  }

  @override
  Future<void> logout() => _authRepository.keluar();

  Map<String, dynamic> _data(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Data profil Guru tidak valid.');
  }
}
