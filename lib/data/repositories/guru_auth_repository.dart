import '../models/guru_auth_session.dart';

abstract interface class GuruAuthRepository {
  Future<String?> bacaAccessToken();

  Future<GuruAuthSession?> pulihkanSesi();

  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  });

  Future<void> daftarGuru({
    required String nip,
    required String namaLengkap,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> kirimUlangVerifikasiGuru({required String email});

  Future<void> mintaResetPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String token,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  });

  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  });

  Future<void> keluar();
}

class GuruAuthException implements Exception {
  final String message;

  const GuruAuthException(this.message);

  @override
  String toString() => message;
}
