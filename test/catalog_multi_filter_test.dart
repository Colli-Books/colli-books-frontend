import 'dart:convert';

import 'package:colli_books_frontend/core/network/api_client.dart';
import 'package:colli_books_frontend/core/widgets/pick_many_dialog.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/book_form.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/book_models.dart';
import 'package:colli_books_frontend/features/catalogo/data/services/catalog_api_service.dart';
import 'package:colli_books_frontend/features/catalogo/presentation/controllers/books_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _bookJson({Object? levels, Object? legacyLevel}) => {
  'id': 7,
  'title': 'Obra',
  'author': 'Autora',
  'themes': [
    {'id': 1, 'name': 'Inclusão'},
  ],
  'education_levels': ?levels,
  'education_level': ?legacyLevel,
  'is_saved': false,
  'created_at': '2026-11-11T10:00:00Z',
  'updated_at': '2026-11-11T10:00:00Z',
};

/// Serviço real sobre um http falso que registra cada requisição.
(CatalogApiService, List<http.BaseRequest>) _service({
  Object response = const [],
}) {
  final requests = <http.BaseRequest>[];
  final client = MockClient((request) async {
    requests.add(request);
    return http.Response(
      jsonEncode(response),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final api = ApiClient(
    baseUrl: 'http://localhost:8000/api/v1',
    client: client,
  );
  return (CatalogApiService(api), requests);
}

void main() {
  group('BookSummary.fromJson — escolaridades', () {
    test('lê a lista education_levels', () {
      final book = BookSummary.fromJson(
        _bookJson(
          levels: [
            {'id': 2, 'name': 'Fundamental I'},
            {'id': 3, 'name': 'Fundamental II'},
          ],
        ),
      );
      expect(book.educationLevels.map((l) => l.name), [
        'Fundamental I',
        'Fundamental II',
      ]);
    });

    test('aceita backend antigo com education_level único', () {
      final book = BookSummary.fromJson(
        _bookJson(legacyLevel: {'id': 2, 'name': 'Infantil'}),
      );
      expect(book.educationLevels.map((l) => l.id), [2]);
    });

    test('sem escolaridade vira lista vazia', () {
      expect(BookSummary.fromJson(_bookJson()).educationLevels, isEmpty);
    });
  });

  group('CatalogApiService.listBooks — filtros múltiplos', () {
    test('repete theme_ids e education_level_ids na query', () async {
      final (service, requests) = _service();

      await service.listBooks(themeIds: [1, 2], educationLevelIds: [3]);

      final url = requests.single.url;
      expect(url.queryParametersAll['theme_ids'], ['1', '2']);
      expect(url.queryParametersAll['education_level_ids'], ['3']);
    });

    test('sem filtro não envia os parâmetros', () async {
      final (service, requests) = _service();

      await service.listBooks();

      final params = requests.single.url.queryParametersAll;
      expect(params.containsKey('theme_ids'), isFalse);
      expect(params.containsKey('education_level_ids'), isFalse);
    });
  });

  group('CatalogApiService.updateBook — escolaridades', () {
    Future<String> sentBody(BookForm form) async {
      final (service, requests) = _service(
        response: _bookJson(levels: const []),
      );
      await service.updateBook(7, form);
      final request = requests.single as http.Request;
      return request.body;
    }

    int countField(String body, String name) =>
        'name="$name"'.allMatches(body).length;

    test('envia cada escolaridade como campo repetido', () async {
      final body = await sentBody(
        const BookForm(
          title: 'T',
          author: 'A',
          educationLevelIds: [2, 3],
          themeIds: [1],
        ),
      );
      expect(countField(body, 'education_level_ids'), 2);
      expect(countField(body, 'education_level_id'), 0);
    });

    test('lista vazia envia education_level_ids= para limpar', () async {
      final body = await sentBody(const BookForm(title: 'T', author: 'A'));
      expect(countField(body, 'education_level_ids'), 1);
      expect(countField(body, 'theme_ids'), 1);
    });
  });

  group('BooksController — filtros múltiplos', () {
    test('setThemes/setLevels recarregam com os ids; o mesmo conjunto não recarrega', () async {
      final (service, requests) = _service();
      final controller = BooksController(service);
      addTearDown(controller.dispose);

      controller.setThemes({1, 2});
      await pumpEventQueue();
      controller.setLevels({3});
      await pumpEventQueue();
      controller.setThemes({2, 1});
      await pumpEventQueue();

      expect(requests, hasLength(2));
      expect(
        requests.last.url.queryParametersAll['theme_ids'],
        unorderedEquals(['1', '2']),
      );
      expect(requests.last.url.queryParametersAll['education_level_ids'], [
        '3',
      ]);
      expect(controller.hasFilters, isTrue);

      controller.setThemes({});
      controller.setLevels({});
      await pumpEventQueue();
      expect(controller.hasFilters, isFalse);
    });
  });

  group('showPickManyDialog', () {
    /// Abre o diálogo e devolve um leitor do resultado (lido depois de fechar).
    Future<({Set<int>? value, bool closed}) Function()> open(
      WidgetTester tester, {
      Set<int> selected = const {},
    }) async {
      Set<int>? value;
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                value = await showPickManyDialog(
                  context,
                  title: 'Filtrar',
                  emptyMessage: 'Nada',
                  options: const [
                    (id: 1, name: 'Um'),
                    (id: 2, name: 'Dois'),
                    (id: 3, name: 'Três'),
                  ],
                  selectedIds: selected,
                );
                closed = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return () => (value: value, closed: closed);
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }

    testWidgets('marca várias opções e devolve o conjunto ao aplicar', (
      tester,
    ) async {
      final read = await open(tester, selected: {2});

      await tapKey(tester, 'pick_many_option_1');
      await tapKey(tester, 'pick_many_option_3');
      await tapKey(tester, 'pick_many_apply');

      final r = read();
      expect(r.closed, isTrue);
      expect(r.value, {1, 2, 3});
    });

    testWidgets('desmarcar remove a opção do conjunto', (tester) async {
      final read = await open(tester, selected: {1, 2});

      await tapKey(tester, 'pick_many_option_1');
      await tapKey(tester, 'pick_many_apply');

      expect(read().value, {2});
    });

    testWidgets('Limpar desmarca tudo e aplicar devolve conjunto vazio', (
      tester,
    ) async {
      final read = await open(tester, selected: {1, 2});

      await tapKey(tester, 'pick_many_clear');
      await tapKey(tester, 'pick_many_apply');

      final r = read();
      expect(r.closed, isTrue);
      expect(r.value, isEmpty);
    });

    testWidgets('Cancelar devolve null', (tester) async {
      final read = await open(tester, selected: {1});

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      final r = read();
      expect(r.closed, isTrue);
      expect(r.value, isNull);
    });
  });
}
