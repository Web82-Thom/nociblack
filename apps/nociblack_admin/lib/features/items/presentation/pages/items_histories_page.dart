import 'package:flutter/material.dart';

/// Point d'entrée de la consultation et de l'édition des articles.
///
/// La lecture Supabase sera ajoutée lors de la prochaine étape fonctionnelle.
final class ItemsHistoryPage extends StatelessWidget {
  const ItemsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Retrouver l'historique des produits dans l'ordre du plus récent au plus ancien",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
