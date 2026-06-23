import 'package:flutter/material.dart';

/// Point d'entrée du formulaire de création d'un article.
///
/// Le formulaire métier sera construit après validation de la liste.
final class ItemFormPage extends StatelessWidget {
  const ItemFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel article')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Le formulaire de création sera développé après la liste des articles.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
