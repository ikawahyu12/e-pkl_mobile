import 'package:flutter_test/flutter_test.dart';

import 'package:e_pkl/main.dart';

void main() {
  testWidgets('starts on the guru home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Halo,\nGuru Pembimbing'), findsOneWidget);
  });
}
