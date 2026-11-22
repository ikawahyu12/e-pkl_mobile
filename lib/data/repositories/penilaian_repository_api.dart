import '../models/penilaian_model.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository_api.dart';
import 'penilaian_repository.dart';

class PenilaianRepositoryApi implements PenilaianRepository {
  final GuruApiClient _apiClient;

  PenilaianRepositoryApi({GuruApiClient? apiClient})
    : _apiClient =
          apiClient ?? GuruApiClient(authRepository: GuruAuthRepositoryApi());

  /// Mengambil penilaian siswa dari backend Laravel.
  @override
  Future<Penilaian?> ambilPenilaian(String siswaId) async {
    final response = await _apiClient.send(
      method: 'GET',
      path: 'guru/penilaian/$siswaId',
    );

    final data = response['data'];

    if (data == null) {
      return null;
    }

    if (data is! Map) {
      throw Exception('Format data penilaian tidak valid.');
    }

    final dataPenilaian = Map<String, dynamic>.from(data);

    // Siswa belum pernah memiliki penilaian.
    if (dataPenilaian['nilai'] == null) {
      return null;
    }

    return Penilaian.fromJson(dataPenilaian);
  }

  /// Menyimpan atau memperbarui penilaian ke backend Laravel.
  @override
  Future<Penilaian> simpanPenilaian(Penilaian penilaian) async {
    final response = await _apiClient.send(
      method: 'POST',
      path: 'guru/penilaian',
      body: penilaian.toJson(),
    );

    final data = response['data'];

    if (data is! Map) {
      throw Exception('Data hasil penyimpanan tidak valid.');
    }

    final dataPenilaian = Map<String, dynamic>.from(data);

    if (dataPenilaian['nilai'] == null) {
      throw Exception('Data penilaian yang disimpan tidak lengkap.');
    }

    return Penilaian.fromJson(dataPenilaian);
  }

  /// Mengambil riwayat perubahan penilaian siswa.
  Future<List<Map<String, dynamic>>> ambilRiwayat(String siswaId) async {
    final response = await _apiClient.send(
      method: 'GET',
      path: 'guru/penilaian/$siswaId/riwayat',
    );

    final data = response['data'];

    if (data is! List) {
      throw Exception('Format riwayat penilaian tidak valid.');
    }

    return data.map((item) {
      if (item is! Map) {
        throw Exception('Format item riwayat penilaian tidak valid.');
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }
}
