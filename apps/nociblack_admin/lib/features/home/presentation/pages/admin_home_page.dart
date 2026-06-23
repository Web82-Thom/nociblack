import 'package:flutter/material.dart';

/// Page d’accueil temporaire de l’espace d’administration.
///
/// Elle sera remplacée par le tableau de bord après l’authentification.
final class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NociBlacK Admin')),
      body: const Center(child: Text('NociBlacK Admin')),
    );
  }
}
