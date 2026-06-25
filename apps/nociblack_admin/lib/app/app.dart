import 'package:flutter/material.dart';

import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/items/domain/repositories/item_image_repository.dart';
import '../features/items/domain/repositories/item_repository.dart';
import '../features/items/domain/services/item_image_creation_service.dart';
import '../features/items/domain/services/item_image_display_service.dart';
import '../features/items/domain/services/item_image_update_service.dart';
import 'theme/app_theme.dart';

/// Widget racine de l’application NociBlacK Admin.
final class NociBlackAdminApp extends StatelessWidget {
  const NociBlackAdminApp({
    required this.authRepository,
    required this.categoryRepository,
    required this.itemRepository,
    required this.itemImageRepository,
    required this.itemImageCreationService,
    required this.itemImageUpdateService,
    required this.itemImageDisplayService,
    super.key,
  });

  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final ItemRepository itemRepository;
  final ItemImageRepository itemImageRepository;
  final ItemImageCreationService itemImageCreationService;
  final ItemImageUpdateService itemImageUpdateService;
  final ItemImageDisplayService itemImageDisplayService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NociBlacK Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(
        authRepository: authRepository,
        categoryRepository: categoryRepository,
        itemRepository: itemRepository,
        itemImageRepository: itemImageRepository,
        itemImageCreationService: itemImageCreationService,
        itemImageUpdateService: itemImageUpdateService,
        itemImageDisplayService: itemImageDisplayService,
      ),
    );
  }
}
