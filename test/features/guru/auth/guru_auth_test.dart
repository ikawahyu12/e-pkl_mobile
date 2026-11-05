import 'dart:async';
import 'dart:convert';

import 'package:e_pkl/data/models/guru_auth_session.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository_api.dart';
import 'package:e_pkl/features/guru/auth/guru_login_page.dart';
import 'package:e_pkl/features/guru/auth/guru_splash_page.dart';
import 'package:e_pkl/features/guru/main/main_page.dart';
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

class _FakeAuthRepository implements GuruAuthRepository {
  Future<GuruAuthSession?> Function() onRestore = () async => null;
  Future<GuruAuthSession> Function(String identifier, String password) onLogin =
      (identifier, password) async => _guruSession;
  Future<void> Function() onLogout = () async {};
  int loginCalls = 0;

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
              'user': {'id': 8, 'role': 'guru'},
            },
          });
        });
        final repository = GuruAuthRepositoryApi(client: client);

        final session = await repository.masuk(
          identifier: 'guru@example.test',
          password: 'secret',
        );

        expect(session.isValidGuruSession, isTrue);
        expect(
          await const FlutterSecureStorage().read(key: 'guru_access_token'),
          'issued-token',
        );
        client.close();
      },
    );

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
              'user': {'id': 8, 'role': 'guru'},
            },
          });
        });
        final repository = GuruAuthRepositoryApi(client: client);

        final session = await repository.pulihkanSesi();

        expect(session?.isValidGuruSession, isTrue);
        expect(session?.user['id'], 8);
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

      expect(find.text('Email atau username wajib diisi'), findsOneWidget);
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
}
