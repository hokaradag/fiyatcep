import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client_provider.dart' show apiBaseUrl;

const String _fcmTokenKey = 'fcm_token';

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }
  return token;
});

/// Call once in main() to listen for token refreshes.
void listenForTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, newToken);

    // Re-sync watch list with new token
    final productIds = prefs.getStringList('watched_product_ids') ?? [];
    final discountIds = prefs.getStringList('watched_discount_ids') ?? [];
    if (productIds.isEmpty && discountIds.isEmpty) return;

    try {
      // Direct Dio call since we're outside Riverpod context.
      // Uses apiBaseUrl constant from api_client_provider.dart to avoid
      // duplicating the base URL (CLAUDE.md: shared infrastructure in lib/shared/).
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      await dio.post('/notifications/subscribe', data: {
        'fcmToken': newToken,
        'productIds': productIds,
        'discountIds': discountIds,
      });
    } catch (_) {
      // Best-effort -- next watch toggle will retry
    }
  });
}
