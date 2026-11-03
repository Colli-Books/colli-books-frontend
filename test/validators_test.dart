import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:colli_books_frontend/core/utils/validators.dart';

void main() {
  group('IsbnInputFormatter - Testes Parametrizados', () {
    final formatter = IsbnInputFormatter();

    // Matriz de dados para Teste Parametrizado
    final isbnTestCases = [
      {
        'description': '13 dígitos numéricos puros',
        'input': '9786560790469',
        'expected': '978-65-6079-046-9',
      },
      {
        'description': 'Dígitos intercalados com letras e caracteres especiais',
        'input': '978-abc-65-6079-046-9',
        'expected': '978-65-6079-046-9',
      },
      {
        'description': 'Mais de 13 dígitos numéricos (deve truncar em 13)',
        'input': '978656079046999999',
        'expected': '978-65-6079-046-9',
      },
      {
        'description': 'Apenas 3 dígitos (prefixo de país)',
        'input': '978',
        'expected': '978',
      },
      {
        'description': '4 dígitos (deve adicionar primeiro hífen)',
        'input': '9786',
        'expected': '978-6',
      },
      {
        'description': '6 dígitos (deve adicionar segundo hífen)',
        'input': '978656',
        'expected': '978-65-6',
      },
      {
        'description': 'Texto vazio',
        'input': '',
        'expected': '',
      },
    ];

    for (final testCase in isbnTestCases) {
      test('Caso parametrizado: ${testCase['description']}', () {
        final input = testCase['input']!;
        final res = formatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: input,
            selection: TextSelection.collapsed(offset: input.length),
          ),
        );
        expect(res.text, equals(testCase['expected']));
      });
    }
  });

  group('FormValidators URL - Testes Parametrizados', () {
    final urlTestCases = [
      {'url': 'https://drive.google.com/file/d/123/view', 'isValid': true, 'reason': 'Google Drive HTTPS válido'},
      {'url': 'https://www.collibooksloja.com/infantil/o-segredo-de-aurora', 'isValid': true, 'reason': 'Loja Colli Books HTTPS válida'},
      {'url': 'https://www.collibooks.com/o-segredo-de-aurora-lp/', 'isValid': true, 'reason': 'Landing page HTTPS válida'},
      {'url': 'http://meusite.com.br', 'isValid': true, 'reason': 'HTTP válido'},
      {'url': '', 'isValid': true, 'reason': 'Vazio permitido quando opcional'},
      {'url': 'https:/drive.google.com', 'isValid': false, 'reason': 'Falta barra após https:'},
      {'url': 'https//drive.google.com', 'isValid': false, 'reason': 'Falta dois pontos após https'},
      {'url': 'drive.google.com', 'isValid': false, 'reason': 'Falta protocolo http/https'},
      {'url': 'https://google com', 'isValid': false, 'reason': 'Espaço proibido na URL'},
      {'url': 'https://google', 'isValid': false, 'reason': 'Sem TLD / ponto'},
    ];

    for (final tc in urlTestCases) {
      test('Validação de URL: [${tc['reason']}] -> "${tc['url']}"', () {
        final result = FormValidators.isValidUrl(tc['url'] as String?);
        expect(result, equals(tc['isValid']));
      });
    }
  });

  group('FormValidators E-mail - Testes Parametrizados', () {
    final emailTestCases = [
      {'email': 'professor@escola.com.br', 'isValid': true, 'desc': 'E-mail institucional com .br'},
      {'email': 'vendas@collibooks.com', 'isValid': true, 'desc': 'E-mail comercial .com'},
      {'email': 'ana.silva+teste@dominio.org', 'isValid': true, 'desc': 'E-mail com subendereçamento (+)'},
      {'email': 'sem-arroba.com', 'isValid': false, 'desc': 'E-mail sem arroba'},
      {'email': 'usuario@', 'isValid': false, 'desc': 'E-mail sem domínio'},
      {'email': '@dominio.com', 'isValid': false, 'desc': 'E-mail sem usuário'},
      {'email': 'usuario@dominio', 'isValid': false, 'desc': 'E-mail sem TLD / extensão'},
      {'email': '', 'isValid': false, 'desc': 'String vazia'},
      {'email': null, 'isValid': false, 'desc': 'Nulo'},
    ];

    for (final tc in emailTestCases) {
      test('E-mail: [${tc['desc']}] -> "${tc['email']}"', () {
        final result = FormValidators.isValidEmail(tc['email'] as String?);
        expect(result, equals(tc['isValid']));
      });
    }
  });

  group('FormValidators Senha (Contratos API) - Testes Parametrizados', () {
    final passwordTestCases = [
      {'pwd': 'Senha123', 'isValid': true, 'desc': 'Senha válida com letras e dígitos (8 caracteres)'},
      {'pwd': 'ColliBooks2026!', 'isValid': true, 'desc': 'Senha forte com símbolo e números (>8 chars)'},
      {'pwd': '1234567', 'isValid': false, 'desc': 'Muito curta (<8 caracteres)'},
      {'pwd': 'apenasletras', 'isValid': false, 'desc': 'Falta número'},
      {'pwd': '1234567890', 'isValid': false, 'desc': 'Falta letra'},
      {'pwd': '', 'isValid': false, 'desc': 'Vazia'},
      {'pwd': null, 'isValid': false, 'desc': 'Nula'},
    ];

    for (final tc in passwordTestCases) {
      test('Senha: [${tc['desc']}]', () {
        final result = FormValidators.isValidPassword(tc['pwd'] as String?);
        expect(result, equals(tc['isValid']));
      });
    }
  });
}
