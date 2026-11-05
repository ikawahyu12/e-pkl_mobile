import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/guru_auth_session.dart';
import 'guru_auth_repository.dart';

class GuruAuthRepositoryApi implements GuruAuthRepository {
  static const String _tokenKey = 'guru_access_token';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;

  GuruAuthRepositoryApi({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  Uri _url(String path) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/$path');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const GuruAuthException('Format respons server tidak valid.');
    } on FormatException {
      throw const GuruAuthException('Respons server tidak dapat dibaca.');
    }
  }

  String _pesanError(Map<String, dynamic> data, String pesanDefault) {
    final message = data['message']?.toString().trim();
    return message == null || message.isEmpty ? pesanDefault : message;
  }

  Map<String, String> _headers({String? token}) => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  @override
  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            _url('guru/auth/login'),
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode({'login': identifier, 'password': password}),
          )
          .timeout(_requestTimeout);

      final data = _decodeResponse(response);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Login gagal. Periksa akun dan password.'),
        );
      }

      final responseData = data['data'];
      if (responseData is! Map) {
        throw const GuruAuthException('Format respons login tidak valid.');
      }
      final session = GuruAuthSession.fromJson(
        Map<String, dynamic>.from(responseData),
      );
      if (!session.isValidGuruSession) {
        throw const GuruAuthException(
          'Akun ini tidak memiliki akses sebagai Guru.',
        );
      }

      try {
        await _storage.write(key: _tokenKey, value: session.accessToken);
      } catch (_) {
        await _cabutToken(session.accessToken);
        throw const GuruAuthException(
          'Login berhasil, tetapi sesi tidak dapat disimpan dengan aman.',
        );
      }
      return session;
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan login terlalu lama. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const GuruAuthException(
        'Tidak dapat terhubung ke server. Periksa koneksi API.',
      );
    } catch (_) {
      throw const GuruAuthException(
        'Login tidak dapat diproses. Periksa koneksi dan konfigurasi API.',
      );
    }
  }

  @override
  Future<GuruAuthSession?> pulihkanSesi() async {
    String? token;
    try {
      token = await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const GuruAuthException(
        'Sesi aman tidak dapat dibaca dari perangkat.',
      );
    }
    if (token == null || token.trim().isEmpty) return null;

    try {
      final response = await _client
          .get(_url('guru/auth/me'), headers: _headers(token: token))
          .timeout(_requestTimeout);
      final data = _decodeResponse(response);

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _storage.delete(key: _tokenKey);
        return null;
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Gagal memeriksa sesi Guru.'),
        );
      }

      final responseData = data['data'];
      final userData = responseData is Map ? responseData['user'] : null;
      if (userData is! Map) {
        throw const GuruAuthException(
          'Format identitas Guru dari server tidak valid.',
        );
      }
      final user = Map<String, dynamic>.from(userData);
      final session = GuruAuthSession(
        accessToken: token,
        role: user['role']?.toString() ?? '',
        user: user,
      );
      if (!session.isValidGuruSession) {
        await _storage.delete(key: _tokenKey);
        return null;
      }
      return session;
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Pemeriksaan sesi terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const GuruAuthException(
        'Tidak dapat memeriksa sesi. Periksa koneksi server.',
      );
    } catch (_) {
      throw const GuruAuthException('Sesi Guru tidak dapat diverifikasi.');
    }
  }

  @override
  Future<void> keluar() async {
    String? token;
    try {
      token = await _storage.read(key: _tokenKey);
    } catch (_) {
      try {
        await _storage.delete(key: _tokenKey);
      } catch (_) {
        throw const GuruAuthException(
          'Token sesi tidak dapat dibaca atau dihapus dari perangkat.',
        );
      }
      throw const GuruAuthException(
        'Sesi lokal dihapus, tetapi server tidak dapat mengonfirmasi logout.',
      );
    }

    GuruAuthException? logoutError;
    try {
      if (token != null && token.isNotEmpty) {
        final response = await _client
            .post(_url('guru/auth/logout'), headers: _headers(token: token))
            .timeout(_requestTimeout);
        if ((response.statusCode < 200 || response.statusCode >= 300) &&
            response.statusCode != 401 &&
            response.statusCode != 403) {
          final data = _decodeResponse(response);
          logoutError = GuruAuthException(
            _pesanError(data, 'Server tidak mengonfirmasi logout.'),
          );
        }
      }
    } on TimeoutException {
      logoutError = const GuruAuthException(
        'Server tidak merespons logout. Sesi lokal akan dihapus.',
      );
    } on http.ClientException {
      logoutError = const GuruAuthException(
        'Server tidak dapat dijangkau. Sesi lokal akan dihapus.',
      );
    } on GuruAuthException catch (error) {
      logoutError = error;
    } finally {
      await _storage.delete(key: _tokenKey);
    }
    if (logoutError != null) throw logoutError;
  }

  Future<void> _cabutToken(String token) async {
    try {
      await _client
          .post(_url('guru/auth/logout'), headers: _headers(token: token))
          .timeout(_requestTimeout);
    } on Exception {
      // The token was not stored locally; cleanup is best effort.
    }
  }
}
