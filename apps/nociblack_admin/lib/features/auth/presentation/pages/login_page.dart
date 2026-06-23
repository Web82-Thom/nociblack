import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

/// Écran de connexion de l'espace d'administration.
final class LoginPage extends StatelessWidget {
  const LoginPage({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  LoginForm(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
