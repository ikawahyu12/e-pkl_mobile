import '../../features/guru/agenda/agenda_data.dart';
import 'guru_api_client.dart';
import 'guru_auth_repository.dart';

class AgendaSiswaOption {
  final int id;
  final String nama;
  final String? kelas;
  final String? nis;

  const AgendaSiswaOption({
    required this.id,
    required this.nama,
    this.kelas,
    this.nis,
  });
}

class AgendaInstansiOption {
  final int id;
  final String nama;
  final String alamat;
  final List<AgendaSiswaOption> siswa;

  const AgendaInstansiOption({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.siswa,
  });
}

abstract interface class AgendaRepository {
  Future<List<AgendaItem>> ambilAgenda({
    required DateTime dari,
    required DateTime sampai,
  });

  Future<List<AgendaInstansiOption>> ambilOpsi(DateTime tanggal);

  Future<AgendaItem> tambah({
    required int instansiId,
    required List<int> siswaIds,
    required DateTime tanggal,
    required String jamMulai,
    required String jamSelesai,
    String? catatan,
  });

  Future<AgendaItem> ubahStatus({
    required int id,
    required StatusAgenda status,
    String? alasanPembatalan,
  });
}

class AgendaRepositoryApi implements AgendaRepository {
  final GuruApiClient _api;

  AgendaRepositoryApi({
    required GuruAuthRepository authRepository,
    GuruApiClient? api,
  }) : _api = api ?? GuruApiClient(authRepository: authRepository);

  @override
  Future<List<AgendaItem>> ambilAgenda({
    required DateTime dari,
    required DateTime sampai,
  }) async {
    final response = await _api.send(
      method: 'GET',
      path: 'guru/agenda',
      queryParameters: {
        'dari': kunciTanggal(dari),
        'sampai': kunciTanggal(sampai),
      },
    );
    return _list(response['data']).map(AgendaItem.fromJson).toList();
  }

  @override
  Future<List<AgendaInstansiOption>> ambilOpsi(DateTime tanggal) async {
    final response = await _api.send(
      method: 'GET',
      path: 'guru/agenda/opsi',
      queryParameters: {'tanggal': kunciTanggal(tanggal)},
    );
    return _list(response['data']).map((item) {
      final students = _list(item['siswa']).map((student) {
        return AgendaSiswaOption(
          id: (student['id'] as num).toInt(),
          nama: student['nama']?.toString() ?? '',
          kelas: student['kelas']?.toString(),
          nis: student['nis']?.toString(),
        );
      }).toList();

      return AgendaInstansiOption(
        id: ((item['instansi_id'] ?? item['id']) as num).toInt(),
        nama: item['nama']?.toString() ?? '',
        alamat: item['alamat']?.toString() ?? '',
        siswa: students,
      );
    }).toList();
  }

  @override
  Future<AgendaItem> tambah({
    required int instansiId,
    required List<int> siswaIds,
    required DateTime tanggal,
    required String jamMulai,
    required String jamSelesai,
    String? catatan,
  }) async {
    final response = await _api.send(
      method: 'POST',
      path: 'guru/agenda',
      body: {
        'instansi_id': instansiId,
        'siswa_ids': siswaIds,
        'tanggal': kunciTanggal(tanggal),
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'catatan': catatan,
      },
    );
    return AgendaItem.fromJson(_map(response['data']));
  }

  @override
  Future<AgendaItem> ubahStatus({
    required int id,
    required StatusAgenda status,
    String? alasanPembatalan,
  }) async {
    final statusApi = switch (status) {
      StatusAgenda.selesai => 'selesai',
      StatusAgenda.dibatalkan => 'dibatalkan',
      StatusAgenda.terjadwal => throw ArgumentError(
        'Agenda terjadwal tidak dapat mengubah status melalui endpoint ini.',
      ),
    };
    final response = await _api.send(
      method: 'PATCH',
      path: 'guru/agenda/$id/status',
      body: {
        'status': statusApi,
        if (alasanPembatalan != null)
          'alasan_pembatalan': alasanPembatalan.trim(),
      },
    );
    return AgendaItem.fromJson(_map(response['data']));
  }

  List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) {
      throw const FormatException('Daftar agenda dari server tidak valid.');
    }
    return value.whereType<Map>().map(_map).toList();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Data agenda dari server tidak valid.');
  }
}
