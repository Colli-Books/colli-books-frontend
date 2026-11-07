import 'package:colli_books_frontend/features/catalogo/data/models/book_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

/// Abre o formulário de nova obra: aba Catálogo → "Adicionar Nova Obra".
Future<void> _openNewBookForm(PatrolIntegrationTester $) async {
  await $.tapText('Catálogo');
  await $.tapText('Adicionar Nova Obra', scroll: true);
  await $.seeKey('book_field_title');
}

/// Os seletores de escolaridade e tema só funcionam depois que as opções carregam da API.
Future<void> _waitFormReady(PatrolIntegrationTester $) async {
  await $.goneText('Carregando escolaridades...');
  await $.goneText('Carregando temas...');
}

/// Abre a edição de uma obra pelo catálogo do admin: busca pelo título e toca no lápis.
Future<void> _openEdit(PatrolIntegrationTester $, BookDetail book) async {
  await $.tapText('Catálogo');
  await $.search('catalog_search', book.title);
  await $.tapKey('book_edit_${book.id}', scroll: true);
  await $.seeText('Edição de Obra');
  await _waitFormReady($);
}

Future<void> _saveEdit(PatrolIntegrationTester $) async {
  await $.tapText('Salvar Alterações', scroll: true);
  await $.seeKey('catalog_search'); // voltou ao catálogo
}

void main() {
  // ===========================================================================
  // US13 — Página de início do administrador
  // ===========================================================================

  patrolTest('US13 — o início mostra obras, professores e convites pendentes', ($) async {
    final api = await E2eApi.asAdmin();
    final before = await api.overview();
    await api.admin.createTeacher(uniqEmail('contador')); // +1 convite pendente
    await api.book(); // +1 obra
    final after = await api.overview();
    expect(after.booksCount, before.booksCount + 1);
    expect(after.pendingInvitesCount, before.pendingInvitesCount + 1);

    await $.launchApp();
    await $.loginAsAdmin();

    // A tela mostra exatamente o que a API informa.
    await $.waitFor(() => $.hasIn('summary_books', '${after.booksCount}'), 'contador de obras');
    await $.waitFor(
          () => $.hasIn('summary_teachers', '${after.teachersCount}'),
      'contador de professores',
    );
    await $.waitFor(
          () => $.hasIn('summary_invites', '${after.pendingInvitesCount}'),
      'contador de convites pendentes',
    );
  });

  patrolTest('US13 — atalhos levam a "Convidar professor" e "Cadastrar nova obra"', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();

    await $.tapText('Convidar Professor');
    await $.seeKey('invite_email');
    await $.goBack();
    await $.seeText('Visão Geral');

    await $.tapText('Cadastrar Nova Obra');
    await $.seeKey('book_field_title');
    await $.goBack();
    await $.seeText('Visão Geral');
  });

  patrolTest('US13 — os cartões de contadores levam às listas correspondentes', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();

    await $.tapKey('summary_books');
    await $.seeText('Catálogo de Obras');

    await $.tapText('Início');
    await $.tapKey('summary_invites');
    await $.seeText('Gestão de Professores');
  });

  // ===========================================================================
  // US14 — Página pessoal do administrador
  // ===========================================================================

  patrolTest('US14 — a página pessoal mostra o e-mail, sem campos editáveis, e permite sair',
          ($) async {
        await $.launchApp();
        await $.loginAsAdmin();

        await $.tapText('Perfil');
        await $.seeText(E2eEnv.adminEmail);
        expect(find.byType(TextField).evaluate(), isEmpty);
        expect(find.byType(TextFormField).evaluate(), isEmpty);

        await $.logoutViaUi();
      });

  // ===========================================================================
  // US15 — Cadastro e edição de obras
  // ===========================================================================
  // A capa é enviada pelo seletor de arquivos do sistema (diálogo nativo): não é coberta aqui.

  patrolTest('US15 — cadastra uma obra e ela passa a existir no acervo', ($) async {
    final api = await E2eApi.asAdmin();
    final theme = await api.theme('Tema obra');
    final level = await api.level('Nivel obra');
    final title = uniq('Obra Nova');
    final isbn = uniqIsbn();

    await $.launchApp();
    await $.loginAsAdmin();
    await _openNewBookForm($);

    await $.typeKey('book_field_title', title, scroll: true);
    await $.typeKey('book_field_author', 'Autor E2E', scroll: true);
    await $.typeKey('book_field_isbn', isbn, scroll: true);
    await $.typeKey('book_field_synopsis', 'Sinopse da obra de teste', scroll: true);
    await $.typeKey(
      'book_field_store_url',
      'https://www.collibooksloja.com/obra-nova',
      scroll: true,
    );

    await _waitFormReady($);
    await $.tapKey('book_picker_level', scroll: true);
    await $.tapInList('level_option_${level.id}');
    await $.tapKey('book_picker_themes', scroll: true);
    await $.tapInList('theme_option_${theme.id}');
    await $.tapText('Aplicar');

    await $.tapText('Cadastrar Obra', scroll: true);
    await $.seeKey('catalog_search'); // voltou ao catálogo

    final found = await api.catalog.listBooks(query: title);
    expect(found, hasLength(1));
    final detail = await api.catalog.getBook(found.single.id);
    expect(detail.author, 'Autor E2E');
    expect(detail.synopsis, 'Sinopse da obra de teste');
    expect(digitsOnly(detail.isbn ?? ''), isbn);
    expect(detail.educationLevel?.id, level.id);
    expect(detail.themes.map((t) => t.id), [theme.id]);

    // E aparece na listagem do admin.
    await $.search('catalog_search', title);
    await $.seeKey('book_edit_${detail.id}');
  });

  patrolTest('US15 — campos obrigatórios são validados, com erro por campo', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();
    await _openNewBookForm($);

    await $.tapText('Cadastrar Obra', scroll: true);

    await $.seeText('Informe o título da obra.');
    await $.seeText('Informe o autor(a).');
    await $.seeText('Preencha os campos obrigatórios destacados.');
    expect($.hasKey('book_field_title'), isTrue); // continua no formulário
  });

  patrolTest('US15 — link com formato inválido é sinalizado antes de salvar', ($) async {
    await $.launchApp();
    await $.loginAsAdmin();
    await _openNewBookForm($);

    await $.typeKey('book_field_title', uniq('Obra link ruim'), scroll: true);
    await $.typeKey('book_field_author', 'Autor E2E', scroll: true);
    await $.typeKey('book_field_book_url', 'isso nao e um link', scroll: true);
    await $.tapText('Cadastrar Obra', scroll: true);

    await $.seeText('Por favor, corrija o formato dos links destacados antes de salvar.');
  });

  patrolTest('US15 — ISBN já cadastrado é recusado no próprio campo', ($) async {
    final api = await E2eApi.asAdmin();
    final digits = uniqIsbn();
    await api.book(isbn: formatIsbn(digits)); // mesmo formato que o campo do app produz

    await $.launchApp();
    await $.loginAsAdmin();
    await _openNewBookForm($);

    await $.typeKey('book_field_title', uniq('Obra ISBN repetido'), scroll: true);
    await $.typeKey('book_field_author', 'Autor E2E', scroll: true);
    await $.typeKey('book_field_isbn', digits, scroll: true);
    await $.tapText('Cadastrar Obra', scroll: true);

    await $.seeText('Este ISBN já está cadastrado em outra obra.');
  });

  patrolTest('US15 — editar uma obra reflete na busca e na página da obra', ($) async {
    final api = await E2eApi.asAdmin();
    final book = await api.book(title: uniq('Titulo Antigo'));
    final newTitle = uniq('Titulo Novo');

    await $.launchApp();
    await $.loginAsAdmin();
    await _openEdit($, book);

    await $.typeKey('book_field_title', newTitle, scroll: true);
    await _saveEdit($);

    // O título antigo deixa de existir na busca (o campo ainda tem o texto antigo)...
    await $.seeText('Nenhuma obra encontrada com esses filtros.');

    // ...e o novo aparece.
    await $.search('catalog_search', newTitle);
    await $.seeKey('book_edit_${book.id}');

    // Também na página da obra e na busca da API.
    expect((await api.catalog.getBook(book.id)).title, newTitle);
    expect((await api.catalog.listBooks(query: newTitle)).map((b) => b.id), contains(book.id));
  });

  // ===========================================================================
  // US16 — Cadastro de temas e escolaridades
  // ===========================================================================

  patrolTest('US16 — cadastra um tema e ele passa a existir', ($) async {
    final api = await E2eApi.asAdmin();
    final name = uniq('Tema novo');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Tema', scroll: true);

    await $.typeKey('theme_name_input', name);
    await $.tapKey('theme_submit');
    await $.seeText('Tema "$name" cadastrado com sucesso!');

    expect((await api.catalog.listThemes()).any((t) => t.name == name), isTrue);
  });

  patrolTest('US16 — não permite dois temas com o mesmo nome, mesmo mudando a caixa', ($) async {
    final api = await E2eApi.asAdmin();
    final existing = await api.theme('Tema duplicado');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Tema', scroll: true);

    await $.typeKey('theme_name_input', existing.name.toUpperCase());
    await $.tapKey('theme_submit');
    await $.seeText('Este tema já existe!');

    final same = (await api.catalog.listThemes())
        .where((t) => t.name.toLowerCase() == existing.name.toLowerCase());
    expect(same, hasLength(1));
  });

  patrolTest('US16 — renomear um tema preserva as obras vinculadas', ($) async {
    final api = await E2eApi.asAdmin();
    final theme = await api.theme('Tema renomear');
    final book = await api.book(themeIds: [theme.id]);
    final newName = uniq('Tema renomeado');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Tema', scroll: true);

    await $.tapKey('theme_edit_${theme.id}', scroll: true);
    await $.seeText('Renomear tema');
    await $.typeKey('rename_input', newName);
    await $.tapText('Salvar');
    await $.seeText('Tema renomeado para "$newName".');

    final detail = await api.catalog.getBook(book.id);
    expect(detail.themes.single.id, theme.id);
    expect(detail.themes.single.name, newName);
  });

  patrolTest('US16 — cadastra uma escolaridade e ela passa a existir', ($) async {
    final api = await E2eApi.asAdmin();
    final name = uniq('Escolaridade nova');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Escolaridade', scroll: true);

    await $.typeKey('level_name_input', name);
    await $.tapKey('level_submit');
    await $.seeText('Escolaridade "$name" cadastrada com sucesso!');

    expect((await api.catalog.listEducationLevels()).any((l) => l.name == name), isTrue);
  });

  patrolTest('US16 — não permite duas escolaridades com o mesmo nome', ($) async {
    final api = await E2eApi.asAdmin();
    final existing = await api.level('Nivel duplicado');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Escolaridade', scroll: true);

    await $.typeKey('level_name_input', existing.name.toUpperCase());
    await $.tapKey('level_submit');
    await $.seeText('Esta escolaridade já existe!');
  });

  patrolTest('US16 — renomear uma escolaridade preserva as obras vinculadas', ($) async {
    final api = await E2eApi.asAdmin();
    final level = await api.level('Nivel renomear');
    final book = await api.book(levelId: level.id);
    final newName = uniq('Nivel renomeado');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Escolaridade', scroll: true);

    await $.tapKey('level_edit_${level.id}', scroll: true);
    await $.seeText('Renomear escolaridade');
    await $.typeKey('rename_input', newName);
    await $.tapText('Salvar');
    await $.seeText('Escolaridade renomeada para "$newName".');

    final detail = await api.catalog.getBook(book.id);
    expect(detail.educationLevel?.id, level.id);
    expect(detail.educationLevel?.name, newName);
  });

  gapTest(
    'US16 — o tema é cadastrado com nome E descrição',
    'a tela de tema não tem campo de descrição (a API aceita)',
  );

  // ===========================================================================
  // US17 — Vínculo entre obra, temas e escolaridade
  // ===========================================================================

  patrolTest(
    'US17 — vincula vários temas e uma escolaridade; remover um vínculo mantém os demais',
        ($) async {
      final api = await E2eApi.asAdmin();
      final themeA = await api.theme('Tema A');
      final themeB = await api.theme('Tema B');
      final level = await api.level('Nivel');
      final book = await api.book(); // sem nenhum vínculo

      await $.launchApp();
      await $.loginAsAdmin();

      // 1) Vincula os dois temas e a escolaridade.
      await _openEdit($, book);
      await $.tapKey('book_picker_themes', scroll: true);
      await $.tapInList('theme_option_${themeA.id}');
      await $.tapInList('theme_option_${themeB.id}');
      await $.tapText('Aplicar');
      await $.tapKey('book_picker_level', scroll: true);
      await $.tapInList('level_option_${level.id}');
      await _saveEdit($);

      var detail = await api.catalog.getBook(book.id);
      expect(detail.themes.map((t) => t.id).toSet(), {themeA.id, themeB.id});
      expect(detail.educationLevel?.id, level.id);
      // A obra consta na busca de cada tema e da escolaridade.
      for (final themeId in [themeA.id, themeB.id]) {
        expect((await api.catalog.listBooks(themeId: themeId)).map((b) => b.id), contains(book.id));
      }
      expect(
        (await api.catalog.listBooks(educationLevelId: level.id)).map((b) => b.id),
        contains(book.id),
      );

      // 2) Remove o vínculo com o tema A: some dali, permanece no B.
      await _openEdit($, book);
      await $.tapKey('book_picker_themes', scroll: true);
      await $.tapInList('theme_option_${themeA.id}'); // desmarca
      await $.tapText('Aplicar');
      await _saveEdit($);

      detail = await api.catalog.getBook(book.id);
      expect(detail.themes.map((t) => t.id), [themeB.id]);
      expect(
        (await api.catalog.listBooks(themeId: themeA.id)).map((b) => b.id),
        isNot(contains(book.id)),
      );
      expect((await api.catalog.listBooks(themeId: themeB.id)).map((b) => b.id), contains(book.id));
    },
  );

  patrolTest(
    'US17 — obra sem tema nem escolaridade permanece cadastrada, mas não aparece nos filtros',
        ($) async {
      final api = await E2eApi.asAdmin();
      final theme = await api.theme('Tema');
      final book = await api.book(); // sem vínculos

      await $.launchApp();
      await $.loginAsAdmin();
      await $.tapText('Catálogo');

      // Está cadastrada: a busca por nome a acha.
      await $.search('catalog_search', book.title);
      await $.seeKey('book_edit_${book.id}');

      // Mas não aparece quando se filtra por um tema.
      await $.tapKey('catalog_filter_theme');
      await $.tapInList('pick_option_${theme.id}');
      await $.goneKey('book_edit_${book.id}');
    },
  );
}
