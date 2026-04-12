import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'shared/providers/fcm_token_provider.dart';
import 'shared/providers/notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupNotificationHandlers();
  listenForTokenRefresh();
  runApp(const ProviderScope(child: FiyatCepApp()));
}
