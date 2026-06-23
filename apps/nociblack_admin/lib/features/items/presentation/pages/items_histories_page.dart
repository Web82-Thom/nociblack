import 'package:flutter/material.dart';

/// Point d'entrée de la consultation et de l'édition des articles.
///
/// La lecture Supabase sera ajoutée lors de la prochaine étape fonctionnelle.
final class ItemsHistoriesPage extends StatelessWidget {
  const ItemsHistoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Retrouver l'historique des produits entrer dans l'ordre du plus recent au plus ancien",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
