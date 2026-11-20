import '../../features/guru/agenda/agenda_data.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository.dart';

abstract interface class GuruPresensiRepository {
  Future<int> bukaSesi({
    required int instansiId,
    required List<int> siswaIds,
    required DateTime tanggal,
    required String jamMasukMulai,
    required String jamMasukSelesai,
    required String jamPulangMulai,
    required String jamPulangSelesai,
  });
}

class GuruPresensiRepositoryApi implements GuruPresensiRepository {
  final GuruApiClient _api;

  GuruPresensiRepositoryApi({
    required GuruAuthRepository authRepository,
    GuruApiClient? api,
  }) : _api = api ?? GuruApiClient(authRepository: authRepository);

  @override
  Future<int> bukaSesi({
    required int instansiId,
    required List<int> siswaIds,
    required DateTime tanggal,
    required String jamMasukMulai,
    required String jamMasukSelesai,
    required String jamPulangMulai,
    required String jamPulangSelesai,
  }) async {
    final response = await _api.send(
      method: 'POST',
      path: 'guru/presensi/sesi',
      body: {
        'instansi_id': instansiId,
        'siswa_ids': siswaIds,
        'tanggal': kunciTanggal(tanggal),
        'jam_masuk_mulai': jamMasukMulai,
        'jam_masuk_selesai': jamMasukSelesai,
        'jam_pulang_mulai': jamPulangMulai,
        'jam_pulang_selesai': jamPulangSelesai,
      },
    );

    final data = response['data'];
    if (data is! Map || data['id'] is! num) {
      throw const FormatException('Respons pembukaan sesi presensi tidak valid.');
    }
    return (data['id'] as num).toInt();
  }
}
