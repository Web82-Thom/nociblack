import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/core/formatters/price_formatter.dart';

void main() {
  test('formats integer cents as euros without floating-point arithmetic', () {
    expect(PriceFormatter.inEuros(0), '0,00 €');
    expect(PriceFormatter.inEuros(5), '0,05 €');
    expect(PriceFormatter.inEuros(1299), '12,99 €');
  });

  test('parses French euro input as integer cents', () {
    expect(PriceFormatter.tryParseEuros('19,99'), 1999);
    expect(PriceFormatter.tryParseEuros('19.9'), 1990);
    expect(PriceFormatter.tryParseEuros('0'), 0);
    expect(PriceFormatter.tryParseEuros('12,999'), isNull);
    expect(PriceFormatter.tryParseEuros('-1'), isNull);
  });
}
