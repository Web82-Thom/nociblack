/// Formate un prix stocké en centimes sans utiliser de nombre flottant.
abstract final class PriceFormatter {
  static String inEuros(int priceCents) {
    final euros = priceCents ~/ 100;
    final cents = (priceCents % 100).toString().padLeft(2, '0');
    return '$euros,$cents €';
  }

  /// Convertit une saisie en euros vers des centimes sans nombre flottant.
  static int? tryParseEuros(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized)) return null;

    final parts = normalized.split('.');
    final euros = int.parse(parts.first);
    final cents = parts.length == 1
        ? 0
        : int.parse(parts.last.padRight(2, '0'));
    return euros * 100 + cents;
  }
}
