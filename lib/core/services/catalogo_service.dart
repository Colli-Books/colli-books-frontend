import '../models/book.dart';

abstract class ICatalogoService {
  List<String> get escolaridades;
  List<String> get temas;
  List<Book> get books;

  Future<void> addEscolaridade(String value);
  Future<void> removeEscolaridade(String value);
  Future<void> addTema(String value);
  Future<void> removeTema(String value);
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> removeBook(String id);
}

class CatalogoService implements ICatalogoService {
  final List<String> _escolaridades = [
    'Educação Infantil',
    'Ensino Fundamental I',
    'Ensino Fundamental II',
    'Ensino Médio',
  ];

  final List<String> _temas = [
    'Aventura',
    'Mistério',
    'Ficção Científica',
    'Bullying',
    'Inclusão',
  ];

  final List<Book> _books = [
    Book(
      id: '1',
      title: 'O Mistério da Floresta',
      author: 'Ana Silva',
      escolaridades: ['Ensino Fundamental I', 'Ensino Fundamental II'],
      temas: ['Aventura', 'Mistério'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Book(
      id: '2',
      title: 'O Pequeno Príncipe',
      author: 'Antoine de S.',
      escolaridades: ['Ensino Fundamental II'],
      temas: ['Ficção Científica'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Book(
      id: '3',
      title: 'Harry Potter',
      author: 'J.K. Rowling',
      escolaridades: ['Ensino Fundamental II', 'Ensino Médio'],
      temas: ['Aventura'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Book(
      id: '4',
      title: 'Diário de um Banana',
      author: 'Jeff Kinney',
      escolaridades: ['Ensino Fundamental I'],
      temas: ['Aventura'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Book(
      id: '5',
      title: 'O Menino Maluquinho',
      author: 'Ziraldo',
      escolaridades: ['Educação Infantil', 'Ensino Fundamental I'],
      temas: ['Aventura'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Book(
      id: '6',
      title: 'Aventuras de Tintim',
      author: 'Hergé',
      escolaridades: ['Ensino Fundamental I', 'Ensino Fundamental II'],
      temas: ['Aventura'],
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  @override
  List<String> get escolaridades => List.unmodifiable(_escolaridades);

  @override
  List<String> get temas => List.unmodifiable(_temas);

  @override
  List<Book> get books => List.unmodifiable(_books);

  @override
  Future<void> addEscolaridade(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (_escolaridades.any((e) => e.toLowerCase() == trimmed.toLowerCase())) {
      throw Exception('Esta escolaridade já existe!');
    }
    _escolaridades.add(trimmed);
  }

  @override
  Future<void> removeEscolaridade(String value) async {
    _escolaridades.remove(value);
  }

  @override
  Future<void> addTema(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (_temas.any((e) => e.toLowerCase() == trimmed.toLowerCase())) {
      throw Exception('Este tema já existe!');
    }
    _temas.add(trimmed);
  }

  @override
  Future<void> removeTema(String value) async {
    _temas.remove(value);
  }

  @override
  Future<void> addBook(Book book) async {
    _books.add(book);
  }

  @override
  Future<void> updateBook(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _books[index] = book;
    }
  }

  @override
  Future<void> removeBook(String id) async {
    _books.removeWhere((b) => b.id == id);
  }
}