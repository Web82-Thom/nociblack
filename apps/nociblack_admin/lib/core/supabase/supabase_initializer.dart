import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_environment.dart';

/// Initialise le SDK Supabase avec la configuration de l'environnement.
///
/// Cette responsabilité reste isolée du point d'entrée Flutter et des widgets.
final class SupabaseInitializer {
  const SupabaseInitializer();

  Future<void> initialize(AppEnvironment environment) async {
    await Supabase.initialize(
      url: environment.supabaseUrl.toString(),
      publishableKey: environment.supabasePublishableKey,
    );
  }
}
