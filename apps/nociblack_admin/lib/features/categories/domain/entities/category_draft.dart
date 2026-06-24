/// Données validées nécessaires à la création d'une catégorie.
final class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.slug,
    required this.displayOrder,
    this.description,
  });

  final String name;
  final String slug;
  final String? description;
  final int displayOrder;
}
