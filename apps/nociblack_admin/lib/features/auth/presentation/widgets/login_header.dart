import 'package:flutter/material.dart';

/// Identité visuelle placée au-dessus du formulaire de connexion.
final class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Image.asset(
          'assets/images/logos/NociBlacK_logo_premium.png',
          width: 180,
          semanticLabel: 'Logo NociBlacK',
        ),
        const SizedBox(height: 24),
        Text(
          'Administration',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous avec votre compte administrateur.',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
