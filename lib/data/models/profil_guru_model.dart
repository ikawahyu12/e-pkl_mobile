class ProfilGuru {
  final String nama;
  final String nip;
  final String sekolah;
  final String bimbingan;
  final String peran;
  final String? email;
  final String? noHp;

  const ProfilGuru({
    required this.nama,
    required this.nip,
    required this.sekolah,
    required this.bimbingan,
    this.peran = 'Guru Pembimbing PKL',
    this.email,
    this.noHp,
  });

  /// Inisial untuk avatar, mis. "Andini Rahmawati, S.Pd." -> "AR".
  String get inisial {
    final kata = nama
        .replaceAll(RegExp(r',.*$'), '') // buang gelar setelah koma
        .trim()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .toList();
    if (kata.isEmpty) return '?';
    if (kata.length == 1) return kata.first[0].toUpperCase();
    return (kata[0][0] + kata[1][0]).toUpperCase();
  }

  /// Sesuaikan key dengan response API backend.
  factory ProfilGuru.fromJson(Map<String, dynamic> json) {
    return ProfilGuru(
      nama: (json['nama'] ?? '') as String,
      nip: (json['nip'] ?? '') as String,
      sekolah: (json['sekolah'] ?? '') as String,
      bimbingan: (json['bimbingan'] ?? '') as String,
      peran: (json['peran'] ?? 'Guru Pembimbing PKL') as String,
      email: json['email'] as String?,
      noHp: json['no_hp'] as String?,
    );
  }

  ProfilGuru copyWith({String? nama, String? email, String? noHp}) {
    return ProfilGuru(
      nama: nama ?? this.nama,
      nip: nip,
      sekolah: sekolah,
      bimbingan: bimbingan,
      peran: peran,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
    );
  }
}