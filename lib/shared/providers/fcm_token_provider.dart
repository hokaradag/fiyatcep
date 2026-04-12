import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // TODO: Plan 03 will add re-sync with backend here
  });
}
