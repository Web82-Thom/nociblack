/// Fournit une URL temporaire permettant d'afficher une image privée.
abstract interface class ItemImageDisplayService {
  Future<String> createDisplayUrl(String imagePath);
}
