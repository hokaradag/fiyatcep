import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/app.dart';

void main() {
  testWidgets('FiyatCep app renders bottom navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FiyatCepApp());

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Ürünler'), findsOneWidget);
    expect(find.text('Marketler'), findsOneWidget);
    expect(find.text('İndirimler'), findsOneWidget);
    expect(find.text('Favoriler'), findsOneWidget);
  });
}
