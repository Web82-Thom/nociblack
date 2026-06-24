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

final class CategoryConflictFailure extends CategoryFailure {
  const CategoryConflictFailure()
    : super('Une catégorie possède déjà ce nom ou ce slug.');
}

final class CategorySaveFailure extends CategoryFailure {
  const CategorySaveFailure()
    : super('Impossible d’enregistrer la catégorie pour le moment.');
}
