/// Erreur catalogue stable, indépendante du fournisseur de données.
sealed class ItemFailure implements Exception {
  const ItemFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// La liste des articles n'a pas pu être chargée.
final class ItemsLoadFailure extends ItemFailure {
  const ItemsLoadFailure()
    : super('Impossible de charger les articles pour le moment.');
}
