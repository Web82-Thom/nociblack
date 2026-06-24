/// Formate un prix stocké en centimes sans utiliser de nombre flottant.
abstract final class PriceFormatter {
  static String inEuros(int priceCents) {
    final euros = priceCents ~/ 100;
    final cents = (priceCents % 100).toString().padLeft(2, '0');
    return '$euros,$cents €';
  }
}
