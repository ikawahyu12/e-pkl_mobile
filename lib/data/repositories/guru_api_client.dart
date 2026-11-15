import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'guru_auth_repository.dart';

class GuruApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  final GuruAuthRepository _authRepository;
  final http.Client _client;

  GuruApiClient({
    required GuruAuthRepository authRepository,
    http.Client? client,
  }) : _authRepository = authRepository,
       _client = client ?? http.Client();

  Future<Map<String, dynamic>> send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final token = await _authRepository.bacaAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const GuruAuthException(
        'Sesi Guru tidak ditemukan. Silakan login kembali.',
      );
    }

    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse(
      '$baseUrl/$path',
    ).replace(queryParameters: queryParameters);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(_timeout);
      final decoded = _decode(response);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        final message = decoded['message']?.toString().trim();
        throw GuruAuthException(
          message == null || message.isEmpty
              ? 'Permintaan ke server gagal (${response.statusCode}).'
              : message,
        );
      }

      return decoded;
    } on GuruAuthException {
      rethrow;
    } on TimeoutException {
      throw const GuruAuthException(
        'Server terlalu lama merespons. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const GuruAuthException(
        'Tidak dapat terhubung ke server. Periksa koneksi API.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw const GuruAuthException('Respons server tidak dapat dibaca.');
    }
    throw const GuruAuthException('Format respons server tidak valid.');
  }
}
