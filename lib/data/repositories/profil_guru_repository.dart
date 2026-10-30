import '../models/profil_guru_model.dart';

/// Kontrak data akun guru. Page hanya bergantung pada kelas ini,
/// jadi tinggal ganti implementasi saat API sudah siap.
abstract class ProfilGuruRepository {
  Future<ProfilGuru> ambilProfil();

  Future<ProfilGuru> ubahProfil({
    required String nama,
    String? email,
    String? noHp,
  });

  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  });

  Future<void> logout();
}

/// Data dummy supaya UI bisa jalan sebelum API tersedia.
/// TODO: buat ProfilGuruRepositoryApi (http/dio) dengan endpoint backend,
/// lalu ganti default di ProfilGuruPage.
class ProfilGuruRepositoryMock implements ProfilGuruRepository {
  ProfilGuru _data = const ProfilGuru(
    nama: 'Andini Rahmawati, S.Pd.',
    nip: '19870918 201503 2 004',
    sekolah: 'SMK Negeri 1 Cendekia',
    bimbingan: '12 siswa • XI RPL 1–2',
    email: 'andini@smkn1cendekia.sch.id',
    noHp: '081234567890',
  );

  String _password = 'password123';

  @override
  Future<ProfilGuru> ambilProfil() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _data;
  }

  @override
  Future<ProfilGuru> ubahProfil({
    required String nama,
    String? email,
    String? noHp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _data = _data.copyWith(nama: nama, email: email, noHp: noHp);
    return _data;
  }

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (passwordLama != _password) {
      throw Exception('Kata sandi lama tidak sesuai');
    }
    _password = passwordBaru;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: hapus token dari secure storage.
  }
}