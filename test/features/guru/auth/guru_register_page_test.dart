import 'package:e_pkl/data/models/guru_auth_session.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/features/guru/auth/guru_register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RegistrationRepository implements GuruAuthRepository {
  int registrationCalls = 0;
  int resendCalls = 0;
  String? registeredNip;
  String? registeredEmail;
  String? resentEmail;

  @override
  Future<String?> bacaAccessToken() async => null;

  @override
  Future<GuruAuthSession?> pulihkanSesi() async => null;

  @override
  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> daftarGuru({
    required String nip,
    required String namaLengkap,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    registrationCalls++;
    registeredNip = nip;
    registeredEmail = email;
  }

  @override
  Future<void> kirimUlangVerifikasiGuru({required String email}) async {
    resendCalls++;
    resentEmail = email;
  }

  @override
  Future<void> mintaResetPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {}

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {}

  @override
  Future<void> keluar() async {}
}

void main() {
  testWidgets('registration validates required fields before calling API', (
    tester,
  ) async {
    final repository = _RegistrationRepository();
    await tester.pumpWidget(
      MaterialApp(home: GuruRegisterPage(repository: repository)),
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('guru-register-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('guru-register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('NIP wajib diisi.'), findsOneWidget);
    expect(find.text('Nama lengkap wajib diisi.'), findsOneWidget);
    expect(repository.registrationCalls, 0);
  });

  testWidgets('registration submits and allows verification resend', (
    tester,
  ) async {
    final repository = _RegistrationRepository();
    await tester.pumpWidget(
      MaterialApp(home: GuruRegisterPage(repository: repository)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('guru-register-nip')),
      '198201012010011001',
    );
    await tester.enterText(
      find.byKey(const ValueKey('guru-register-name')),
      'Guru Uji',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'guru@example.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('guru-register-password')),
      'SecurePassword123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('guru-register-confirm-password')),
      'SecurePassword123',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('guru-register-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('guru-register-submit')));
    await tester.pumpAndSettle();

    expect(repository.registrationCalls, 1);
    expect(repository.registeredNip, '198201012010011001');
    expect(repository.registeredEmail, 'guru@example.test');
    expect(
      find.textContaining('instruksi verifikasi akan dikirim'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('guru-register-resend')),
    );
    await tester.tap(find.byKey(const ValueKey('guru-register-resend')));
    await tester.pumpAndSettle();

    expect(repository.resendCalls, 1);
    expect(repository.resentEmail, 'guru@example.test');
    expect(find.textContaining('tautan baru akan dikirim'), findsOneWidget);
  });
}
