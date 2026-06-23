import 'package:flutter/material.dart';

import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import 'theme/app_theme.dart';

/// Widget racine de l’application NociBlacK Admin.
final class NociBlackAdminApp extends StatelessWidget {
  const NociBlackAdminApp({required this.authRepository, super.key});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NociBlacK Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(authRepository: authRepository),
    );
  }
}
