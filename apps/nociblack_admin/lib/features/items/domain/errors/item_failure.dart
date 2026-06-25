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

/// La restauration d'un article archivé vers l'état brouillon a échoué.
final class ItemRestoreFailure extends ItemFailure {
  const ItemRestoreFailure()
    : super('Impossible de restaurer l’article pour le moment.');
}

final class ItemDeleteFailure extends ItemFailure {
  const ItemDeleteFailure()
    : super('Impossible de supprimer définitivement l’article pour le moment.');
}

final class ItemImageUnsupportedFormatFailure extends ItemFailure {
  const ItemImageUnsupportedFormatFailure()
    : super('Le format de cette image n’est pas pris en charge.');
}

final class ItemImageProcessingFailure extends ItemFailure {
  const ItemImageProcessingFailure()
    : super('Impossible de préparer cette image pour l’envoi.');
}

final class ItemImageTooLargeFailure extends ItemFailure {
  const ItemImageTooLargeFailure()
    : super('L’image traitée dépasse la limite de 5 Mo.');
}

final class ItemImageUploadFailure extends ItemFailure {
  const ItemImageUploadFailure()
    : super('Impossible d’envoyer cette image pour le moment.');
}

final class ItemImageSaveFailure extends ItemFailure {
  const ItemImageSaveFailure()
    : super('Impossible d’associer cette image à l’article.');
}

final class ItemImagesLoadFailure extends ItemFailure {
  const ItemImagesLoadFailure()
    : super('Impossible de charger les images de l’article.');
}

final class ItemImageDisplayFailure extends ItemFailure {
  const ItemImageDisplayFailure()
    : super('Impossible d’afficher cette image pour le moment.');
}

final class ItemImageCleanupFailure extends ItemFailure {
  const ItemImageCleanupFailure()
    : super('L’image n’a pas pu être nettoyée après l’échec.');
}

final class ItemCreationRollbackFailure extends ItemFailure {
  const ItemCreationRollbackFailure()
    : super(
        'L’enregistrement des images a échoué et le brouillon créé n’a pas pu '
        'être annulé automatiquement.',
      );
}
