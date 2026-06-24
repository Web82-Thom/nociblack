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

final class ItemConflictFailure extends ItemFailure {
  const ItemConflictFailure()
    : super('Un article possède déjà ce slug ou cette REF.');
}

final class ItemSaveFailure extends ItemFailure {
  const ItemSaveFailure()
    : super('Impossible d’enregistrer l’article pour le moment.');
}
