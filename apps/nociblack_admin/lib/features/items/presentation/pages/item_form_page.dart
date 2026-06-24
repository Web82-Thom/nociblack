import 'package:flutter/material.dart';

import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/presentation/controllers/active_categories_controller.dart';

/// Première étape du formulaire Article : sélection d'une catégorie active.
final class ItemFormPage extends StatefulWidget {
  const ItemFormPage({required this.categoryRepository, super.key});

  final CategoryRepository categoryRepository;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

final class _ItemFormPageState extends State<ItemFormPage> {
  late final ActiveCategoriesController _controller;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _controller = ActiveCategoriesController(widget.categoryRepository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel article')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return switch (_controller.status) {
            ActiveCategoriesStatus.initial || ActiveCategoriesStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ActiveCategoriesStatus.failure => _CategoriesFailureView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
            ),
            ActiveCategoriesStatus.success
                when _controller.categories.isEmpty =>
              const _NoActiveCategoryView(),
            ActiveCategoriesStatus.success => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Informations générales',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Commencez par choisir la catégorie de l’article.',
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    key: const Key('item_category_field'),
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _controller.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(growable: false),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}

final class _CategoriesFailureView extends StatelessWidget {
  const _CategoriesFailureView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _NoActiveCategoryView extends StatelessWidget {
  const _NoActiveCategoryView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune catégorie active. Une catégorie est nécessaire avant de '
          'créer un article.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
