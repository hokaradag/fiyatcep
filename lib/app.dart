import 'package:flutter/material.dart';
import 'shared/main_navigation.dart';

class FiyatCepApp extends StatelessWidget {
  const FiyatCepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
