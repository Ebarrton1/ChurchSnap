import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';

class ChurchSnapApp extends StatelessWidget {
  const ChurchSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChurchSnap',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
