import 'package:colli_books_frontend/core/session/token_storage.dart';
import 'package:colli_books_frontend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'e2e_env.dart';

const _timeout = Duration(seconds: 20);

/// Camada única entre os testes e o Patrol.
///
/// Regra do desenho:
///   - AÇÕES (tap, enterText, openUrl) usam a API do Patrol (a rolagem usa o framework);
///   - ASSERÇÕES e ESPERAS usam só `flutter_test` (`find` + `evaluate()`) e `pump`.
/// Se uma versão do Patrol mudar um nome, o ajuste é aqui e só aqui.
///
/// Elementos são achados por `ValueKey<String>` (via Symbol, o jeito documentado do Patrol)
/// ou por texto.
extension E2eDriver on PatrolIntegrationTester {
  // ---------------------------------------------------------------------------
  // Ciclo de vida
  // ---------------------------------------------------------------------------

  /// Sobe o app do zero.
  ///  - [clearSession] true: apaga o refresh token antes (começa deslogado);
  ///    false: simula "fechar e reabrir o app" (a sessão salva é restaurada).
  ///  - [deepLinks] true só no teste que dispara `collibooks://` (evita reabrir convites antigos).
  Future<void> launchApp({bool clearSession = true, bool deepLinks = false}) async {
    E2eEnv.ensure();
    if (clearSession) await TokenStorage().clear();
    // Descarta a árvore anterior para o State novo (initState) realmente rodar.
    await pumpWidgetAndSettle(const SizedBox.shrink());
    await pumpWidgetAndSettle(ColliBooksRoot(enableDeepLinks: deepLinks));
  }

  // ---------------------------------------------------------------------------
  // Consultas (flutter_test puro: sem depender do Patrol)
  // ---------------------------------------------------------------------------

  bool hasText(String text) => find.text(text).evaluate().isNotEmpty;

  bool hasKey(String key) => find.byKey(ValueKey<String>(key)).evaluate().isNotEmpty;

  bool hasContaining(String part) => find.textContaining(part).evaluate().isNotEmpty;

  /// O widget com a chave [key] contém [text]? (ex.: o valor dentro de um cartão de contador)
  bool hasIn(String key, String text) => find
      .descendant(of: find.byKey(ValueKey<String>(key)), matching: find.text(text))
      .evaluate()
      .isNotEmpty;

  /// Texto de um `Text` identificado por chave.
  String textOfKey(String key) {
    final widget = find.byKey(ValueKey<String>(key)).evaluate().single.widget as Text;
    return widget.data ?? widget.textSpan?.toPlainText() ?? '';
  }

  /// O marcador do cartão da obra está no estado "salva"?
  bool savedMarkerOn(int bookId) => find
      .descendant(
    of: find.byKey(ValueKey<String>('book_save_$bookId')),
    matching: find.byIcon(Icons.bookmark),
  )
      .evaluate()
      .isNotEmpty;

  // ---------------------------------------------------------------------------
  // Esperas
  // ---------------------------------------------------------------------------

  /// Espera [condition] ficar verdadeira (o backend é real: nada acontece instantaneamente).
  Future<void> waitFor(
      bool Function() condition,
      String reason, {
        Duration timeout = _timeout,
      }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) fail('Tempo esgotado esperando: $reason');
      await pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> seeText(String text, {Duration timeout = _timeout}) =>
      waitFor(() => hasText(text), 'texto "$text"', timeout: timeout);

  Future<void> seeKey(String key, {Duration timeout = _timeout}) =>
      waitFor(() => hasKey(key), 'elemento com chave "$key"', timeout: timeout);

  Future<void> goneText(String text, {Duration timeout = _timeout}) =>
      waitFor(() => !hasText(text), 'sumir o texto "$text"', timeout: timeout);

  Future<void> goneKey(String key, {Duration timeout = _timeout}) =>
      waitFor(() => !hasKey(key), 'sumir o elemento "$key"', timeout: timeout);

  // ---------------------------------------------------------------------------
  // Ações (Patrol)
  // ---------------------------------------------------------------------------

  PatrolFinder byKey(String key) => this(Symbol(key));

  /// Rola, pelo próprio framework, até o widget ficar visível (hit-testable).
  ///
  /// Num elemento que existe mas está fora da tela (abaixo da dobra de um scroll), o toque
  /// do Patrol esgota o tempo ("did not find any visible widgets"). `Scrollable.ensureVisible`
  /// sobe pela árvore até o scroll mais próximo e o posiciona, sem depender de gestos:
  /// funciona em celulares e em janelas pequenas do Chrome, e é no-op quando o widget
  /// não está dentro de nenhum scroll (ex.: botões de diálogo).
  Future<void> _reveal(Finder finder) async {
    final elements = finder.evaluate();
    if (elements.isEmpty) return;
    await Scrollable.ensureVisible(
      elements.first,
      alignment: 0.5,
      duration: Duration.zero,
    );
    await pump(const Duration(milliseconds: 100));
  }

  /// [scroll] (padrão true): traz o elemento para a tela antes de tocar.
  Future<void> tapText(String text, {bool scroll = true}) async {
    await seeText(text);
    if (scroll) await _reveal(find.text(text));
    await this(text).tap();
  }

  Future<void> tapKey(String key, {bool scroll = true}) async {
    await seeKey(key);
    if (scroll) await _reveal(find.byKey(ValueKey<String>(key)));
    await byKey(key).tap();
  }

  Future<void> tapIcon(IconData icon) async {
    await waitFor(() => find.byIcon(icon).evaluate().isNotEmpty, 'ícone $icon');
    await _reveal(find.byIcon(icon));
    await this(icon).tap();
  }

  Future<void> typeKey(String key, String text, {bool scroll = true}) async {
    await seeKey(key);
    if (scroll) await _reveal(find.byKey(ValueKey<String>(key)));
    await byKey(key).enterText(text);
  }

  /// Espera as requisições em andamento terminarem: nenhum indicador de progresso na tela.
  /// O primeiro `pump` cobre o debounce de 400 ms das buscas.
  Future<void> waitForLoaded({Duration timeout = _timeout}) async {
    await pump(const Duration(milliseconds: 500));
    await waitFor(
          () =>
      find.byType(LinearProgressIndicator).evaluate().isEmpty &&
          find.byType(CircularProgressIndicator).evaluate().isEmpty,
      'terminar o carregamento',
      timeout: timeout,
    );
  }

  /// Digita num campo de busca e espera o resultado chegar do servidor.
  Future<void> search(String key, String text) async {
    await typeKey(key, text);
    await waitForLoaded();
  }

  /// Escolhe um item numa lista dentro de um diálogo (que pode ter mais itens que a tela):
  /// rola a lista até a chave aparecer e toca.
  Future<void> tapInList(String key) async {
    for (var i = 0; i < 80 && !hasKey(key); i++) {
      final scrollables = find.byType(Scrollable).evaluate();
      if (scrollables.isEmpty) break;
      // O diálogo é a rota mais recente: o último Scrollable da árvore é o da lista dele.
      final state = (scrollables.last as StatefulElement).state as ScrollableState;
      final position = state.position;
      if (position.pixels >= position.maxScrollExtent) break;
      position.jumpTo((position.pixels + 240).clamp(0.0, position.maxScrollExtent));
      await pump(const Duration(milliseconds: 150));
    }
    await tapKey(key);
  }

  /// Volta uma tela, do jeito que o usuário faria (e, se não achar o botão, pelo Navigator).
  Future<void> goBack() async {
    if (hasText('Voltar')) {
      await this('Voltar').first.tap(); // pode haver mais de um "Voltar" na tela
    } else if (find.byType(BackButton).evaluate().isNotEmpty) {
      await this(BackButton).tap();
    } else if (find.byIcon(Icons.arrow_back_ios_new_rounded).evaluate().isNotEmpty) {
      await this(Icons.arrow_back_ios_new_rounded).tap();
    } else {
      final nav = (find.byType(Navigator).evaluate().first as StatefulElement).state
      as NavigatorState;
      nav.pop();
      await pumpAndSettle();
    }
  }

  /// Abre o menu lateral (ícone de hambúrguer).
  Future<void> openDrawer() => tapIcon(Icons.menu);

  // ---------------------------------------------------------------------------
  // Fluxos compostos
  // ---------------------------------------------------------------------------

  Future<void> loginViaUi(String email, String password) async {
    await seeKey('login_submit');
    await typeKey('login_email', email);
    await typeKey('login_password', password);
    await tapKey('login_submit');
  }

  Future<void> loginAsAdmin() async {
    await loginViaUi(E2eEnv.adminEmail, E2eEnv.adminPassword);
    await seeText('Visão Geral');
  }

  Future<void> loginAsTeacher(String email, String password) async {
    await loginViaUi(email, password);
    await seeKey('catalog_search');
  }

  /// Aba Perfil → Sair → confirmar. Vale para admin e professor.
  Future<void> logoutViaUi() async {
    await tapText('Perfil');
    await tapKey('profile_logout');
    await tapKey('logout_confirm');
    await seeKey('login_submit');
  }

  // ---------------------------------------------------------------------------
  // Sistema operacional (Patrol)
  // ---------------------------------------------------------------------------

  /// Dispara um deep link de verdade pelo sistema.
  /// Patrol 4.x: `platform.mobile`. Em versões 3.x, o equivalente é `native.openUrl(url)`.
  /// No iOS o sistema pode pedir confirmação antes de abrir o app.
  Future<void> openDeepLink(String url) => platform.mobile.openUrl(url);
}

/// Registra, como PULADO, um teste que descreve uma exigência da US que o app ainda não atende.
/// O motivo aparece no nome, então a lacuna fica visível no relatório.
void gapTest(String name, String reason) {
  patrolTest('$name [LACUNA: $reason]', ($) async {}, skip: true);
}
