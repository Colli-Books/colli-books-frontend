import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/support.dart';

void main() {
  patrolTest(
    'Isolamento — a Seleção de um professor não aparece para outro no mesmo aparelho',
        ($) async {
      final api = await E2eApi.asAdmin();
      final fx = await CatalogFixture.seed(api);
      final teacherA = await api.createActiveTeacher(label: 'a');
      final teacherB = await api.createActiveTeacher(label: 'b');
      await api.saveBookFor(teacherA, fx.b1.id);

      // Professor A vê a sua obra salva.
      await $.launchApp();
      await $.loginAsTeacher(teacherA.email, teacherA.password);
      await $.tapText('Seleção');
      await $.seeText('Minha Seleção (1)');
      await $.seeKey('book_card_${fx.b1.id}');

      // Sai e entra o professor B no mesmo aparelho (sem reiniciar o processo).
      await $.logoutViaUi();
      await $.loginAsTeacher(teacherB.email, teacherB.password);
      await $.tapText('Seleção');

      await $.seeText('Sua Seleção está vazia');
      expect($.hasKey('book_card_${fx.b1.id}'), isFalse);

      // E o perfil mostra os dados de B, não os de A.
      await $.tapText('Perfil');
      await $.seeText(teacherB.name);
      expect($.hasText(teacherA.name), isFalse);
    },
  );

  patrolTest(
    'Sessão — o access token vencido é renovado sem o usuário perceber',
        ($) async {
      // Só roda com o backend de teste configurado com um access token CURTO
      // (E2E_ACCESS_TTL_SECONDS). Rode este teste sozinho: com TTL curto, o preparo
      // de dados dos outros testes também expiraria no meio.
      final api = await E2eApi.asAdmin();
      final fx = await CatalogFixture.seed(api);
      final teacher = await api.createActiveTeacher();
      await api.saveBookFor(teacher, fx.b1.id);

      await $.launchApp();
      await $.loginAsTeacher(teacher.email, teacher.password);
      await $.tapText('Seleção');
      await $.seeText('Minha Seleção (1)');
      await $.tapText('ColliBooks');

      // Espera o access token vencer (tempo real).
      await Future<void>.delayed(Duration(seconds: E2eEnv.accessTtlSeconds + 3));

      // Muda o estado no servidor, para a recarga PROVAR que a requisição funcionou
      // (se só reaproveitasse a lista antiga, o teste passaria sem testar nada).
      final api2 = await E2eApi.asAdmin(); // login novo: não depende do token vencido
      await api2.saveBookFor(teacher, fx.b2.id);

      // Voltar à aba dispara GET /me/saved-books com o token vencido → refresh → retry.
      await $.tapText('Seleção');
      await $.seeText('Minha Seleção (2)');
      expect($.hasKey('login_submit'), isFalse, reason: 'a sessão não pode ter caído');
    },
    skip: E2eEnv.accessTtlSeconds <= 0,
  );
}