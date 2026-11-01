import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/book_models.dart';
import '../../data/services/catalog_api_service.dart';

/// Estado de "Minha Seleção" por id de obra, compartilhado entre catálogo,
/// detalhe e a própria seleção. Fica no topo do app e é limpo no logout.
class SavedBooksController extends ChangeNotifier {
  SavedBooksController(this._service);

  final CatalogApiService _service;

  final Map<int, bool> _saved = {};
  final Set<int> _pending = {};
  int _epoch = 0; // invalida operações em andamento quando a sessão é limpa
  bool _disposed = false;

  bool isSaved(int bookId) => _saved[bookId] ?? false;

  /// true enquanto a chamada ao servidor está em andamento (desabilitar o botão).
  bool isPending(int bookId) => _pending.contains(bookId);

  /// Registra o estado que veio do servidor (`is_saved` em GET /books,
  /// GET /books/{id} e GET /me/saved-books). Obras com operação em andamento
  /// são ignoradas, para a resposta atrasada de uma lista não desfazer o toque.
  void sync(Iterable<BookSummary> books) {
    var changed = false;
    for (final b in books) {
      if (_pending.contains(b.id)) continue;
      if (_saved[b.id] != b.isSaved) {
        _saved[b.id] = b.isSaved;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Alterna salvar/remover com atualização otimista.
  /// Devolve null em sucesso, ou a ApiException (o estado já foi revertido).
  /// PUT e DELETE são idempotentes: repetir após falha de rede é seguro.
  Future<ApiException?> toggle(int bookId) async {
    if (_pending.contains(bookId)) return null;

    final epoch = _epoch;
    final target = !isSaved(bookId);
    _pending.add(bookId);
    _saved[bookId] = target;
    notifyListeners();

    ApiException? failure;
    try {
      if (target) {
        await _service.saveBook(bookId);
      } else {
        await _service.unsaveBook(bookId);
      }
    } on ApiException catch (e) {
      failure = e;
    } catch (e, st) {
      debugPrint('Falha inesperada ao salvar/remover obra: $e\n$st');
      failure = ApiException.unexpected('$e');
    }

    if (epoch != _epoch) return failure; // sessão encerrada no meio: nada a atualizar
    _pending.remove(bookId);
    if (failure != null) _saved[bookId] = !target; // reverte
    notifyListeners();
    return failure;
  }

  /// Mensagem para exibir quando [toggle] falha.
  static String messageFor(ApiException e) => switch (e.code) {
    'NOT_FOUND' => 'Esta obra não está mais disponível.',
    'RATE_LIMITED' => 'Muitas tentativas. Aguarde um instante e tente de novo.',
    _ => e.message, // inclui NETWORK_ERROR e TIMEOUT
  };

  /// Chamar no logout.
  void clear() {
    _epoch++;
    _saved.clear();
    _pending.clear();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Marca obras como salvas (ex.: tudo que veio de GET /me/saved-books).
  void markSaved(Iterable<int> ids) {
    var changed = false;
    for (final id in ids) {
      if (_pending.contains(id)) continue;
      if (_saved[id] != true) {
        _saved[id] = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

}