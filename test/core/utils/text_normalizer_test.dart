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

    group('handles uppercase Turkish characters', () {
      test('normalizes uppercase dotted-I (İ) to i', () {
        expect(TextNormalizer.normalize('İ'), equals('i'));
        expect(TextNormalizer.normalize('İstanbul'), equals('istanbul'));
      });

      test('normalizes uppercase C-cedilla (Ç) to c', () {
        expect(TextNormalizer.normalize('Ç'), equals('c'));
      });

      test('normalizes uppercase G-breve (Ğ) to g', () {
        expect(TextNormalizer.normalize('Ğ'), equals('g'));
      });

      test('normalizes uppercase O-umlaut (Ö) to o', () {
        expect(TextNormalizer.normalize('Ö'), equals('o'));
      });

      test('normalizes uppercase S-cedilla (Ş) to s', () {
        expect(TextNormalizer.normalize('Ş'), equals('s'));
      });

      test('normalizes uppercase U-umlaut (Ü) to u', () {
        expect(TextNormalizer.normalize('Ü'), equals('u'));
      });

      test('normalizes ŞOK to sok (UAT scenario)', () {
        expect(TextNormalizer.normalize('ŞOK'), equals('sok'));
      });
    });
  });
}
