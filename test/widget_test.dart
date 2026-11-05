import 'package:flutter_test/flutter_test.dart';

import 'package:e_pkl/data/models/guru_auth_session.dart';
import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/main.dart';

class _AuthRepositoryFake implements GuruAuthRepository {
  @override
  Future<GuruAuthSession?> pulihkanSesi() async => null;

  @override
  Future<GuruAuthSession> masuk({
    required String identifier,
    required String password,
  }) async {
    throw const GuruAuthException('Tidak dipakai pada test splash.');
  }

  @override
  Future<void> keluar() async {}
}

void main() {
  testWidgets('starts with splash and shows Guru login without a session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: _AuthRepositoryFake()));
    expect(find.text('E-PKL'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Silakan masuk dengan akun Guru.'), findsOneWidget);
  });
}
