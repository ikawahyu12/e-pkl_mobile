// Simpan di: lib/data/repositories/agenda_repository_api.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../features/guru/agenda/agenda_data.dart';
import 'agenda_repository.dart';

class AgendaException implements Exception {
  final String message;
  const AgendaException(this.message);

  @override
  String toString() => message;
}

class AgendaRepositoryApi implements AgendaRepository {
  // Harus sama dengan _tokenKey di GuruAuthRepositoryApi.
  static const String _tokenKey = 'guru_access_token';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;

  AgendaRepositoryApi({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  Uri _url(String path, [Map<String, String>? query]) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$baseUrl/$path');
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Future<String> _bacaToken() async {
    String? token;
    try {
      token = await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const AgendaException('Sesi aman tidak dapat dibaca dari perangkat.');
    }
    if (token == null || token.trim().isEmpty) {
      throw const AgendaException('Sesi tidak ditemukan. Silakan login ulang.');
    }
    return token;
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const AgendaException('Format respons server tidak valid.');
    } on FormatException {
      throw const AgendaException('Respons server tidak dapat dibaca.');
    }
  }

  /// Utamakan pesan validasi field (422), lalu pesan umum.
  String _pesanError(Map<String, dynamic> data, String pesanDefault) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    final message = data['message']?.toString().trim();
    return message == null || message.isEmpty ? pesanDefault : message;
  }

  /// Satu pintu untuk semua request: token, timeout, dan pemetaan error.
  Future<Map<String, dynamic>> _panggil(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required String pesanGagal,
  }) async {
    final token = await _bacaToken();
    try {
      final request = http.Request(method, _url(path, query))
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _client.send(request).timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AgendaException('Sesi berakhir. Silakan login ulang.');
      }
      final data = _decode(response);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw AgendaException(_pesanError(data, pesanGagal));
      }
      return data;
    } on AgendaException {
      rethrow;
    } on TimeoutException {
      throw const AgendaException(
        'Permintaan terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const AgendaException(
        'Tidak dapat terhubung ke server. Periksa koneksi API.',
      );
    } catch (_) {
      throw AgendaException(pesanGagal);
    }
  }

  AgendaItem _bacaItem(Map<String, dynamic> data) {
    final payload = data['data'];
    if (payload is! Map) {
      throw const AgendaException('Format data agenda tidak valid.');
    }
    return AgendaItem.fromJson(Map<String, dynamic>.from(payload));
  }

  @override
  Future<Map<String, List<AgendaItem>>> ambilRentang(
    DateTime dari,
    DateTime sampai,
  ) async {
    final data = await _panggil(
      'GET',
      'guru/agenda',
      query: {'dari': kunciTanggal(dari), 'sampai': kunciTanggal(sampai)},
      pesanGagal: 'Agenda tidak dapat dimuat.',
    );

    final daftar = data['data'];
    if (daftar is! List) {
      throw const AgendaException('Format data agenda tidak valid.');
    }

    final hasil = <String, List<AgendaItem>>{};
    for (final row in daftar.whereType<Map>()) {
      final json = Map<String, dynamic>.from(row);
      final kunci = json['tanggal']?.toString();
      if (kunci == null) continue;
      hasil.putIfAbsent(kunci, () => []).add(AgendaItem.fromJson(json));
    }
    return hasil;
  }

  @override
  Future<List<TempatOpsi>> ambilOpsi() async {
    final data = await _panggil(
      'GET',
      'guru/agenda/opsi',
      pesanGagal: 'Daftar tempat PKL tidak dapat dimuat.',
    );
    final daftar = data['data'];
    if (daftar is! List) {
      throw const AgendaException('Format daftar tempat PKL tidak valid.');
    }
    return daftar
        .whereType<Map>()
        .map((t) => TempatOpsi.fromJson(Map<String, dynamic>.from(t)))
        .toList();
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
    final data = await _panggil(
      'POST',
      'guru/agenda',
      body: {
        'instansi_id': instansiId,
        'siswa_ids': siswaIds,
        'tanggal': kunciTanggal(tanggal),
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'catatan': catatan,
      },
      pesanGagal: 'Jadwal gagal disimpan.',
    );
    return _bacaItem(data);
  }

  @override
  Future<AgendaItem> ubahStatus(int id, StatusAgenda status) async {
    final data = await _panggil(
      'PATCH',
      'guru/agenda/$id/status',
      body: {'status': status == StatusAgenda.selesai ? 'selesai' : 'terjadwal'},
      pesanGagal: 'Status agenda gagal diperbarui.',
    );
    return _bacaItem(data);
  }

  @override
  Future<void> hapus(int id) async {
    await _panggil(
      'DELETE',
      'guru/agenda/$id',
      pesanGagal: 'Jadwal gagal dihapus.',
    );
  }
}