import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amaraty/main.dart';

void main() {
  testWidgets('AmaratyApp renders Month 11 bill and 13 apartments', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AmaratyApp());
    await tester.pumpAndSettle();

    expect(find.text('مصاريف العمارة لشهر 11:'), findsOneWidget);
    expect(find.text('287 ج'), findsWidgets);
    expect(find.text('أستاذ حازم'), findsOneWidget);
    expect(find.text('أستاذ معتز'), findsOneWidget);
  });
}
