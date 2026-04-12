import 'package:flutter/material.dart';
import 'shared/main_navigation.dart';
import 'shared/providers/notification_handler.dart';

class FiyatCepApp extends StatelessWidget {
  const FiyatCepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FiyatCep',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
