/// Résultat métier d'une suppression définitive d'article.
final class ItemDeletionResult {
  const ItemDeletionResult({required this.pendingStorageObjectCount});

  /// Nombre d'objets dont le nettoyage Storage reste durablement en attente.
  final int pendingStorageObjectCount;

  bool get hasPendingStorageCleanup => pendingStorageObjectCount > 0;
}
