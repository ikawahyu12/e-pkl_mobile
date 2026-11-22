import '../models/siswa_bimbingan_model.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository_api.dart';
import 'siswa_bimbingan_repository.dart';

class SiswaBimbinganRepositoryApi implements SiswaBimbinganRepository {
  final GuruApiClient _apiClient;

  SiswaBimbinganRepositoryApi({GuruApiClient? apiClient})
    : _apiClient =
          apiClient ?? GuruApiClient(authRepository: GuruAuthRepositoryApi());

  @override
  Future<List<SiswaBimbingan>> ambilDaftar() async {
    final response = await _apiClient.send(
      method: 'GET',
      path: 'guru/siswa-bimbingan',
    );

    final data = response['data'];

    if (data is! List) {
      throw Exception('Format data siswa bimbingan tidak valid.');
    }

    return data.map((item) {
      if (item is! Map) {
        throw Exception('Format data siswa tidak valid.');
      }

      return SiswaBimbingan.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  @override
  Future<SiswaBimbingan> ambilDetail(String id) async {
    final response = await _apiClient.send(
      method: 'GET',
      path: 'guru/siswa-bimbingan/$id',
    );

    final data = response['data'];

    if (data is! Map) {
      throw Exception('Format detail siswa tidak valid.');
    }

    return SiswaBimbingan.fromJson(Map<String, dynamic>.from(data));
  }
}
