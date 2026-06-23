/// Configuration externe nécessaire au démarrage de l'application.
///
/// Les valeurs proviennent des `dart-define` injectés au lancement. Aucune
/// configuration propre à un environnement ne doit être codée en dur.
final class AppEnvironment {
  const AppEnvironment._({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  factory AppEnvironment.fromEnvironment() {
    const rawSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const rawPublishableKey = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    );

    return AppEnvironment.fromValues(
      supabaseUrl: rawSupabaseUrl,
      supabasePublishableKey: rawPublishableKey,
    );
  }

  factory AppEnvironment.fromValues({
    required String supabaseUrl,
    required String supabasePublishableKey,
  }) {
    final normalizedUrl = supabaseUrl.trim();
    final normalizedKey = supabasePublishableKey.trim();
    final parsedUrl = Uri.tryParse(normalizedUrl);

    if (parsedUrl == null ||
        parsedUrl.scheme != 'https' ||
        parsedUrl.host.isEmpty ||
        (parsedUrl.path.isNotEmpty && parsedUrl.path != '/') ||
        parsedUrl.hasQuery ||
        parsedUrl.hasFragment) {
      throw StateError(
        'SUPABASE_URL doit contenir l’URL HTTPS racine du projet Supabase.',
      );
    }

    if (normalizedKey.isEmpty) {
      throw StateError('SUPABASE_PUBLISHABLE_KEY est absente.');
    }

    return AppEnvironment._(
      supabaseUrl: parsedUrl,
      supabasePublishableKey: normalizedKey,
    );
  }

  final Uri supabaseUrl;
  final String supabasePublishableKey;
}
