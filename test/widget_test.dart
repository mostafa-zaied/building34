import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amaraty/core/utils/web_url.dart';
import 'package:amaraty/main.dart';
import 'package:amaraty/models/building_models.dart';

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

  test('BuildingInfo SaaS status, WhatsApp normalization, and share URLs', () {
    const defaultB = BuildingInfo.defaultDemo;
    expect(defaultB.isDefaultBuilding, isTrue);
    expect(defaultB.isSuspended, isFalse);
    expect(buildBuildingShareUrl(defaultB.code, isDefaultBuilding: true), 'https://mabna-care.web.app/');

    final activeTrial = BuildingInfo(
      id: 2,
      code: 'MBN-TEST',
      name: 'عمارة النخيل',
      managerWhatsapp: '01099887766',
      subscriptionStatus: 'trial',
      trialEndsAt: DateTime.now().add(const Duration(days: 10)),
    );
    expect(activeTrial.isDefaultBuilding, isFalse);
    expect(activeTrial.isSuspended, isFalse);
    expect(activeTrial.normalizedWhatsapp, '201099887766');
    expect(buildBuildingShareUrl(activeTrial.code), 'https://mabna-care.web.app/?b=MBN-TEST');

    final expiredTrial = BuildingInfo(
      id: 3,
      code: 'MBN-OLD',
      name: 'عمارة الأمل',
      subscriptionStatus: 'trial',
      trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    expect(expiredTrial.isExpired, isTrue);
    expect(expiredTrial.isSuspended, isTrue);
  });
}
