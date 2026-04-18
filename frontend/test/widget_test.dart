import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghurtejai/main.dart';

void main() {
  testWidgets('App loads with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GhurtejaiApp(),
      ),
    );
    // Shimmer and other animations prevent pumpAndSettle from completing.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Ghurtejai'), findsWidgets);
  });
}
