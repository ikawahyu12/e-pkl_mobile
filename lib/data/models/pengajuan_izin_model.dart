import '../../core/config/api_config.dart';

class PengajuanIzinModel {
  final String id;
  final String namaSiswa;
  final String nisn;
  final String jenis;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String alasan;
  final String status;
  final List<IzinLampiranModel> lampiran;

  const PengajuanIzinModel({
    required this.id,
    required this.namaSiswa,
    required this.nisn,
    required this.jenis,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    required this.status,
    required this.lampiran,
  });

  factory PengajuanIzinModel.fromJson(Map<String, dynamic> json) {
    final siswaData = json['siswa'];
    final siswa = siswaData is Map
        ? Map<String, dynamic>.from(siswaData)
        : const <String, dynamic>{};
    final lampiranData =
        json['lampiran'] ?? json['dokumentasi'] ?? json['lampiran_url'];

    return PengajuanIzinModel(
      id: json['id']?.toString() ?? '',
      namaSiswa:
          (json['nama_siswa'] ?? json['nama_lengkap'] ?? siswa['nama_lengkap'])
              ?.toString() ??
          '',
      nisn: (json['nisn'] ?? siswa['nisn'])?.toString() ?? '',
      jenis: (json['jenis'] ?? json['jenis_izin'])?.toString() ?? '',
      tanggalMulai:
          (json['tanggal_mulai'] ?? json['tanggal'])?.toString() ?? '',
      tanggalSelesai: json['tanggal_selesai']?.toString() ?? '',
      alasan: (json['alasan'] ?? json['keterangan'])?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lampiran: _parseLampiran(lampiranData),
    );
  }
}

List<IzinLampiranModel> _parseLampiran(dynamic value) {
  if (value is List) {
    return value
        .map(_parseLampiranItem)
        .whereType<IzinLampiranModel>()
        .toList();
  }

  final item = _parseLampiranItem(value);
  return item == null ? const [] : [item];
}

IzinLampiranModel? _parseLampiranItem(dynamic value) {
  if (value is String) {
    final url = _resolveLampiranUrl(value);
    if (url.isEmpty) return null;
    return IzinLampiranModel(
      namaFile: Uri.tryParse(url)?.pathSegments.last ?? '',
      mimeType: '',
      url: url,
    );
  }

  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final rawUrl = json['url'] ?? json['path'] ?? json['file'];
  final url = _resolveLampiranUrl(rawUrl);
  if (url.isEmpty) return null;

  return IzinLampiranModel(
    namaFile:
        (json['nama_file'] ?? json['nama'] ?? json['filename'])?.toString() ??
        '',
    mimeType:
        (json['mime_type'] ?? json['mime'] ?? json['type'])?.toString() ?? '',
    url: url,
  );
}

String _resolveLampiranUrl(dynamic value) {
  if (value is! String || value.trim().isEmpty) return '';

  final uri = Uri.tryParse(value.trim());
  final apiUri = Uri.tryParse(ApiConfig.baseUrl);
  if (uri == null || apiUri == null) return '';

  if (uri.hasScheme) {
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      return apiUri
          .replace(
            path: uri.path,
            query: uri.hasQuery ? uri.query : null,
            fragment: uri.hasFragment ? uri.fragment : null,
          )
          .toString();
    }
    return uri.toString();
  }

  if (uri.path.startsWith('/')) {
    return apiUri
        .replace(
          path: uri.path,
          query: uri.hasQuery ? uri.query : null,
          fragment: uri.hasFragment ? uri.fragment : null,
        )
        .toString();
  }

  final basePath = apiUri.path.replaceFirst(RegExp(r'/+$'), '');
  return apiUri.replace(path: '$basePath/${uri.path}').toString();
}

class IzinLampiranModel {
  final String namaFile;
  final String mimeType;
  final String url;

  const IzinLampiranModel({
    required this.namaFile,
    required this.mimeType,
    required this.url,
  });

  bool get isImage {
    final mime = mimeType.toLowerCase();
    if (mime.startsWith('image/')) return true;
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }
}
