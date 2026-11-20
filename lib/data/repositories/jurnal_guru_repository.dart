import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/jurnal_model.dart';

abstract interface class JurnalGuruRepository {
  Future<List<JurnalModel>> ambilDaftar();
  Future<JurnalModel> ambilDetail(String id);
  Future<Map<String, String>> dokumentasiHeaders();
}

class JurnalGuruException implements Exception {
  final String message;

  const JurnalGuruException(this.message);

  @override
  String toString() => message;
}

class JurnalGuruRepositoryApi implements JurnalGuruRepository {
  static const String _tokenKey = 'guru_access_token';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;

  JurnalGuruRepositoryApi({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  Uri _url(String path) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/$path');
  }

  Future<String> _accessToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.trim().isEmpty) {
      throw const JurnalGuruException(
        'Sesi Guru tidak ditemukan. Silakan login kembali.',
      );
    }

    return token;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await _accessToken();

    try {
      final response = await _client
          .get(
            _url(path),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);
      final payload = _decodeResponse(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          payload['success'] != true) {
        final message = payload['message']?.toString().trim();
        throw JurnalGuruException(
          message == null || message.isEmpty
              ? 'Data jurnal tidak dapat dimuat.'
              : message,
        );
      }

      return payload;
    } on JurnalGuruException {
      rethrow;
    } on TimeoutException {
      throw const JurnalGuruException(
        'Permintaan jurnal terlalu lama. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const JurnalGuruException(
        'Tidak dapat terhubung ke server jurnal. Periksa koneksi API.',
      );
    }
  }

  @override
  Future<Map<String, String>> dokumentasiHeaders() async => {
    'Accept': 'image/*',
    'Authorization': 'Bearer ${await _accessToken()}',
  };

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const JurnalGuruException('Format respons jurnal tidak valid.');
    } on FormatException {
      throw const JurnalGuruException('Respons jurnal tidak dapat dibaca.');
    }
  }

  @override
  Future<List<JurnalModel>> ambilDaftar() async {
    final payload = await _get('guru/jurnal');
    final data = payload['data'];
    if (data is! List) {
      throw const JurnalGuruException(
        'Format daftar jurnal dari server tidak valid.',
      );
    }

    return data
        .whereType<Map>()
        .map((entry) => JurnalModel.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  @override
  Future<JurnalModel> ambilDetail(String id) async {
    final payload = await _get('guru/jurnal/${Uri.encodeComponent(id)}');
    final data = payload['data'];
    if (data is! Map) {
      throw const JurnalGuruException(
        'Format detail jurnal dari server tidak valid.',
      );
    }

    return JurnalModel.fromJson(Map<String, dynamic>.from(data));
  }
}
