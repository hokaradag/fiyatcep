import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../features/products/models/product_item.dart';
import '../../features/products/product_detail_page.dart';

/// Global navigator key — set on MaterialApp.navigatorKey (per D-01).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Call once after Firebase.initializeApp() in main().
Future<void> setupNotificationHandlers() async {
  // Request permission (needed for iOS, harmless on Android)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Cold start (D-02): app was terminated, user tapped notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Delay slightly to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(initialMessage);
    });
  }

  // Background (D-02): app was suspended, user tapped notification
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  // Foreground (D-02): app is open, show in-app SnackBar
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
}

void _handleNotificationTap(RemoteMessage message) {
  final productId = message.data['productId'] as String?;
  if (productId == null) return;

  // Per D-03: navigate using same path as pressing a product card.
  // Create a minimal ProductItem for navigation — the detail page
  // fetches full data via productMarketPricesProvider.
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => ProductDetailPage(
        product: ProductItem(
          id: productId,
          marketId: '',
          name: '',
          brand: '',
          market: '',
          price: 0,
          isDiscounted: false,
        ),
      ),
    ),
  );
}

void _handleForegroundMessage(RemoteMessage message) {
  final productId = message.data['productId'] as String?;
  final title = message.notification?.title ?? 'FiyatCep';
  final body = message.notification?.body ?? '';

  final context = navigatorKey.currentContext;
  if (context == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title: $body'),
      duration: const Duration(seconds: 5),
      action: productId != null
          ? SnackBarAction(
              label: 'Goruntule',
              onPressed: () => _handleNotificationTap(message),
            )
          : null,
    ),
  );
}
