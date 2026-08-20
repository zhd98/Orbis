import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

/// Ignis ("fire" in Latin) — a minimal WYSIWYG Markdown editor for Windows 11.
class IgnisApp extends StatelessWidget {
  const IgnisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ignis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE25822), // warm ember orange
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}
