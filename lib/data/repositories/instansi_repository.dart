import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class InstansiException implements Exception {
  final String message;

  const InstansiException(this.message);

  @override
  String toString() => message;
}

class InstansiOption {
  final int id;
  final String nama;

  const InstansiOption({required this.id, required this.nama});
}

class InstansiRepository {
  static const String _tokenKey = 'guru_access_token';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;

  InstansiRepository({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  Uri get _url {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/guru/instansi');
  }

  Future<List<InstansiOption>> ambilDaftar() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.trim().isEmpty) {
      throw const InstansiException(
        'Sesi Guru tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await _client
          .get(
            _url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);

      final decoded = _decodeResponse(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw InstansiException(
          _errorMessage(decoded, 'Data instansi gagal dimuat dari server.'),
        );
      }

      final items = _extractItems(decoded);
      final instansi = <InstansiOption>[];
      final seen = <int>{};

      for (final item in items) {
        final option = _extractInstansi(item);
        if (seen.add(option.id)) {
          instansi.add(option);
        }
      }

      return instansi;
    } on InstansiException {
      rethrow;
    } on TimeoutException {
      throw const InstansiException(
        'Permintaan data instansi terlalu lama. Periksa koneksi API.',
      );
    } on http.ClientException {
      throw const InstansiException(
        'Tidak dapat terhubung ke server API. Periksa alamat dan koneksi server.',
      );
    } on FormatException {
      throw const InstansiException('Format respons API instansi tidak valid.');
    }
  }

  dynamic _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      rethrow;
    }
  }

  List<dynamic> _extractItems(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) {
      throw const InstansiException(
        'Format daftar instansi dari server tidak valid.',
      );
    }

    final payload = Map<String, dynamic>.from(decoded);
    if (payload['success'] == false) {
      throw InstansiException(
        _errorMessage(payload, 'Server menolak permintaan data instansi.'),
      );
    }

    dynamic data = payload['data'] ?? payload['instansi'] ?? payload['items'];
    if (data is Map) {
      final nested = Map<String, dynamic>.from(data);
      data = nested['data'] ?? nested['instansi'] ?? nested['items'];
    }
    if (data is List) return data;

    throw const InstansiException(
      'Format daftar instansi dari server tidak valid. API harus mengembalikan data berupa array.',
    );
  }

  InstansiOption _extractInstansi(dynamic item) {
    if (item is! Map) {
      throw const InstansiException(
        'Format data instansi dari server tidak valid.',
      );
    }
    final data = Map<String, dynamic>.from(item);
    final rawId = data['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    final nama = data['nama'];
    if (id == null || id <= 0 || nama is! String || nama.trim().isEmpty) {
      throw const InstansiException(
        'Data instansi dari server tidak memiliki ID atau nama yang valid.',
      );
    }
    return InstansiOption(id: id, nama: nama.trim());
  }

  String _errorMessage(dynamic payload, String fallback) {
    if (payload is Map) {
      final message = payload['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }
}
