import 'package:colli_books_frontend/features/admin/data/models/teacher_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

const _wrongCreds = 'E-mail ou senha incorretos.';

/// Abre "Tenho um convite" no login, cola o código e continua.
Future<void> _openInviteByCode(PatrolIntegrationTester $, String code) async {
  await $.launchApp();
  await $.tapKey('login_have_invite');
  await $.typeKey('invite_code_input', code);
  await $.tapText('Continuar');
}

void main() {
  // ===========================================================================
  // US01 — Cadastro de professor pelo administrador
  // ===========================================================================

  patrolTest(
    'US01 — admin cadastra professor: conta pendente, código e link exibidos para cópia',
        ($) async {
      final api = await E2eApi.asAdmin();
      final email = uniqEmail('novo');

      await $.launchApp();
      await $.loginAsAdmin();

      await $.tapText('Convidar Professor');
      await $.typeKey('invite_email', email);
      await $.tapText('Enviar Convite');
      await $.seeText('Confirmar Envio');
      await $.tapText('Sim');

      // O link também é exibido para cópia (reenvio por WhatsApp se o e-mail não chegar).
      await $.seeText('Código do convite');
      await $.seeText('Link do convite');
      expect($.hasContaining('collibooks://convite?token='), isTrue);

      // A conta existe com status "Convite pendente".
      final teacher = await api.teacherByEmail(email);
      expect(teacher, isNotNull);
      expect(teacher!.status, TeacherStatus.invitePending);
    },
  );

  patrolTest('US01 — e-mail já cadastrado: erro e nenhuma conta duplicada', ($) async {
    final api = await E2eApi.asAdmin();
    final existing = await api.createActiveTeacher(label: 'dup');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Convidar Professor');
    await $.typeKey('invite_email', existing.email);
    await $.tapText('Enviar Convite');
    await $.tapText('Sim');

    await $.seeText('Já existe uma conta com este e-mail.');
    expect($.hasText('Código do convite'), isFalse);

    final matches = (await api.admin.listTeachers(query: existing.email))
        .where((t) => t.email.toLowerCase() == existing.email.toLowerCase());
    expect(matches, hasLength(1));
  });

  patrolTest('US01 — e-mail em formato inválido não chega a ser enviado', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Convidar Professor');
    await $.typeKey('invite_email', 'isto-nao-e-um-email');
    await $.tapText('Enviar Convite');

    await $.pump(const Duration(seconds: 1));
    expect($.hasText('Confirmar Envio'), isFalse);
    expect($.hasKey('invite_email'), isTrue);
  });

  patrolTest('US01 — o login fica bloqueado enquanto a senha não for definida', ($) async {
    final api = await E2eApi.asAdmin();
    final email = uniqEmail('pendente');
    await api.admin.createTeacher(email);

    await $.launchApp();
    await $.loginViaUi(email, 'Qualquer-Senha-123');
    await $.seeText(_wrongCreds);
    expect($.hasKey('login_submit'), isTrue);
  });

  patrolTest('US01/US02 — admin gera um novo convite: o anterior deixa de valer', ($) async {
    final api = await E2eApi.asAdmin();
    final email = uniqEmail('reenvio');
    final first = await api.admin.createTeacher(email);

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Professores');
    await $.seeText('Gestão de Professores');
    await $.typeKey('teachers_search', email);

    // Convite pendente: o cartão traz o botão de reenviar.
    await $.tapKey('teacher_resend_${first.id}', scroll: true);
    await $.seeText('Gerar novo convite');
    await $.tapText('Gerar');
    await $.seeText('Novo convite gerado');
    await $.tapText('Fechar');

    final error = await E2eApi.verifyInvite(first.inviteCode);
    expect(error?.code, 'INVITE_INVALID');
  });

  // ===========================================================================
  // US02 — Primeiro acesso e conclusão do cadastro
  // ===========================================================================

  patrolTest(
    'US02 — professor completa o cadastro com o código e entra autenticado',
        ($) async {
      final api = await E2eApi.asAdmin();
      final email = uniqEmail('primeiro-acesso');
      final invite = await api.admin.createTeacher(email);
      final name = uniq('Paulo');

      await _openInviteByCode($, invite.inviteCode);

      await $.seeText('Complete seu cadastro');
      await $.seeText(email); // e-mail já preenchido (somente leitura)

      // Nome é obrigatório.
      await $.tapText('Concluir Cadastro', scroll: true);
      await $.seeText('Por favor, informe seu nome completo.');

      // A confirmação precisa coincidir com a senha.
      await $.typeKey('accept_name', name, scroll: true);
      await $.typeKey('accept_password', '12345678', scroll: true);
      await $.typeKey('accept_confirm', '87654321', scroll: true);
      await $.tapText('Concluir Cadastro', scroll: true);
      await $.seeText('As senhas não coincidem.');

      // Escola é opcional: concluir sem ela.
      await $.typeKey('accept_confirm', '12345678', scroll: true);
      await $.tapText('Concluir Cadastro', scroll: true);

      await $.seeKey('catalog_search'); // autenticado, na área do professor

      final teacher = await api.teacherByEmail(email);
      expect(teacher?.status, TeacherStatus.active);
      expect(teacher?.fullName, name);
    },
  );

  patrolTest('US02 — senha com menos de 8 caracteres é recusada e a conta não é ativada',
          ($) async {
        final api = await E2eApi.asAdmin();
        final email = uniqEmail('senha-curta');
        final invite = await api.admin.createTeacher(email);

        await _openInviteByCode($, invite.inviteCode);
        await $.seeText('Complete seu cadastro');
        await $.typeKey('accept_name', uniq('Paulo'), scroll: true);
        await $.typeKey('accept_password', 'curta1', scroll: true);
        await $.typeKey('accept_confirm', 'curta1', scroll: true);
        await $.tapText('Concluir Cadastro', scroll: true);

        await $.seeText('A senha deve ter no mínimo 8 caracteres.');
        expect((await api.teacherByEmail(email))?.status, TeacherStatus.invitePending);
      });

  patrolTest('US02 — o link de convite (deep link) abre o cadastro', ($) async {
    final api = await E2eApi.asAdmin();
    final invite = await api.admin.createTeacher(uniqEmail('deeplink'));

    await $.launchApp(deepLinks: true);
    await $.seeKey('login_submit');

    await $.openDeepLink(invite.inviteLink);
    await $.seeText('Complete seu cadastro');
  });

  patrolTest('US02 — convite já utilizado orienta a usar "Esqueci minha senha"', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher(label: 'usado');

    await _openInviteByCode($, teacher.usedInviteToken);

    await $.seeText('Convite já utilizado');
    expect($.hasContaining('Esqueci minha senha'), isTrue);

    await $.tapText('Ir para o login');
    await $.seeKey('login_submit');
  });

  patrolTest('US02 — convite inexistente é recusado', ($) async {
    await _openInviteByCode($, 'invalido-${DateTime.now().millisecondsSinceEpoch}');
    await $.seeText('Convite inválido');
  });

  patrolTest(
    'US02 — convite expirado permite solicitar um novo link sem acionar a editora',
        ($) async {
      await _openInviteByCode($, E2eEnv.expiredInviteToken);

      await $.seeText('Convite expirado');
      await $.tapText('Enviar novo convite');
      await $.waitFor(
            () => $.hasContaining('Se este convite estiver expirado'),
        'confirmação do reenvio',
      );
    },
    skip: E2eEnv.expiredInviteToken.isEmpty,
  );
}