import 'dart:async';
import 'dart:convert';

import 'package:e_pkl/data/models/guru_auth_session.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository_api.dart';
import 'package:e_pkl/features/guru/auth/guru_forgot_password_page.dart';
import 'package:e_pkl/features/guru/auth/guru_login_page.dart';
import 'package:e_pkl/features/guru/auth/guru_reset_password_page.dart';
import 'package:e_pkl/features/guru/auth/guru_splash_page.dart';
import 'package:e_pkl/features/guru/main/main_page.dart';
import 'package:e_pkl/features/guru/profil/ganti_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _guruSession = GuruAuthSession(
  accessToken: 'guru-token',
  role: 'guru',
  user: {'id': 8, 'role': 'guru'},
);

const _guruPasswordChangeSession = GuruAuthSession(
  accessToken: 'temporary-token',
  role: 'guru',
  user: {'id': 8, 'role': 'guru', 'wajib_ganti_password': true},
);

class _FakeAuthRepository implements GuruAuthRepository {
  Future<GuruAuthSession?> Function() onRestore = () async => null;
  Future<GuruAuthSession> Function(String identifier, String password) onLogin =
      (identifier, password) async => _guruSession;
  Future<void> Function(
    String nip,
    String namaLengkap,
    String email,
    String password,
    String passwordConfirmation,
  )
  onRegister = (nip, nama, email, password, confirmation) async {};
  Future<void> Function(String email) onResendVerification = (email) async {};
  Future<void> Function(String email) onForgotPassword = (email) async {};
  Future<void> Function(
    String email,
    String token,
    String password,
    String confirmation,
  )
  onResetPassword = (email, token, password, confirmation) async {};
  Future<void> Function() onLogout = () async {};
  int loginCalls = 0;

  @override
  Future<String?> bacaAccessToken() async => null;

  @override
  Future<GuruAuthSession?> pulihkanSesi() => onRestore();

  @override
  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  }) {
    loginCalls++;
    return onLogin(identifier, password);
  }

  @override
  Future<void> daftarGuru({
    required String nip,
    required String namaLengkap,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => onRegister(nip, namaLengkap, email, password, passwordConfirmation);

  @override
  Future<void> kirimUlangVerifikasiGuru({required String email}) =>
      onResendVerification(email);

  @override
  Future<void> mintaResetPassword({required String email}) =>
      onForgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) => onResetPassword(email, token, passwordBaru, passwordBaruConfirmation);

  @override
  Future<void> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {}

  @override
  Future<void> keluar() => onLogout();
}

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('GuruAuthRepositoryApi', () {
    test(
      'login sends backend contract and persists only valid Guru token',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/guru/auth/login');
          expect(request.headers['accept'], 'application/json');
          expect(jsonDecode(request.body), {
            'login': 'guru@example.test',
            'password': 'secret',
          });
          return _jsonResponse({
            'success': true,
            'data': {
              'token': 'issued-token',
              'token_type': 'Bearer',
              'user': {'id': 8, 'role': 'guru', 'wajib_ganti_password': true},
            },
          });
        });
        final repository = GuruAuthRepositoryApi(client: client);

        final session = await repository.masuk(
          identifier: 'guru@example.test',
          password: 'secret',
        );

        expect(session.isValidGuruSession, isTrue);
        expect(session.wajibGantiPassword, isTrue);
        expect(
          await const FlutterSecureStorage().read(key: 'guru_access_token'),
          'issued-token',
        );
        client.close();
      },
    );

    test('login sends a NIP identifier using the login field', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v1/guru/auth/login');
        expect(jsonDecode(request.body), {
          'login': '198201012010011001',
          'password': 'secret',
        });
        return _jsonResponse({
          'success': true,
          'data': {
            'token': 'issued-token',
            'user': {'id': 8, 'role': 'guru'},
          },
        });
      });
      final repository = GuruAuthRepositoryApi(client: client);

      final session = await repository.masuk(
        identifier: '198201012010011001',
        password: 'secret',
      );

      expect(session.isValidGuruSession, isTrue);
      client.close();
    });

    test(
      'login rejects a non-Guru response and does not store its token',
      () async {
        final client = MockClient(
          (_) async => _jsonResponse({
            'success': true,
            'data': {
              'token': 'student-token',
              'user': {'role': 'siswa'},
            },
          }),
        );
        final repository = GuruAuthRepositoryApi(client: client);

        await expectLater(
          repository.masuk(identifier: 'siswa', password: 'secret'),
          throwsA(isA<GuruAuthException>()),
        );
        expect(
          await const FlutterSecureStorage().read(key: 'guru_access_token'),
          isNull,
        );
        client.close();
      },
    );

    test('login shows the API authentication error', () async {
      final client = MockClient(
        (_) async => _jsonResponse({
          'success': false,
          'message': 'Login atau password tidak valid.',
        }, statusCode: 401),
      );
      final repository = GuruAuthRepositoryApi(client: client);

      await expectLater(
        repository.masuk(identifier: 'unknown', password: 'wrong'),
        throwsA(
          isA<GuruAuthException>().having(
            (error) => error.message,
            'message',
            'Login atau password tidak valid.',
          ),
        ),
      );
      client.close();
    });

    test('Guru registration sends the API contract', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/register');
        expect(request.headers['accept'], 'application/json');
        expect(jsonDecode(request.body), {
          'nip': '198201012010011001',
          'nama_lengkap': 'Guru Uji',
          'email': 'guru@example.test',
          'password': 'SecurePassword123',
          'password_confirmation': 'SecurePassword123',
        });
        return _jsonResponse({
          'success': true,
          'message': 'Instruksi verifikasi akan dikirim.',
          'data': null,
        }, statusCode: 202);
      });
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.daftarGuru(
        nip: ' 198201012010011001 ',
        namaLengkap: ' Guru Uji ',
        email: ' guru@example.test ',
        password: 'SecurePassword123',
        passwordConfirmation: 'SecurePassword123',
      );
      client.close();
    });

    test('Guru registration accepts any successful 2xx response', () async {
      final client = MockClient(
        (_) async => _jsonResponse({
          'success': true,
          'message': 'Instruksi verifikasi akan dikirim.',
          'data': null,
        }, statusCode: 201),
      );
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.daftarGuru(
        nip: '198201012010011001',
        namaLengkap: 'Guru Uji',
        email: 'guru@example.test',
        password: 'SecurePassword123',
        passwordConfirmation: 'SecurePassword123',
      );
      client.close();
    });

    test('Guru registration can resend a verification email', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/resend-verification');
        expect(jsonDecode(request.body), {'email': 'guru@example.test'});
        return _jsonResponse({
          'success': true,
          'message': 'Jika akun menunggu verifikasi, tautan baru akan dikirim.',
          'data': null,
        }, statusCode: 202);
      });
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.kirimUlangVerifikasiGuru(email: ' guru@example.test ');
      client.close();
    });

    test('verification resend accepts any successful 2xx response', () async {
      final client = MockClient(
        (_) async => _jsonResponse({
          'success': true,
          'message': 'Jika akun menunggu verifikasi, tautan baru akan dikirim.',
          'data': null,
        }, statusCode: 200),
      );
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.kirimUlangVerifikasiGuru(email: 'guru@example.test');
      client.close();
    });

    test('forgot password sends the Guru email request', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/forgot-password');
        expect(jsonDecode(request.body), {'email': 'guru@example.test'});
        return _jsonResponse({
          'success': true,
          'message': 'Jika alamat email terdaftar, instruksi reset dikirim.',
          'data': null,
        }, statusCode: 202);
      });
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.mintaResetPassword(email: 'guru@example.test');
      client.close();
    });

    test('reset password sends token and matching password fields', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/reset-password');
        expect(jsonDecode(request.body), {
          'email': 'guru@example.test',
          'token': 'a' * 64,
          'password_baru': 'Baru12345',
          'password_baru_confirmation': 'Baru12345',
        });
        return _jsonResponse({
          'success': true,
          'message': 'Kata sandi berhasil diubah.',
          'data': null,
        });
      });
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.resetPassword(
        email: 'guru@example.test',
        token: 'a' * 64,
        passwordBaru: 'Baru12345',
        passwordBaruConfirmation: 'Baru12345',
      );
      client.close();
    });

    test(
      'session restoration sends Bearer token and accepts API-verified Guru',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'guru_access_token': 'stored-token',
        });
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/guru/auth/me');
          expect(request.headers['authorization'], 'Bearer stored-token');
          return _jsonResponse({
            'success': true,
            'data': {
              'user': {'id': 8, 'role': 'guru', 'wajib_ganti_password': true},
            },
          });
        });
        final repository = GuruAuthRepositoryApi(client: client);

        final session = await repository.pulihkanSesi();

        expect(session?.isValidGuruSession, isTrue);
        expect(session?.user['id'], 8);
        expect(session?.wajibGantiPassword, isTrue);
        client.close();
      },
    );

    test('expired token is deleted and never restores a session', () async {
      FlutterSecureStorage.setMockInitialValues({
        'guru_access_token': 'expired-token',
      });
      final client = MockClient(
        (_) async => _jsonResponse({
          'success': false,
          'message': 'Autentikasi diperlukan.',
        }, statusCode: 401),
      );
      final repository = GuruAuthRepositoryApi(client: client);

      expect(await repository.pulihkanSesi(), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'guru_access_token'),
        isNull,
      );
      client.close();
    });

    test(
      'connection failure does not treat an unverified session as valid',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'guru_access_token': 'stored-token',
        });
        final client = MockClient(
          (_) async => throw http.ClientException('offline'),
        );
        final repository = GuruAuthRepositoryApi(client: client);

        await expectLater(
          repository.pulihkanSesi(),
          throwsA(isA<GuruAuthException>()),
        );
        expect(
          await const FlutterSecureStorage().read(key: 'guru_access_token'),
          'stored-token',
        );
        client.close();
      },
    );

    test('change password sends Bearer token and correct payload', () async {
      FlutterSecureStorage.setMockInitialValues({
        'guru_access_token': 'stored-token',
      });

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/password');
        expect(request.headers['authorization'], 'Bearer stored-token');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'password_lama': 'PasswordLama123',
          'password_baru': 'PasswordBaru123',
          'password_baru_confirmation': 'PasswordBaru123',
        });

        return _jsonResponse({
          'success': true,
          'message': 'Kata sandi berhasil diubah.',
        });
      });

      final repository = GuruAuthRepositoryApi(client: client);

      await expectLater(
        repository.gantiPassword(
          passwordLama: 'PasswordLama123',
          passwordBaru: 'PasswordBaru123',
          passwordBaruConfirmation: 'PasswordBaru123',
        ),
        completes,
      );

      expect(
        await const FlutterSecureStorage().read(key: 'guru_access_token'),
        'stored-token',
      );

      client.close();
    });

    test('change password rejects missing token without calling API', () async {
      var requestCalled = false;

      final client = MockClient((request) async {
        requestCalled = true;
        return _jsonResponse({'success': true});
      });

      final repository = GuruAuthRepositoryApi(client: client);

      await expectLater(
        repository.gantiPassword(
          passwordLama: 'PasswordLama123',
          passwordBaru: 'PasswordBaru123',
          passwordBaruConfirmation: 'PasswordBaru123',
        ),
        throwsA(
          isA<GuruAuthException>().having(
            (error) => error.message,
            'message',
            'Sesi Guru tidak ditemukan. Silakan login kembali.',
          ),
        ),
      );

      expect(requestCalled, isFalse);

      client.close();
    });

    test('change password displays backend validation error', () async {
      FlutterSecureStorage.setMockInitialValues({
        'guru_access_token': 'stored-token',
      });

      final client = MockClient(
        (_) async => _jsonResponse({
          'success': false,
          'message': 'Password lama tidak sesuai.',
        }, statusCode: 422),
      );

      final repository = GuruAuthRepositoryApi(client: client);

      await expectLater(
        repository.gantiPassword(
          passwordLama: 'PasswordSalah123',
          passwordBaru: 'PasswordBaru123',
          passwordBaruConfirmation: 'PasswordBaru123',
        ),
        throwsA(
          isA<GuruAuthException>().having(
            (error) => error.message,
            'message',
            'Password lama tidak sesuai.',
          ),
        ),
      );

      expect(
        await const FlutterSecureStorage().read(key: 'guru_access_token'),
        'stored-token',
      );

      client.close();
    });
    test('logout sends token and removes local session', () async {
      FlutterSecureStorage.setMockInitialValues({
        'guru_access_token': 'stored-token',
      });
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/guru/auth/logout');
        expect(request.headers['authorization'], 'Bearer stored-token');
        return _jsonResponse({'success': true, 'data': null});
      });
      final repository = GuruAuthRepositoryApi(client: client);

      await repository.keluar();

      expect(
        await const FlutterSecureStorage().read(key: 'guru_access_token'),
        isNull,
      );
      client.close();
    });

    test(
      'logout removes local session even when server does not confirm it',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'guru_access_token': 'stored-token',
        });
        final client = MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': 'Server unavailable.',
          }, statusCode: 503),
        );
        final repository = GuruAuthRepositoryApi(client: client);

        await expectLater(
          repository.keluar(),
          throwsA(isA<GuruAuthException>()),
        );
        expect(
          await const FlutterSecureStorage().read(key: 'guru_access_token'),
          isNull,
        );
        client.close();
      },
    );
  });

  group('Guru splash and login', () {
    testWidgets('login opens Guru registration page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: _FakeAuthRepository())),
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('guru-register-link')),
      );
      await tester.tap(find.byKey(const ValueKey('guru-register-link')));
      await tester.pumpAndSettle();

      expect(find.text('Registrasi Guru'), findsOneWidget);
      expect(find.byKey(const ValueKey('guru-register-nip')), findsOneWidget);
    });

    testWidgets('valid session from API opens Guru dashboard', (tester) async {
      final repository = _FakeAuthRepository()
        ..onRestore = () async => _guruSession;

      await tester.pumpWidget(
        MaterialApp(home: GuruSplashPage(repository: repository)),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(GuruMainPage), findsOneWidget);
      expect(find.text('Halo,\nGuru Pembimbing'), findsOneWidget);
    });

    testWidgets('restored session requiring password change is gated', (
      tester,
    ) async {
      final repository = _FakeAuthRepository()
        ..onRestore = () async => _guruPasswordChangeSession;

      await tester.pumpWidget(
        MaterialApp(home: GuruSplashPage(repository: repository)),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(GantiPasswordPage), findsOneWidget);
      expect(find.byType(GuruMainPage), findsNothing);
      expect(find.text('Wajib Ganti Kata Sandi'), findsOneWidget);
    });

    testWidgets('invalid or unavailable session opens Guru login', (
      tester,
    ) async {
      final repository = _FakeAuthRepository()
        ..onRestore = () async => const GuruAuthSession(
          accessToken: 'invalid-token',
          role: 'siswa',
          user: {'role': 'siswa'},
        );

      await tester.pumpWidget(
        MaterialApp(home: GuruSplashPage(repository: repository)),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(GuruLoginPage), findsOneWidget);
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.byType(GuruMainPage), findsNothing);
    });

    testWidgets('empty login input is validated without calling repository', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: repository)),
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('guru-login-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('guru-login-submit')));
      await tester.pump();

      expect(
        find.text('NIP, email, atau username wajib diisi'),
        findsOneWidget,
      );
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(repository.loginCalls, 0);
    });

    testWidgets('password visibility toggle changes obscured state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: _FakeAuthRepository())),
      );

      final passwordInput = find.descendant(
        of: find.byKey(const ValueKey('guru-password')),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);

      await tester.tap(
        find.byKey(const ValueKey('toggle-password-visibility')),
      );
      await tester.pump();

      expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);
    });

    testWidgets('API login failure is displayed and does not open dashboard', (
      tester,
    ) async {
      final repository = _FakeAuthRepository()
        ..onLogin = (identifier, password) async {
          throw const GuruAuthException('Login atau password tidak valid.');
        };
      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: repository)),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-identifier')),
        'guru@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-password')),
        'wrong',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('guru-login-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('guru-login-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Login atau password tidak valid.'), findsOneWidget);
      expect(find.byType(GuruMainPage), findsNothing);
    });

    testWidgets('login requiring password change does not open dashboard', (
      tester,
    ) async {
      final repository = _FakeAuthRepository()
        ..onLogin = (identifier, password) async => _guruPasswordChangeSession;

      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: repository)),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-identifier')),
        'guru@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-password')),
        'temporary-password',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('guru-login-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('guru-login-submit')));
      await tester.pumpAndSettle();

      expect(find.byType(GantiPasswordPage), findsOneWidget);
      expect(find.byType(GuruMainPage), findsNothing);
    });

    testWidgets('successful login remains loading until API responds', (
      tester,
    ) async {
      final completer = Completer<GuruAuthSession>();
      final repository = _FakeAuthRepository()
        ..onLogin = (identifier, password) => completer.future;
      await tester.pumpWidget(
        MaterialApp(home: GuruLoginPage(repository: repository)),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-identifier')),
        'guru@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-password')),
        'secret',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('guru-login-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('guru-login-submit')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(repository.loginCalls, 1);
      completer.complete(_guruSession);
      await tester.pumpAndSettle();

      expect(find.byType(GuruMainPage), findsOneWidget);
    });
  });

  group('Guru password reset pages', () {
    testWidgets('forgot password shows generic confirmation', (tester) async {
      var requestedEmail = '';
      final repository = _FakeAuthRepository()
        ..onForgotPassword = (email) async => requestedEmail = email;

      await tester.pumpWidget(
        MaterialApp(home: GuruForgotPasswordPage(repository: repository)),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-reset-email')),
        'guru@example.test',
      );
      await tester.tap(find.byKey(const ValueKey('guru-reset-request-submit')));
      await tester.pumpAndSettle();

      expect(requestedEmail, 'guru@example.test');
      expect(
        find.text(
          'Jika alamat email terdaftar, instruksi reset kata sandi akan dikirim.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('reset password validates confirmation and submits token', (
      tester,
    ) async {
      var resetCalled = false;
      final repository = _FakeAuthRepository()
        ..onResetPassword = (email, token, password, confirmation) async {
          expect(email, 'guru@example.test');
          expect(token, 'a' * 64);
          expect(password, 'Password123');
          expect(confirmation, 'Password123');
          resetCalled = true;
        };

      await tester.pumpWidget(
        MaterialApp(
          home: GuruResetPasswordPage(
            repository: repository,
            email: 'guru@example.test',
            token: 'a' * 64,
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-reset-new-password')),
        'Password123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-reset-confirm-password')),
        'Password123',
      );
      await tester.tap(
        find.byKey(const ValueKey('guru-reset-password-submit')),
      );
      await tester.pumpAndSettle();

      expect(resetCalled, isTrue);
      expect(
        find.text(
          'Password berhasil diubah. Silakan masuk menggunakan password baru.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('reset password rejects mismatched confirmation', (
      tester,
    ) async {
      var resetCalled = false;
      final repository = _FakeAuthRepository()
        ..onResetPassword = (email, token, password, confirmation) async {
          resetCalled = true;
        };

      await tester.pumpWidget(
        MaterialApp(
          home: GuruResetPasswordPage(
            repository: repository,
            email: 'guru@example.test',
            token: 'a' * 64,
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-reset-new-password')),
        'Password123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('guru-reset-confirm-password')),
        'WrongPassword123',
      );
      await tester.tap(
        find.byKey(const ValueKey('guru-reset-password-submit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi password tidak cocok.'), findsOneWidget);
      expect(resetCalled, isFalse);
    });
  });
}
