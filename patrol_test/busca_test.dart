import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

typedef _Scene = ({E2eApi api, CatalogFixture fx, TestTeacher teacher});

/// Prepara tudo pela API: catálogo de teste (2 temas, 2 escolaridades, 3 obras) e um professor ativo.
Future<_Scene> _arrange() async {
  final api = await E2eApi.asAdmin();
  final fx = await CatalogFixture.seed(api);
  final teacher = await api.createActiveTeacher();
  return (api: api, fx: fx, teacher: teacher);
}

Future<void> _enter(PatrolIntegrationTester $, TestTeacher teacher) async {
  await $.launchApp();
  await $.loginAsTeacher(teacher.email, teacher.password);
}

Future<void> _search(PatrolIntegrationTester $, String term) =>
    $.typeKey('catalog_search', term);

Future<void> _pickTheme(PatrolIntegrationTester $, int id) async {
  await $.tapKey('catalog_filter_theme');
  await $.tapInList('pick_option_$id');
}

Future<void> _pickLevel(PatrolIntegrationTester $, int id) async {
  await $.tapKey('catalog_filter_level');
  await $.tapInList('pick_option_$id');
}

void main() {
  // ===========================================================================
  // US07 — Busca de obras por nome
  // ===========================================================================

  patrolTest('US07 — a busca por nome ignora acentuação e maiúsculas', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    // "Árvore Mágica <id>" é achada por "arvore magica <id>".
    await _search($, foldAccents(s.fx.b1.title).toLowerCase());

    await $.seeKey('book_card_${s.fx.b1.id}');
    await $.goneKey('book_card_${s.fx.b2.id}');
    await $.goneKey('book_card_${s.fx.b3.id}');
  });

  patrolTest('US07 — busca sem resultado mostra a mensagem de ausência', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await _search($, 'zzzz-sem-resultado-${DateTime.now().millisecondsSinceEpoch}');
    await $.seeText('Nenhuma obra encontrada para esta pesquisa.');
  });

  gapTest(
    'US07 — a listagem é paginada',
    'a API devolve a lista inteira, sem paginação (GET /books)',
  );

  // ===========================================================================
  // US08 — Filtro por tema e escolaridade
  // ===========================================================================

  patrolTest('US08 — filtro por tema: só as obras do tema; obra em vários temas aparece em todos',
          ($) async {
        final s = await _arrange();
        await _enter($, s.teacher);

        // Tema A: b1 e b2 (b2 também está no tema B); b3 não tem tema.
        await _pickTheme($, s.fx.themeA.id);
        await $.seeKey('book_card_${s.fx.b1.id}');
        await $.seeKey('book_card_${s.fx.b2.id}');
        await $.goneKey('book_card_${s.fx.b3.id}');

        // Tema B: só b2.
        await _pickTheme($, s.fx.themeB.id);
        await $.seeKey('book_card_${s.fx.b2.id}');
        await $.goneKey('book_card_${s.fx.b1.id}');
      });

  patrolTest('US08 — filtro por escolaridade', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await _pickLevel($, s.fx.level1.id);
    await $.seeKey('book_card_${s.fx.b1.id}');
    await $.goneKey('book_card_${s.fx.b2.id}');

    await _pickLevel($, s.fx.level2.id);
    await $.seeKey('book_card_${s.fx.b2.id}');
    await $.goneKey('book_card_${s.fx.b1.id}');
  });

  patrolTest('US08 — tema e escolaridade combinados são aplicados juntos', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    // Tema A + escolaridade 2: só b2 (b1 é do tema A, mas da escolaridade 1).
    await _pickTheme($, s.fx.themeA.id);
    await _pickLevel($, s.fx.level2.id);

    await $.seeKey('book_card_${s.fx.b2.id}');
    await $.goneKey('book_card_${s.fx.b1.id}');
    await $.goneKey('book_card_${s.fx.b3.id}');
  });

  patrolTest('US08 — limpar os filtros volta ao resultado completo', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await _pickTheme($, s.fx.themeA.id);
    await $.goneKey('book_card_${s.fx.b3.id}');

    await $.tapKey('catalog_filter_theme');
    await $.tapInList('pick_option_all'); // "Todos os temas"

    // b3 não tem tema: só reaparece sem o filtro.
    await _search($, s.fx.b3.title);
    await $.seeKey('book_card_${s.fx.b3.id}');
  });

  // ===========================================================================
  // US09 — Detalhe da obra
  // ===========================================================================

  patrolTest('US09 — o detalhe mostra capa/título, autor, sinopse, ISBN, páginas, escolaridade e temas',
          ($) async {
        final s = await _arrange();
        final b = s.fx.b1;
        await _enter($, s.teacher);

        await _search($, b.title);
        await $.tapKey('book_card_${b.id}', scroll: true);

        await $.seeText('Detalhe da Obra');
        await $.seeText(b.title);
        await $.seeText('Por ${b.author}');
        await $.seeText(b.synopsis!);
        await $.seeText(b.isbn!);
        await $.seeText('${b.pageCount}');
        await $.seeText(s.fx.level1.name.toUpperCase());
        await $.seeText(s.fx.themeA.name.toUpperCase());

        // O botão de compra existe. Tocar nele abre o navegador (sai do app): não é verificado aqui.
        await $.seeText('Comprar na Loja');
      });

  patrolTest('US09 — tocar num tema do detalhe leva à busca filtrada por ele', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await _search($, s.fx.b1.title);
    await $.tapKey('book_card_${s.fx.b1.id}', scroll: true);
    await $.tapText(s.fx.themeA.name.toUpperCase());

    // Esperado pela US: o catálogo filtrado pelo tema A (b1 e b2, sem b3).
    await $.seeKey('book_card_${s.fx.b2.id}');
    await $.goneKey('book_card_${s.fx.b3.id}');
  }, skip: true); // LACUNA: os temas do detalhe não são clicáveis (ver E2E_SETUP.md)

  // ===========================================================================
  // US10 — Informações pessoais do professor
  // ===========================================================================

  patrolTest('US10 — e-mail somente leitura; nome e escola são editáveis e persistem', ($) async {
    final s = await _arrange();
    final newName = uniq('Paulo Souza');
    await _enter($, s.teacher);

    await $.tapText('Perfil');
    await $.seeText(s.teacher.name);
    await $.tapText('Minhas Informações');

    await $.seeText('Meus Dados');
    await $.seeText(s.teacher.email);
    await $.seeText('O e-mail é a identidade da sua conta e não pode ser alterado por aqui.');

    await $.typeKey('meus_dados_name', newName);
    await $.typeKey('meus_dados_school', 'Escola E2E');
    await $.tapText('Salvar Alterações', scroll: true);
    await $.seeText('Informações atualizadas com sucesso!');

    // De volta ao perfil, já com os dados novos.
    await $.seeText(newName);
    await $.seeText('ESCOLA E2E');

    // Persistem entre sessões: reabrir o app (sessão restaurada) mostra o mesmo.
    await $.launchApp(clearSession: false);
    await $.seeKey('catalog_search');
    await $.tapText('Perfil');
    await $.seeText(newName);
  });

  patrolTest('US10 — o nome não pode ficar vazio', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await $.tapText('Perfil');
    await $.tapText('Minhas Informações');
    await $.typeKey('meus_dados_name', '');
    await $.tapText('Salvar Alterações', scroll: true);

    await $.seeText('Por favor, informe seu nome completo.');
  });

  gapTest(
    'US10 — o cabeçalho mostra o nome (ou o e-mail, se não houver nome)',
    'a AppBar do professor só mostra o logo; o nome aparece apenas no Perfil',
  );

  // ===========================================================================
  // US11 — Vinculação do professor a temas e escolaridades
  // ===========================================================================

  gapTest(
    'US11 — o professor escolhe os temas e escolaridades que leciona',
    'sem GET de interesses na API, a tela não foi construída (salvar às cegas apagaria os vínculos)',
  );

  // ===========================================================================
  // US12 — Seleção e salvamento de obras
  // ===========================================================================

  patrolTest('US12 — salvar uma obra a coloca em "Minha Seleção"; dá para removê-la', ($) async {
    final s = await _arrange();
    final b = s.fx.b1;
    await _enter($, s.teacher);

    await _search($, b.title);
    await $.tapKey('book_save_${b.id}', scroll: true);
    await $.seeText('"${b.title}" adicionado à sua Seleção!');
    expect($.savedMarkerOn(b.id), isTrue); // o botão indica o estado salvo

    await $.tapText('Seleção');
    await $.seeText('Minha Seleção (1)');
    await $.seeKey('book_card_${b.id}');

    // Remover da própria Seleção.
    await $.tapKey('book_save_${b.id}', scroll: true);
    await $.seeText('Sua Seleção está vazia');
  });

  patrolTest('US12 — a Seleção persiste entre sessões', ($) async {
    final s = await _arrange();
    await s.api.saveBookFor(s.teacher, s.fx.b1.id);

    await _enter($, s.teacher);
    await $.tapText('Seleção');
    await $.seeText('Minha Seleção (1)');
    await $.seeKey('book_card_${s.fx.b1.id}');

    // Fechar e reabrir o app.
    await $.launchApp(clearSession: false);
    await $.seeKey('catalog_search');
    await $.tapText('Seleção');
    await $.seeKey('book_card_${s.fx.b1.id}');
  });

  patrolTest('US12 — o estado "salva" é o mesmo no catálogo e no detalhe', ($) async {
    final s = await _arrange();
    final b = s.fx.b1;
    await _enter($, s.teacher);

    await _search($, b.title);
    await $.seeKey('book_card_${b.id}');
    expect($.savedMarkerOn(b.id), isFalse);

    await $.tapKey('book_card_${b.id}', scroll: true);
    await $.tapText('Salvar na Seleção');
    await $.seeText('Salvo na Seleção');

    await $.goBack();
    await $.waitFor(() => $.savedMarkerOn(b.id), 'marcador "salva" no cartão do catálogo');
  });

  patrolTest('US12 — Seleção vazia convida a explorar o acervo', ($) async {
    final s = await _arrange();
    await _enter($, s.teacher);

    await $.tapText('Seleção');
    await $.seeText('Sua Seleção está vazia');
    await $.tapText('Explorar Obras');
    await $.seeKey('catalog_search'); // voltou ao catálogo
  });
}