import '../../core/config/api_config.dart';

class JurnalModel {
  final String id;
  final int? penempatanId;
  final String namaSiswa;
  final String nisn;
  final String tanggal;
  final String judul;
  final String kegiatan;
  final String? hasil;
  final String? kendala;
  final List<JurnalLampiran> dokumentasi;

  const JurnalModel({
    required this.id,
    required this.penempatanId,
    required this.namaSiswa,
    required this.nisn,
    required this.tanggal,
    required this.judul,
    required this.kegiatan,
    required this.hasil,
    required this.kendala,
    required this.dokumentasi,
  });

  factory JurnalModel.fromJson(Map<String, dynamic> json) {
    final siswaData = json['siswa'];
    final siswa = siswaData is Map
        ? Map<String, dynamic>.from(siswaData)
        : const <String, dynamic>{};
    final lampiranData = json['dokumentasi'];
    final lampiran = lampiranData is List
        ? lampiranData
              .whereType<Map>()
              .map(
                (item) =>
                    JurnalLampiran.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <JurnalLampiran>[];

    return JurnalModel(
      id: json['id']?.toString() ?? '',
      penempatanId: int.tryParse(json['penempatan_id']?.toString() ?? ''),
      namaSiswa: siswa['nama_lengkap']?.toString() ?? '',
      nisn: siswa['nisn']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      kegiatan: json['kegiatan']?.toString() ?? '',
      hasil: json['hasil']?.toString(),
      kendala: json['kendala']?.toString(),
      dokumentasi: lampiran,
    );
  }
}

class JurnalLampiran {
  final String namaFile;
  final String mimeType;
  final String url;

  const JurnalLampiran({
    required this.namaFile,
    required this.mimeType,
    required this.url,
  });

  factory JurnalLampiran.fromJson(Map<String, dynamic> json) {
    return JurnalLampiran(
      namaFile: json['nama_file']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      url: _resolveDokumentasiUrl(json['url']),
    );
  }
}

String _resolveDokumentasiUrl(dynamic value) {
  if (value is! String || value.trim().isEmpty) return '';

  final uri = Uri.tryParse(value.trim());
  if (uri == null) return '';
  final apiUri = Uri.tryParse(ApiConfig.baseUrl);
  if (apiUri == null) return uri.toString();

  if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
    return Uri(
      scheme: apiUri.scheme,
      userInfo: apiUri.userInfo,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    ).toString();
  }
  if (!uri.hasAuthority && uri.path.startsWith('/')) {
    return apiUri.replace(path: uri.path).toString();
  }
  return uri.toString();
}
