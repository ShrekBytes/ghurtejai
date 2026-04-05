import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'login_page.dart';

void main() {
  runApp(const GhurteJaiApp());
}

class GhurteJaiApp extends StatelessWidget {
  const GhurteJaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhurteJai',
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme(),
      home: const LoginPage(),
    );
  }
}
