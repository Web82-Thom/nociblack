import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/core/formatters/price_formatter.dart';

void main() {
  test('formats integer cents as euros without floating-point arithmetic', () {
    expect(PriceFormatter.inEuros(0), '0,00 €');
    expect(PriceFormatter.inEuros(5), '0,05 €');
    expect(PriceFormatter.inEuros(1299), '12,99 €');
  });
}
