import 'package:flutter/material.dart';

import '../../../auth/domain/entities/admin_profile.dart';

/// Page d’accueil temporaire de l’espace d’administration.
///
/// Elle sera remplacée par le tableau de bord après l’authentification.
final class AdminHomePage extends StatelessWidget {
  const AdminHomePage({
    required this.profile,
    required this.onSignOut,
    super.key,
  });

  final AdminProfile profile;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NociBlacK Admin'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenue ${profile.firstName ?? profile.email}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
