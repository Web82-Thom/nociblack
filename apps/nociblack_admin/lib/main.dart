import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromEnvironment();
  await const SupabaseInitializer().initialize(environment);

  runApp(const NociBlackAdminApp());
}
