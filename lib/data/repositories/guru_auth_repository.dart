import '../models/guru_auth_session.dart';

abstract interface class GuruAuthRepository {
  Future<GuruAuthSession?> pulihkanSesi();

  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  });

  Future<void> keluar();
}

class GuruAuthException implements Exception {
  final String message;

  const GuruAuthException(this.message);

  @override
  String toString() => message;
}