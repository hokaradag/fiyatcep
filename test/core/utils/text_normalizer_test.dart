import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/core/utils/text_normalizer.dart';

void main() {
  group('TextNormalizer', () {
    test('normalizes c-cedilla (ç) to c', () {
      expect(TextNormalizer.normalize('çay'), equals('cay'));
      expect(TextNormalizer.normalize('Çilek'), equals('cilek'));
    });

    test('normalizes g-breve (ğ) to g', () {
      expect(TextNormalizer.normalize('yoğurt'), equals('yogurt'));
      expect(TextNormalizer.normalize('Dağ'), equals('dag'));
    });

    test('normalizes dotless-i (ı) to i', () {
      expect(TextNormalizer.normalize('kızılırmak'), equals('kizilirmak'));
      expect(TextNormalizer.normalize('Sıvı'), equals('sivi'));
    });

    test('normalizes o-umlaut (ö) to o', () {
      expect(TextNormalizer.normalize('öğrenci'), equals('ogrenci'));
      expect(TextNormalizer.normalize('Göz'), equals('goz'));
    });

    test('normalizes s-cedilla (ş) to s', () {
      expect(TextNormalizer.normalize('şeker'), equals('seker'));
      expect(TextNormalizer.normalize('Şiş'), equals('sis'));
    });

    test('normalizes u-umlaut (ü) to u', () {
      expect(TextNormalizer.normalize('üzüm'), equals('uzum'));
      expect(TextNormalizer.normalize('Süt'), equals('sut'));
    });

    test('converts to lowercase', () {
      expect(TextNormalizer.normalize('ABC'), equals('abc'));
      expect(TextNormalizer.normalize('MAKARNA'), equals('makarna'));
    });

    test('handles mixed Turkish and ASCII characters', () {
      expect(TextNormalizer.normalize('Süt 1L'), equals('sut 1l'));
      expect(TextNormalizer.normalize('Çamaşır Deterjanı'), equals('camasir deterjani'));
    });

    test('handles empty string', () {
      expect(TextNormalizer.normalize(''), equals(''));
    });

    test('handles string with no Turkish characters', () {
      expect(TextNormalizer.normalize('makarna'), equals('makarna'));
      expect(TextNormalizer.normalize('PASTA'), equals('pasta'));
    });
  });
}
