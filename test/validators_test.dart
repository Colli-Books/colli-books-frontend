import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:colli_books_frontend/core/utils/validators.dart';

void main() {
  group('IsbnInputFormatter', () {
    final formatter = IsbnInputFormatter();

    test('formata 13 dígitos automaticamente', () {
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '9786560790469',
          selection: TextSelection.collapsed(offset: 13),
        ),
      );
      expect(res.text, '978-65-6079-046-9');
    });

    test('ignora caracteres que não são números', () {
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '978-abc-65-6079-046-9',
          selection: TextSelection.collapsed(offset: 21),
        ),
      );
      expect(res.text, '978-65-6079-046-9');
    });

    test('limita em 13 dígitos numéricos', () {
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '978656079046999999',
          selection: TextSelection.collapsed(offset: 19),
        ),
      );
      expect(res.text, '978-65-6079-046-9');
    });
  });

  group('FormValidators URL', () {
    test('valida URLs corretas', () {
      expect(FormValidators.isValidUrl('https://drive.google.com/file/d/123/view'), isTrue);
      expect(FormValidators.isValidUrl('https://www.collibooksloja.com/infantil/o-segredo-de-aurora'), isTrue);
      expect(FormValidators.isValidUrl('https://www.collibooks.com/o-segredo-de-aurora-lp/'), isTrue);
      expect(FormValidators.isValidUrl('http://meusite.com.br'), isTrue);
      expect(FormValidators.isValidUrl(''), isTrue); // opcional
    });

    test('rejeita URLs com formato incorreto', () {
      expect(FormValidators.isValidUrl('https:/drive.google.com'), isFalse); // falta uma barra
      expect(FormValidators.isValidUrl('https//drive.google.com'), isFalse); // falta dois pontos
      expect(FormValidators.isValidUrl('drive.google.com'), isFalse); // falta https://
      expect(FormValidators.isValidUrl('https://google com'), isFalse); // espaço
      expect(FormValidators.isValidUrl('https://google'), isFalse); // sem ponto
    });
  });
}
