enum StatusKehadiran {
  hadir('Hadir'),
  izin('Izin'),
  alpha('Alpha');

  final String label;
  const StatusKehadiran(this.label);
}

class SiswaBimbingan {
  final String id;
  final String nama;
  final String nis;
  final String kelas;
  final String instansi;
  final StatusKehadiran status;
  final String pembimbingIndustri;
  final String periodePkl;
  final int persentaseKehadiran;

  const SiswaBimbingan({
    required this.id,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.instansi,
    required this.status,
    this.pembimbingIndustri = '-',
    this.periodePkl = '-',
    this.persentaseKehadiran = 0,
  });

  /// "Ahmad Rizky Pratama" -> "AR"
  String get inisial {
    final kata = nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .toList();
    if (kata.isEmpty) return '?';
    if (kata.length == 1) return kata.first[0].toUpperCase();
    return (kata[0][0] + kata[1][0]).toUpperCase();
  }

  /// Sesuaikan key dengan response API backend.
  factory SiswaBimbingan.fromJson(Map<String, dynamic> json) {
    return SiswaBimbingan(
      id: '${json['id']}',
      nama: (json['nama'] ?? '') as String,
      nis: (json['nis'] ?? '') as String,
      kelas: (json['kelas'] ?? '') as String,
      instansi: (json['instansi'] ?? '') as String,
      status: StatusKehadiran.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => StatusKehadiran.hadir,
      ),
      pembimbingIndustri: (json['pembimbing_industri'] ?? '-') as String,
      periodePkl: (json['periode_pkl'] ?? '-') as String,
      persentaseKehadiran: (json['persentase_kehadiran'] ?? 0) as int,
    );
  }
}
