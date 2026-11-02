class Penilaian {
  /// Urutan aspek HARUS sama dengan urutan [nilai].
  static const List<String> namaAspek = [
    'Sikap & Disiplin',
    'Keterampilan Kerja',
    'Pengetahuan',
    'Inisiatif & Kreativitas',
    'Kerjasama Tim',
  ];

  static const List<String> _kunciJson = [
    'sikap_disiplin',
    'keterampilan_kerja',
    'pengetahuan',
    'inisiatif_kreativitas',
    'kerjasama_tim',
  ];

  final String siswaId;
  final List<int> nilai;
  final String catatan;
  final DateTime? disimpanPada;

  const Penilaian({
    required this.siswaId,
    required this.nilai,
    this.catatan = '',
    this.disimpanPada,
  });

  double get rataRata => hitungRata(nilai);
  String get predikat => hitungPredikat(rataRata);

  static bool nilaiValid(int? v) => v != null && v >= 0 && v <= 100;

  static double hitungRata(List<int> n) {
    if (n.isEmpty) return 0;
    return n.reduce((a, b) => a + b) / n.length;
  }

  /// TODO: samakan rentang predikat dengan aturan penilaian sekolah.
  static String hitungPredikat(double rata) {
    if (rata >= 90) return 'A';
    if (rata >= 85) return 'A-';
    if (rata >= 80) return 'B+';
    if (rata >= 75) return 'B';
    if (rata >= 70) return 'B-';
    if (rata >= 65) return 'C+';
    if (rata >= 60) return 'C';
    return 'D';
  }

  /// Sesuaikan key dengan response API backend.
  factory Penilaian.fromJson(Map<String, dynamic> json) {
    final n = (json['nilai'] as Map<String, dynamic>?) ?? const {};
    return Penilaian(
      siswaId: '${json['siswa_id']}',
      nilai: _kunciJson.map((k) => ((n[k] as num?) ?? 0).toInt()).toList(),
      catatan: (json['catatan'] ?? '') as String,
      disimpanPada: json['disimpan_pada'] == null
          ? null
          : DateTime.tryParse('${json['disimpan_pada']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswa_id': siswaId,
      'nilai': {
        for (var i = 0; i < _kunciJson.length; i++) _kunciJson[i]: nilai[i],
      },
      'catatan': catatan,
    };
  }
}
