import 'package:flutter_test/flutter_test.dart';
import 'package:dunia_anak_ceria/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DuniaAnakCeriaApp());
    expect(find.byType(DuniaAnakCeriaApp), findsOneWidget);
  });
}
