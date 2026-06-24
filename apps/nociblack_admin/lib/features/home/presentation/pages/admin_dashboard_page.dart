import 'package:flutter/material.dart';

import '../../../auth/domain/entities/admin_profile.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../items/domain/repositories/item_repository.dart';
import '../../../items/presentation/pages/item_form_page.dart';
import '../../../items/presentation/pages/items_history_page.dart';
import '../../../items/presentation/pages/items_list_page.dart';
import '../widgets/dashboard_action_card.dart';

/// Tableau de bord principal de l'espace d'administration.
final class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    required this.profile,
    required this.onSignOut,
    required this.categoryRepository,
    required this.itemRepository,
    super.key,
  });

  final AdminProfile profile;
  final Future<void> Function() onSignOut;
  final CategoryRepository categoryRepository;
  final ItemRepository itemRepository;

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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _DashboardHeader(profile: profile),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 180,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate.fixed([
                DashboardActionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Articles',
                  description:
                      'Consulter et modifier les articles du catalogue.',
                  onTap: () => _openItems(context),
                ),
                DashboardActionCard(
                  icon: Icons.history,
                  title: 'Historique',
                  description: 'Historique des articles ajoutés',
                  onTap: () => _openItemsHistory(context),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create_item_fab'),
        tooltip: 'Ajouter un article',
        onPressed: () => _openCreateItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel article'),
      ),
    );
  }

  void _openItems(BuildContext context) {
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemsListPage(repository: itemRepository),
      ),
    );
  }

  void _openCreateItem(BuildContext context) {
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemFormPage(
          categoryRepository: categoryRepository,
        ),
      ),
    );
  }

  void _openItemsHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemsHistoryPage(repository: itemRepository),
      ),
    );
  }
}

final class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.profile});

  final AdminProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = profile.firstName ?? profile.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bienvenue $displayName', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Gérez le catalogue NociBlacK depuis votre tableau de bord.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
