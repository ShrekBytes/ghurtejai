import 'package:flutter_test/flutter_test.dart';
import 'package:ghurtejai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GhurtejaiApp());
    expect(find.text('GhurteJai'), findsNothing);
  });
}
