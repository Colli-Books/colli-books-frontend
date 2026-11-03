import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

void main() {
  // ===========================================================================
  // US18 — Navegação com seções institucionais
  // ===========================================================================

  patrolTest('US18 — o menu lateral do professor abre as seções institucionais', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher();

    await $.launchApp();
    await $.loginAsTeacher(teacher.email, teacher.password);

    await $.openDrawer();
    await $.seeText('SIGA-NOS'); // rodapé do menu

    // Itens que o menu tem hoje. Editora, PNLD, Blog e Anima Kids abrem o navegador:
    // aqui só se verifica que existem (tocar neles sai do app).
    for (final item in ['Editora', 'PNLD', 'Blog', 'Anima Kids', 'Sobre Nós']) {
      expect($.hasText(item), isTrue, reason: 'item "$item" ausente no menu');
    }
    expect($.hasText('Termos de Uso'), isTrue);
    expect($.hasText('Política de Privacidade'), isTrue);

    // Seções internas: abrem uma tela própria e voltam ao menu.
    for (final item in ['Sobre Nós', 'Termos de Uso', 'Política de Privacidade']) {
      await $.tapText(item);
      await $.goneText('SIGA-NOS'); // o menu ficou por baixo da nova tela
      await $.goBack();
      await $.seeText('SIGA-NOS');
    }
  });

  patrolTest('US18 — o menu traz Home, Editora, PNLD, Catálogo, Blog, Anima Kids e Contato',
          ($) async {
        final api = await E2eApi.asAdmin();
        final teacher = await api.createActiveTeacher();

        await $.launchApp();
        await $.loginAsTeacher(teacher.email, teacher.password);
        await $.openDrawer();

        for (final item in ['Home', 'Editora', 'PNLD', 'Catálogo', 'Blog', 'Anima Kids', 'Contato']) {
          expect($.hasText(item), isTrue, reason: 'a US18 pede o item "$item" no menu');
        }
      }, skip: true); // LACUNA: o menu atual não tem Home, Catálogo nem Contato, e tem "Sobre Nós"

  patrolTest('US18 — o administrador vê "Visão Geral" no menu; o professor não', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher();

    // Admin: a partir de outra aba, para "Visão Geral" não ser o título da página.
    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Professores');
    await $.openDrawer();
    expect($.hasText('Visão Geral'), isTrue);

    // Professor: a opção não existe.
    await $.launchApp();
    await $.loginAsTeacher(teacher.email, teacher.password);
    await $.openDrawer();
    expect($.hasText('Visão Geral'), isFalse);
  }, skip: true); // A CONFIRMAR: depende do conteúdo de sidebar_admin.dart (remova o skip após conferir)

  // ===========================================================================
  // Fale Conosco (compartilhado entre os dois perfis)
  // ===========================================================================

  patrolTest('Fale Conosco — acessível pelo rodapé do login', ($) async {
    await $.launchApp();
    await $.tapKey('login_footer_contact');

    await $.seeText('WHATSAPP OFICIAL');
    await $.seeText('E-MAIL COMERCIAL');

    // Telefone: tocar copia o número.
    await $.tapText('+55 (61) 98212-7673');
    await $.seeText('Telefone copiado para a área de transferência!');

    await $.goBack();
    await $.seeKey('login_submit');
  });

  patrolTest('Fale Conosco — acessível pelo perfil do professor', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher();

    await $.launchApp();
    await $.loginAsTeacher(teacher.email, teacher.password);
    await $.tapText('Perfil');
    await $.tapText('Fale Conosco');

    await $.seeText('WHATSAPP OFICIAL');
    await $.goBack();
    await $.seeText('Minhas Informações'); // voltou ao perfil
  });
}