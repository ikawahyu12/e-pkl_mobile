import '../models/siswa_bimbingan_model.dart';

abstract class SiswaBimbinganRepository {
  Future<List<SiswaBimbingan>> ambilDaftar();
  Future<SiswaBimbingan> ambilDetail(String id);
}

/// Data dummy (12 siswa, sesuai "Total 12 siswa" di desain).
/// Urutan list dianggap sudah "terbaru" lebih dulu.
/// TODO: buat SiswaBimbinganRepositoryApi lalu ganti default di page.
class SiswaBimbinganRepositoryMock implements SiswaBimbinganRepository {
  static final SiswaBimbinganRepositoryMock _instance =
      SiswaBimbinganRepositoryMock._();
  factory SiswaBimbinganRepositoryMock() => _instance;
  SiswaBimbinganRepositoryMock._();

  static const String _periode = '3 Agu 2026 – 30 Nov 2026';

  static const List<SiswaBimbingan> _data = [
    SiswaBimbingan(
      id: 's01',
      nama: 'Ahmad Rizky Pratama',
      nis: '1234567890',
      kelas: 'XI RPL',
      instansi: 'PT. Informatika Solusi Nusantara',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Hendra Wijaya',
      periodePkl: _periode,
      persentaseKehadiran: 96,
    ),
    SiswaBimbingan(
      id: 's02',
      nama: 'Siti Nurhaliza',
      nis: '1234567891',
      kelas: 'XI TKJ',
      instansi: 'Dinas Kominfo Kota Bandung',
      status: StatusKehadiran.izin,
      pembimbingIndustri: 'Ibu Ratna Sari',
      periodePkl: _periode,
      persentaseKehadiran: 88,
    ),
    SiswaBimbingan(
      id: 's03',
      nama: 'Muhammad Faisal',
      nis: '1234567892',
      kelas: 'XI RPL',
      instansi: 'CV. Techno Kreatif',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Dimas Aryo',
      periodePkl: _periode,
      persentaseKehadiran: 94,
    ),
    SiswaBimbingan(
      id: 's04',
      nama: 'Nabila Putri',
      nis: '1234567893',
      kelas: 'XI MM',
      instansi: 'PT. Digital Mandiri',
      status: StatusKehadiran.alpha,
      pembimbingIndustri: 'Ibu Laras Ayu',
      periodePkl: _periode,
      persentaseKehadiran: 72,
    ),
    SiswaBimbingan(
      id: 's05',
      nama: 'Dinda Aulia',
      nis: '1234567894',
      kelas: 'XI RPL',
      instansi: 'PT. Kreasi Teknologi Bangsa',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Yoga Prasetyo',
      periodePkl: _periode,
      persentaseKehadiran: 98,
    ),
    SiswaBimbingan(
      id: 's06',
      nama: 'Arya Pratama',
      nis: '1234567895',
      kelas: 'XI TKJ',
      instansi: 'PT. Jaringan Nusantara',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Fikri Hakim',
      periodePkl: _periode,
      persentaseKehadiran: 91,
    ),
    SiswaBimbingan(
      id: 's07',
      nama: 'Rizka Amelia',
      nis: '1234567896',
      kelas: 'XI MM',
      instansi: 'Studio Kreatif Pixel',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Ibu Mira Lestari',
      periodePkl: _periode,
      persentaseKehadiran: 93,
    ),
    SiswaBimbingan(
      id: 's08',
      nama: 'Fajar Ramadhan',
      nis: '1234567897',
      kelas: 'XI RPL',
      instansi: 'CV. Solusi Aplikasi',
      status: StatusKehadiran.izin,
      pembimbingIndustri: 'Bpk. Teguh Santoso',
      periodePkl: _periode,
      persentaseKehadiran: 85,
    ),
    SiswaBimbingan(
      id: 's09',
      nama: 'Putri Maharani',
      nis: '1234567898',
      kelas: 'XI TKJ',
      instansi: 'Dinas Pendidikan Kota Bandung',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Ibu Wulan Sari',
      periodePkl: _periode,
      persentaseKehadiran: 95,
    ),
    SiswaBimbingan(
      id: 's10',
      nama: 'Bagas Saputra',
      nis: '1234567899',
      kelas: 'XI RPL',
      instansi: 'PT. Teknologi Cerdas Indonesia',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Rudi Hartono',
      periodePkl: _periode,
      persentaseKehadiran: 90,
    ),
    SiswaBimbingan(
      id: 's11',
      nama: 'Anisa Fitriani',
      nis: '1234567900',
      kelas: 'XI MM',
      instansi: 'PT. Media Visual Utama',
      status: StatusKehadiran.alpha,
      pembimbingIndustri: 'Ibu Citra Dewi',
      periodePkl: _periode,
      persentaseKehadiran: 76,
    ),
    SiswaBimbingan(
      id: 's12',
      nama: 'Rendi Kurniawan',
      nis: '1234567901',
      kelas: 'XI TKJ',
      instansi: 'PT. Net Solusi Prima',
      status: StatusKehadiran.hadir,
      pembimbingIndustri: 'Bpk. Andi Firmansyah',
      periodePkl: _periode,
      persentaseKehadiran: 92,
    ),
  ];

  @override
  Future<List<SiswaBimbingan>> ambilDaftar() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.of(_data);
  }

  @override
  Future<SiswaBimbingan> ambilDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Siswa tidak ditemukan'),
    );
  }
}
