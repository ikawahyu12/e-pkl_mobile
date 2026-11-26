import 'package:http/http.dart' as http;

import '../models/pengajuan_izin_model.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository.dart';
import 'guru_auth_repository_api.dart';

abstract interface class IzinGuruRepository {
  Future<List<PengajuanIzinModel>> ambilDaftar();
  Future<Map<String, String>> lampiranHeaders();
}

class IzinGuruRepositoryApi implements IzinGuruRepository {
  final GuruAuthRepository _authRepository;
  final GuruApiClient _apiClient;

  IzinGuruRepositoryApi({
    GuruAuthRepository? authRepository,
    GuruApiClient? apiClient,
    http.Client? client,
  }) : _authRepository =
           authRepository ?? GuruAuthRepositoryApi(client: client),
       _apiClient =
           apiClient ??
           GuruApiClient(
             authRepository:
                 authRepository ?? GuruAuthRepositoryApi(client: client),
             client: client,
           );

  @override
  Future<List<PengajuanIzinModel>> ambilDaftar() async {
    final response = await _apiClient.send(method: 'GET', path: 'guru/izin');
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('Format daftar pengajuan izin tidak valid.');
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('Format pengajuan izin tidak valid.');
      }
      return PengajuanIzinModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  @override
  Future<Map<String, String>> lampiranHeaders() async {
    final token = await _authRepository.bacaAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const GuruAuthException(
        'Sesi Guru tidak ditemukan. Silakan login kembali.',
      );
    }
    return {'Accept': 'image/*', 'Authorization': 'Bearer $token'};
  }
}
