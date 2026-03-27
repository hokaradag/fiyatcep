import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/app.dart';

void main() {
  testWidgets('FiyatCep app renders bottom navigation items', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: FiyatCepApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsAtLeastNWidgets(1));
    expect(find.text('Ürünler'), findsAtLeastNWidgets(1));
    expect(find.text('Marketler'), findsAtLeastNWidgets(1));
    expect(find.text('İndirimler'), findsAtLeastNWidgets(1));
    expect(find.text('Favoriler'), findsAtLeastNWidgets(1));
  });
}
