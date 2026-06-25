import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/supabase/supabase_initializer.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/categories/data/repositories/supabase_category_repository.dart';
import 'features/items/data/repositories/supabase_item_repository.dart';
import 'features/items/data/repositories/supabase_item_image_repository.dart';
import 'features/items/data/services/default_item_image_creation_service.dart';
import 'features/items/data/services/default_item_image_update_service.dart';
import 'features/items/data/services/flutter_image_processor.dart';
import 'features/items/data/services/supabase_item_image_display_service.dart';
import 'features/items/data/services/supabase_item_image_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromEnvironment();
  await const SupabaseInitializer().initialize(environment);

  final authRepository = SupabaseAuthRepository(Supabase.instance.client);
  final categoryRepository = SupabaseCategoryRepository(
    Supabase.instance.client,
  );
  final itemRepository = SupabaseItemRepository(Supabase.instance.client);
  final itemImageRepository = SupabaseItemImageRepository(
    Supabase.instance.client,
  );
  final itemImageStorageService = SupabaseItemImageStorageService(
    Supabase.instance.client,
  );
  final imageIdGenerator = const Uuid().v4;
  final itemImageCreationService = DefaultItemImageCreationService(
    imageProcessor: FlutterImageProcessor(),
    storageService: itemImageStorageService,
    imageRepository: itemImageRepository,
    generateImageId: imageIdGenerator,
  );
  final itemImageUpdateService = DefaultItemImageUpdateService(
    imageProcessor: FlutterImageProcessor(),
    storageService: itemImageStorageService,
    imageRepository: itemImageRepository,
    generateImageId: imageIdGenerator,
  );
  final itemImageDisplayService = SupabaseItemImageDisplayService(
    Supabase.instance.client,
  );

  runApp(
    NociBlackAdminApp(
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
