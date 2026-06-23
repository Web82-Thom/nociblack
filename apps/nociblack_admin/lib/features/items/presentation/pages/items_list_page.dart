import 'package:flutter/material.dart';

/// Point d'entrée de la consultation et de l'édition des articles.
///
/// La lecture Supabase sera ajoutée lors de la prochaine étape fonctionnelle.
final class ItemsListPage extends StatelessWidget {
  const ItemsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'La liste des articles sera connectée à Supabase à la prochaine étape.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
