import 'package:flutter/material.dart';
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
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}
