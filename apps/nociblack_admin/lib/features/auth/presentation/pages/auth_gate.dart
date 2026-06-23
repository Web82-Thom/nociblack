import 'package:flutter/material.dart';

import '../../../home/presentation/pages/admin_dashboard_page.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

/// Sélectionne l'écran à partir de la session réellement validée.
final class AuthGate extends StatefulWidget {
  const AuthGate({required this.authRepository, super.key});

  final AuthRepository authRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

final class _AuthGateState extends State<AuthGate> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(widget.authRepository);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return switch (_controller.status) {
          AuthenticationStatus.checking => const _AuthenticationLoadingView(),
          AuthenticationStatus.unauthenticated => LoginPage(
            controller: _controller,
          ),
          AuthenticationStatus.authenticated => AdminDashboardPage(
            profile: _controller.profile!,
            onSignOut: _controller.signOut,
          ),
        };
      },
    );
  }
}

final class _AuthenticationLoadingView extends StatelessWidget {
  const _AuthenticationLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
