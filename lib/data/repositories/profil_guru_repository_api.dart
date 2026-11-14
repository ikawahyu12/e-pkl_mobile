// Simpan di: lib/data/repositories/profil_guru_repository_api.dart (timpa file lama)
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' show XFile;

import '../../core/config/api_config.dart';
import '../models/profil_guru_model.dart';
import 'guru_auth_repository.dart';
import 'guru_auth_repository_api.dart';
import 'profil_guru_repository.dart';

class ProfilGuruException implements Exception {
  final String message;
  const ProfilGuruException(this.message);

  @override
  String toString() => message;
}

class ProfilGuruRepositoryApi implements ProfilGuruRepository {
  // Harus sama dengan _tokenKey di GuruAuthRepositoryApi.
  static const String _tokenKey = 'guru_access_token';
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const Duration _uploadTimeout = Duration(seconds: 40);

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final GuruAuthRepository _auth;

  ProfilGuruRepositoryApi({
    http.Client? client,
    FlutterSecureStorage? storage,
    GuruAuthRepository? auth,
  }) : _client = client ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage(),
       _auth = auth ?? GuruAuthRepositoryApi(client: client, storage: storage);

  Uri _url(String path) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/$path');
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const ProfilGuruException('Format respons server tidak valid.');
    } on FormatException {
      throw const ProfilGuruException('Respons server tidak dapat dibaca.');
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

  Future<String> _bacaToken() async {
    String? token;
    try {
      token = await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const ProfilGuruException(
        'Sesi aman tidak dapat dibaca dari perangkat.',
      );
    }
    if (token == null || token.trim().isEmpty) {
      throw const ProfilGuruException(
        'Sesi tidak ditemukan. Silakan login ulang.',
      );
    }
    return token;
  }

  /// Membungkus semua error jaringan menjadi ProfilGuruException.
  Future<T> _aman<T>(Future<T> Function() aksi, String pesanGagal) async {
    try {
      return await aksi();
    } on ProfilGuruException {
      rethrow;
    } on TimeoutException {
      throw const ProfilGuruException(
        'Permintaan terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const ProfilGuruException(
        'Tidak dapat terhubung ke server. Periksa koneksi API.',
      );
    } catch (_) {
      throw ProfilGuruException(pesanGagal);
    }
  }

  /// Memproses respons: cek sesi, cek sukses, kembalikan body.
  Map<String, dynamic> _proses(http.Response response, String pesanGagal) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ProfilGuruException('Sesi berakhir. Silakan login ulang.');
    }
    final data = _decode(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw ProfilGuruException(_pesanError(data, pesanGagal));
    }
    return data;
  }

  ProfilGuru _bacaProfil(Map<String, dynamic> data) {
    final payload = data['data'];
    if (payload is! Map) {
      throw const ProfilGuruException('Format data profil tidak valid.');
    }
    return ProfilGuru.fromJson(Map<String, dynamic>.from(payload));
  }

  @override
  Future<ProfilGuru> ambilProfil() async {
    final token = await _bacaToken();
    return _aman(() async {
      final response = await _client
          .get(
            _url('guru/profil'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);
      return _bacaProfil(_proses(response, 'Gagal memuat profil.'));
    }, 'Profil tidak dapat dimuat.');
  }

  @override
  Future<ProfilGuru> ubahProfil({
    required String nama,
    String? email,
    String? noHp,
    XFile? foto,
  }) async {
    final token = await _bacaToken();
    return _aman(() async {
      // Multipart supaya foto bisa ikut terkirim (sama seperti profil siswa).
      final request = http.MultipartRequest('POST', _url('guru/profil'))
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['nama'] = nama;
      if (email != null) request.fields['email'] = email;
      if (noHp != null) request.fields['no_hp'] = noHp;
      if (foto != null) {
        final bytes = await foto.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('foto', bytes, filename: foto.name),
        );
      }

      final streamed = await _client.send(request).timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      return _bacaProfil(_proses(response, 'Profil gagal diperbarui.'));
    }, 'Profil tidak dapat diperbarui.');
  }

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    final token = await _bacaToken();
    await _aman(() async {
      final response = await _client
          .post(
            _url('guru/profil/password'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'password_lama': passwordLama,
              'password_baru': passwordBaru,
            }),
          )
          .timeout(_requestTimeout);
      _proses(response, 'Kata sandi gagal diubah.');
    }, 'Kata sandi tidak dapat diubah.');
  }

  @override
  Future<void> logout() => _auth.keluar();
}