import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

const _wrongCreds = 'E-mail ou senha incorretos.';
const _invalidResetToken = 'Código inválido, já usado ou expirado. Solicite um novo link.';

/// Pede a recuperação de senha pela interface e devolve a mensagem exibida.
Future<String> _requestRecovery(PatrolIntegrationTester $, String email) async {
  await $.launchApp();
  await $.tapKey('login_tab_forgot');
  await $.seeText('Recuperação de Senha');
  await $.typeKey('forgot_email', email);
  await $.tapKey('forgot_submit', scroll: true);
  await $.seeKey('forgot_feedback_text');
  return $.textOfKey('forgot_feedback_text');
}

void main() {
  // ===========================================================================
  // US03 / US05 — Autenticação (professor e administrador)
  // ===========================================================================

  patrolTest('US05 — admin entra no painel e sai; reabrir o app volta ao login', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();

    await $.logoutViaUi();

    // Sem limpar a sessão salva: se o logout não tivesse encerrado a sessão de verdade,
    // o app reabriria logado.
    await $.launchApp(clearSession: false);
    await $.seeKey('login_submit');
  });

  patrolTest('US03 — professor entra na área do professor (e não vê a do admin) e sai', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher();

    await $.launchApp();
    await $.loginAsTeacher(teacher.email, teacher.password);

    // Cada perfil vê só a sua área.
    expect($.hasText('Professores'), isFalse);
    expect($.hasText('Visão Geral'), isFalse);

    await $.logoutViaUi();
    await $.launchApp(clearSession: false);
    await $.seeKey('login_submit');
  });

  patrolTest('US03-US05 — a sessão persiste ao fechar e reabrir o app', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher();

    // professor
    await $.launchApp();
    await $.loginAsTeacher(teacher.email, teacher.password);
    await $.launchApp(clearSession: false);
    await $.seeKey('catalog_search');

    // admin
    await $.launchApp();
    await $.loginAsAdmin();
    await $.launchApp(clearSession: false);
    await $.seeText('Visão Geral');
  });

  patrolTest('US03-US05 — sem sessão, o app abre no login (rota restrita redireciona)', ($) async {
    await $.launchApp();
    await $.seeKey('login_submit');
    expect($.hasText('Visão Geral'), isFalse);
    expect($.hasKey('catalog_search'), isFalse);
  });

  patrolTest(
    'US03-US05 — credenciais incorretas: mensagem genérica, sem revelar se o e-mail existe',
        ($) async {
      await $.launchApp();

      // E-mail que NÃO existe.
      await $.loginViaUi(uniqEmail('inexistente'), 'qualquer-senha-123');
      await $.seeText(_wrongCreds);
      expect($.hasKey('login_submit'), isTrue); // continua no login

      // Espera a snackbar sumir para provar que a próxima é uma resposta nova.
      await $.goneText(_wrongCreds, timeout: const Duration(seconds: 15));

      // E-mail que EXISTE, senha errada: exatamente a mesma mensagem.
      await $.loginViaUi(E2eEnv.adminEmail, 'senha-errada-123');
      await $.seeText(_wrongCreds);
    },
  );

  patrolTest('US03 — campos vazios pedem e-mail e senha', ($) async {
    await $.launchApp();
    await $.tapKey('login_submit');
    await $.seeText('Por favor, preencha o e-mail e a senha.');
    expect($.hasKey('login_submit'), isTrue);
  });

  gapTest(
    'US05 — o nome do administrador aparece no cabeçalho',
    'AdminHomeScreen só mostra o logo na AppBar',
  );

  // ===========================================================================
  // US04 / US06 — Redefinição de senha (professor e administrador)
  // ===========================================================================

  patrolTest(
    'US04 — "Esqueci minha senha": mesma mensagem para e-mail existente e inexistente',
        ($) async {
      final api = await E2eApi.asAdmin();
      final teacher = await api.createActiveTeacher();

      final existing = await _requestRecovery($, teacher.email);
      final missing = await _requestRecovery($, uniqEmail('naoexiste'));

      expect(existing, isNotEmpty);
      expect(missing, existing, reason: 'a mensagem não pode revelar quais contas existem');
    },
  );

  patrolTest('US06 — "Esqueci minha senha" do administrador: mesma regra de não revelar contas',
          ($) async {
        final existing = await _requestRecovery($, E2eEnv.adminEmail);
        final missing = await _requestRecovery($, uniqEmail('naoexiste'));
        expect(missing, existing);
      });

  patrolTest('US04 — e-mail em formato inválido não é enviado', ($) async {
    await $.launchApp();
    await $.tapKey('login_tab_forgot');
    await $.typeKey('forgot_email', 'isto-nao-e-um-email');
    await $.tapKey('forgot_submit', scroll: true);

    await $.pump(const Duration(seconds: 1));
    expect($.hasKey('forgot_feedback_text'), isFalse, reason: 'não deve confirmar um envio');
    expect($.hasText('Recuperação de Senha'), isTrue); // continua na mesma tela
  });

  patrolTest('US04 — código de redefinição inválido é recusado', ($) async {
    await $.launchApp();
    await $.tapKey('login_tab_forgot');
    await $.tapKey('forgot_show_reset', scroll: true);
    await $.typeKey('reset_token', 'token-invalido-${DateTime.now().millisecondsSinceEpoch}', scroll: true);
    await $.typeKey('reset_password', 'Nova-Senha-456', scroll: true);
    await $.tapKey('reset_submit', scroll: true);

    await $.seeText(_invalidResetToken);
  });

  patrolTest(
    'US04-US06 — redefinição completa pelo link do e-mail; o link vale uma vez só',
        ($) async {
      final api = await E2eApi.asAdmin();
      final teacher = await api.createActiveTeacher(label: 'reset');
      const newPassword = 'Nova-Senha-456';

      // O administrador usa o mesmo fluxo e o mesmo backend; não redefinimos a senha dele
      // aqui para não quebrar as credenciais do restante da suíte.
      await _requestRecovery($, teacher.email);

      final token = await E2eMail.latestToken(teacher.email);
      expect(token, isNotNull, reason: 'o e-mail de redefinição não chegou ao coletor');

      await $.tapKey('forgot_show_reset', scroll: true);
      await $.typeKey('reset_token', token!, scroll: true);
      await $.typeKey('reset_password', newPassword, scroll: true);
      await $.tapKey('reset_submit', scroll: true);
      await $.seeText('Senha redefinida com sucesso! Você já pode entrar com sua nova senha.');

      // A senha antiga deixa de valer...
      await $.loginViaUi(teacher.email, teacher.password);
      await $.seeText(_wrongCreds);
      await $.goneText(_wrongCreds, timeout: const Duration(seconds: 15));

      // ...e a nova funciona.
      await $.loginViaUi(teacher.email, newPassword);
      await $.seeKey('catalog_search');

      // O token é de uso único.
      await $.logoutViaUi();
      await $.tapKey('login_tab_forgot');
      await $.tapKey('forgot_show_reset', scroll: true);
      await $.typeKey('reset_token', token, scroll: true);
      await $.typeKey('reset_password', 'Outra-Senha-789', scroll: true);
      await $.tapKey('reset_submit', scroll: true);
      await $.seeText(_invalidResetToken);
    },
    skip: E2eEnv.mailpitUrl.isEmpty,
  );
}