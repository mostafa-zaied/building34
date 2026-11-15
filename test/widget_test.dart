import 'package:flutter_test/flutter_test.dart';
import 'package:amaraty/main.dart';

void main() {
  testWidgets('AmaratyApp renders Month 11 bill and 13 apartments', (WidgetTester tester) async {
    await tester.pumpWidget(const AmaratyApp());
    await tester.pumpAndSettle();

    expect(find.text('مصاريف العمارة لشهر 11:'), findsOneWidget);
    expect(find.text('300 ج'), findsOneWidget);
    expect(find.text('شقة 1'), findsOneWidget);
    expect(find.text('شقة 13'), findsOneWidget);
  });
}
