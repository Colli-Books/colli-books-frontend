import 'package:colli_books_frontend/features/invites/data/invite_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appLinkFromUri', () {
    test('reconhece o convite', () {
      final link = appLinkFromUri(
        Uri.parse('collibooks://convite?token=abc123'),
      );
      expect(link?.kind, AppLinkKind.invite);
      expect(link?.token, 'abc123');
    });

    test('reconhece a redefinição de senha', () {
      final link = appLinkFromUri(
        Uri.parse('collibooks://redefinir-senha?token=xyz789'),
      );
      expect(link?.kind, AppLinkKind.passwordReset);
      expect(link?.token, 'xyz789');
    });

    for (final raw in [
      'collibooks://outra-coisa?token=abc',
      'collibooks://convite',
      'collibooks://convite?token=',
      'https://exemplo.com/convite?token=abc',
      'collibook://convite?token=abc',
    ]) {
      test('ignora $raw', () {
        expect(appLinkFromUri(Uri.parse(raw)), isNull);
      });
    }
  });

  group('inviteTokenFromUri', () {
    test('só devolve token de convite', () {
      expect(
        inviteTokenFromUri(Uri.parse('collibooks://convite?token=a1')),
        'a1',
      );
      expect(
        inviteTokenFromUri(Uri.parse('collibooks://redefinir-senha?token=a1')),
        isNull,
      );
    });
  });

  group('extractInviteToken', () {
    final cases = {
      'abc123': 'abc123',
      '  abc123  ': 'abc123',
      'collibooks://convite?token=abc123': 'abc123',
      'https://api.exemplo.com/abrir/convite?token=abc123': 'abc123',
    };
    cases.forEach((input, expected) {
      test(
        'aceita "$input"',
        () => expect(extractInviteToken(input), expected),
      );
    });

    test('rejeita vazio e texto com espaço', () {
      expect(extractInviteToken(''), isNull);
      expect(extractInviteToken('abc 123'), isNull);
    });
  });
}
