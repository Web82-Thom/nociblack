/// Erreur Catégories indépendante de Supabase.
sealed class CategoryFailure implements Exception {
  const CategoryFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class CategoriesLoadFailure extends CategoryFailure {
  const CategoriesLoadFailure()
    : super('Impossible de charger les catégories pour le moment.');
}
