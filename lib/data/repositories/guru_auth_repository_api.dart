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

  @override
  Future<String?> bacaAccessToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const GuruAuthException(
        'Token sesi tidak dapat dibaca dari perangkat.',
      );
    }
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
  Future<void> daftarGuru({
    required String nip,
    required String namaLengkap,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client
          .post(
            _url('guru/auth/register'),
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode({
              'nip': nip.trim(),
              'nama_lengkap': namaLengkap.trim(),
              'email': email.trim(),
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(_requestTimeout);
      final data = _decodeResponse(response);

      if (response.statusCode != 202 || data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Registrasi Guru tidak dapat diproses.'),
        );
      }
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan registrasi terlalu lama. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const GuruAuthException('Tidak dapat terhubung ke server API.');
    } catch (_) {
      throw const GuruAuthException('Registrasi Guru tidak dapat diproses.');
    }
  }

  @override
  Future<void> kirimUlangVerifikasiGuru({required String email}) async {
    try {
      final response = await _client
          .post(
            _url('guru/auth/resend-verification'),
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim()}),
          )
          .timeout(_requestTimeout);
      final data = _decodeResponse(response);

      if (response.statusCode != 202 || data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Tautan verifikasi tidak dapat dikirim ulang.'),
        );
      }
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan terlalu lama. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const GuruAuthException('Tidak dapat terhubung ke server API.');
    } catch (_) {
      throw const GuruAuthException(
        'Tautan verifikasi tidak dapat dikirim ulang.',
      );
    }
  }

  @override
  Future<void> mintaResetPassword({required String email}) async {
    try {
      final response = await _client
          .post(
            _url('guru/auth/forgot-password'),
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_requestTimeout);
      final data = _decodeResponse(response);

      if (response.statusCode != 202 || data['success'] != true) {
        throw GuruAuthException(
          _pesanError(
            data,
            'Permintaan reset kata sandi tidak dapat diproses.',
          ),
        );
      }
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const GuruAuthException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const GuruAuthException(
        'Permintaan reset kata sandi tidak dapat diproses.',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    try {
      final response = await _client
          .post(
            _url('guru/auth/reset-password'),
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'token': token,
              'password_baru': passwordBaru,
              'password_baru_confirmation': passwordBaruConfirmation,
            }),
          )
          .timeout(_requestTimeout);
      final data = _decodeResponse(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Tautan reset tidak valid atau telah kedaluwarsa.'),
        );
      }
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const GuruAuthException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const GuruAuthException('Reset kata sandi tidak dapat diproses.');
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
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    String? token;

    try {
      token = await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const GuruAuthException(
        'Token sesi tidak dapat dibaca dari perangkat.',
      );
    }

    if (token == null || token.trim().isEmpty) {
      throw const GuruAuthException(
        'Sesi Guru tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await _client
          .post(
            _url('guru/auth/password'),
            headers: {
              ..._headers(token: token),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'password_lama': passwordLama,
              'password_baru': passwordBaru,
              'password_baru_confirmation': passwordBaruConfirmation,
            }),
          )
          .timeout(_requestTimeout);

      final data = _decodeResponse(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw GuruAuthException(
          _pesanError(data, 'Gagal mengubah kata sandi Guru.'),
        );
      }
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Permintaan terlalu lama. Periksa koneksi server.',
      );
    } on http.ClientException {
      throw const GuruAuthException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const GuruAuthException('Ganti kata sandi tidak dapat diproses.');
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
