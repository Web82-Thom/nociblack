import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/supabase/supabase_initializer.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/categories/data/repositories/supabase_category_repository.dart';
import 'features/items/data/repositories/supabase_item_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromEnvironment();
  await const SupabaseInitializer().initialize(environment);

  final authRepository = SupabaseAuthRepository(Supabase.instance.client);
  final categoryRepository = SupabaseCategoryRepository(
    Supabase.instance.client,
  );
  final itemRepository = SupabaseItemRepository(Supabase.instance.client);

  runApp(
    NociBlackAdminApp(
      authRepository: authRepository,
      categoryRepository: categoryRepository,
      itemRepository: itemRepository,
    ),
  );
}
