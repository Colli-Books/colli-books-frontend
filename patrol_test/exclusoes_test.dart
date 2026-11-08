import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

void main() {
  // ===========================================================================
  // Obra
  // ===========================================================================

  patrolTest('Exclusão — admin exclui uma obra: some do acervo e da Minha Seleção', ($) async {
    final api = await E2eApi.asAdmin();
    final book = await api.book();
    final teacher = await api.createActiveTeacher();
    await api.saveBookFor(teacher, book.id);

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.search('catalog_search', book.title);

    await $.tapKey('book_delete_${book.id}');
    await $.seeText('Excluir obra');
    await $.tapKey('confirm_delete');

    await $.seeText('Obra "${book.title}" excluída.');
    await $.goneKey('book_edit_${book.id}');

    expect((await api.bookError(book.id))?.code, 'NOT_FOUND');
    expect(await api.savedBookIdsOf(teacher), isNot(contains(book.id)));
  });

  patrolTest('Exclusão — cancelar a confirmação não exclui a obra', ($) async {
    final api = await E2eApi.asAdmin();
    final book = await api.book();

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.search('catalog_search', book.title);

    await $.tapKey('book_delete_${book.id}');
    await $.seeText('Excluir obra');
    await $.tapText('Cancelar');
    await $.goneText('Excluir obra');

    expect($.hasKey('book_edit_${book.id}'), isTrue);
    expect(await api.bookError(book.id), isNull);
  });

  // ===========================================================================
  // Tema
  // ===========================================================================

  patrolTest('Exclusão — admin exclui um tema: as obras permanecem, sem o tema', ($) async {
    final api = await E2eApi.asAdmin();
    final theme = await api.theme('Tema excluir');
    final book = await api.book(themeIds: [theme.id]);

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Tema');

    await $.tapKey('theme_delete_${theme.id}');
    await $.seeText('Excluir tema');
    // A confirmação diz quantas obras são afetadas.
    expect($.hasContaining('1 obra usa este tema'), isTrue);
    await $.tapKey('confirm_delete');

    await $.seeText('Tema "${theme.name}" excluído.');
    await $.goneKey('theme_delete_${theme.id}');

    expect((await api.catalog.listThemes()).any((t) => t.id == theme.id), isFalse);
    final detail = await api.catalog.getBook(book.id); // a obra continua cadastrada
    expect(detail.themes, isEmpty);
  });

  // ===========================================================================
  // Escolaridade
  // ===========================================================================

  patrolTest('Exclusão — admin exclui uma escolaridade: as obras permanecem, sem ela', ($) async {
    final api = await E2eApi.asAdmin();
    final level = await api.level('Nivel excluir');
    final book = await api.book(levelId: level.id);

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Catálogo');
    await $.tapText('Adicionar Escolaridade');

    await $.tapKey('level_delete_${level.id}');
    await $.seeText('Excluir escolaridade');
    expect($.hasContaining('1 obra usa esta escolaridade'), isTrue);
    await $.tapKey('confirm_delete');

    await $.seeText('Escolaridade "${level.name}" excluída.');
    await $.goneKey('level_delete_${level.id}');

    expect((await api.catalog.listEducationLevels()).any((l) => l.id == level.id), isFalse);
    final detail = await api.catalog.getBook(book.id);
    expect(detail.educationLevel, isNull);
  });

  // ===========================================================================
  // Professor
  // ===========================================================================

  patrolTest('Exclusão — admin cancela um convite pendente: o código deixa de valer', ($) async {
    final api = await E2eApi.asAdmin();
    final email = uniqEmail('excluir-pendente');
    final invite = await api.admin.createTeacher(email);

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Professores');
    await $.search('teachers_search', email);

    await $.tapKey('teacher_delete_${invite.id}');
    await $.seeText('Excluir professor');
    await $.tapKey('confirm_delete');

    await $.seeText('Professor excluído.');
    await $.goneKey('teacher_delete_${invite.id}');

    expect(await api.teacherByEmail(email), isNull);
    expect(await E2eApi.verifyInvite(invite.inviteCode), isNotNull); // convite não vale mais
  });

  patrolTest('Exclusão — admin exclui um professor ativo: ele perde o acesso', ($) async {
    final api = await E2eApi.asAdmin();
    final teacher = await api.createActiveTeacher(label: 'excluir-ativo');

    await $.launchApp();
    await $.loginAsAdmin();
    await $.tapText('Professores');
    await $.search('teachers_search', teacher.email);

    await $.tapKey('teacher_delete_${teacher.id}');
    await $.seeText('Excluir professor');
    await $.tapKey('confirm_delete');
    await $.seeText('Professor excluído.');
    await $.goneKey('teacher_delete_${teacher.id}');

    expect(await api.teacherByEmail(teacher.email), isNull);

    // E não consegue mais entrar.
    await $.logoutViaUi();
    await $.loginViaUi(teacher.email, teacher.password);
    await $.seeText('E-mail ou senha incorretos.');
  });
}