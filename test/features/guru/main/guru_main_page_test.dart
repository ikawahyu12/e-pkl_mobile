import 'package:e_pkl/data/repositories/guru_auth_repository.dart';
import 'package:e_pkl/features/guru/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepositoryStub implements GuruAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('header logo, notifikasi, dan profil tetap ada saat ganti tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GuruMainPage(repository: _AuthRepositoryStub())),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Logo E-PKL'), findsOneWidget);
    expect(find.byTooltip('Notifikasi'), findsOneWidget);
    expect(find.byTooltip('Profil'), findsOneWidget);

    await tester.tap(find.text('Siswa'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Logo E-PKL'), findsOneWidget);
    expect(find.byTooltip('Notifikasi'), findsOneWidget);
    expect(find.byTooltip('Profil'), findsOneWidget);

    await tester.tap(find.text('Monitoring'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Logo E-PKL'), findsOneWidget);
    expect(find.byTooltip('Notifikasi'), findsOneWidget);
    expect(find.byTooltip('Profil'), findsOneWidget);
  });
}
