import 'package:flutter/material.dart';

import '../../domain/repositories/category_repository.dart';
import '../controllers/categories_list_controller.dart';
import '../widgets/catalog_category_card.dart';
import 'category_form_page.dart';

final class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({required this.repository, super.key});

  final CategoryRepository repository;

  @override
  State<CategoriesListPage> createState() => _CategoriesListPageState();
}

final class _CategoriesListPageState extends State<CategoriesListPage> {
  late final CategoriesListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoriesListController(widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCreationForm() async {
    final isCreated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryFormPage(repository: widget.repository),
      ),
    );

    if (isCreated == true) await _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return switch (_controller.status) {
            CategoriesListStatus.initial || CategoriesListStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            CategoriesListStatus.failure => _CategoriesFailureView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
            ),
            CategoriesListStatus.success when _controller.categories.isEmpty =>
              const _CategoriesEmptyView(),
            CategoriesListStatus.success => RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _controller.categories.length,
                itemBuilder: (context, index) {
                  return CatalogCategoryCard(
                    category: _controller.categories[index],
                  );
                },
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create_category_fab'),
        onPressed: _openCreationForm,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
      ),
    );
  }
}

final class _CategoriesFailureView extends StatelessWidget {
  const _CategoriesFailureView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

final class _CategoriesEmptyView extends StatelessWidget {
  const _CategoriesEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune catégorie. Utilisez le bouton + pour créer la première.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
