enum StatusKehadiran {
  hadir('Hadir'),
  izin('Izin'),
  sakit('Sakit'),
  alpha('Alpha'),
  belumLengkap('Belum Lengkap');

  final String label;
  const StatusKehadiran(this.label);

  static StatusKehadiran fromJson(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'hadir':
        return StatusKehadiran.hadir;
      case 'izin':
        return StatusKehadiran.izin;
      case 'sakit':
        return StatusKehadiran.sakit;
      case 'alpha':
        return StatusKehadiran.alpha;
      case 'belum_lengkap':
        return StatusKehadiran.belumLengkap;
      default:
        return StatusKehadiran.belumLengkap;
    }
  }
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

  factory SiswaBimbingan.fromJson(Map<String, dynamic> json) {
    final persentase =
        num.tryParse('${json['persentase_kehadiran'] ?? 0}') ?? 0;

    return SiswaBimbingan(
      id: '${json['siswa_id'] ?? json['id'] ?? ''}',
      nama: '${json['nama_lengkap'] ?? json['nama'] ?? ''}',
      nis: '${json['nis'] ?? ''}',
      kelas: '${json['kelas'] ?? '-'}',
      instansi: '${json['instansi'] ?? '-'}',
      status: StatusKehadiran.fromJson(
        json['status_kehadiran'] ?? json['status'],
      ),
      pembimbingIndustri: '${json['pembimbing_industri'] ?? '-'}',
      periodePkl: '${json['periode_pkl'] ?? '-'}',
      persentaseKehadiran: persentase.round(),
    );
  }
}
