import 'package:flutter/material.dart';

import '../features/home/presentation/pages/admin_home_page.dart';
import 'theme/app_theme.dart';

/// Widget racine de l’application NociBlacK Admin.
final class NociBlackAdminApp extends StatelessWidget {
  const NociBlackAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NociBlacK Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AdminHomePage(),
    );
  }
}
