class Book {
  final String id;
  final String title;
  final String author;
  final String? publisher;
  final String? isbn;
  final int? year;
  final int? pages;
  final String? synopsis;
  final String? imageUrl;
  final List<String> escolaridades;
  final List<String> temas;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.isbn,
    this.year,
    this.pages,
    this.synopsis,
    this.imageUrl,
    this.escolaridades = const [],
    this.temas = const [],
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      publisher: map['publisher'] as String?,
      isbn: map['isbn'] as String?,
      year: map['year'] as int?,
      pages: map['pages'] as int?,
      synopsis: map['synopsis'] as String?,
      imageUrl: map['image'] as String? ?? map['imageUrl'] as String?,
      escolaridades: (map['escolaridades'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      temas: (map['temas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'isbn': isbn,
      'year': year,
      'pages': pages,
      'synopsis': synopsis,
      'image': imageUrl,
      'escolaridades': escolaridades,
      'temas': temas,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? publisher,
    String? isbn,
    int? year,
    int? pages,
    String? synopsis,
    String? imageUrl,
    List<String>? escolaridades,
    List<String>? temas,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      isbn: isbn ?? this.isbn,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      escolaridades: escolaridades ?? this.escolaridades,
      temas: temas ?? this.temas,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';
}

class Professor {
  final String id;
  final String name;
  final String email;
  final String school;
  final String status;
  final String joinDate;
  final String initials;

  Professor({
    required this.id,
    required this.name,
    required this.email,
    required this.school,
    required this.status,
    required this.joinDate,
    required this.initials,
  });

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'] as String? ?? '',
      name: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      school: map['escola'] as String? ?? '',
      status: map['status'] as String? ?? '',
      joinDate: map['data'] as String? ?? '',
      initials: map['iniciais'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': name,
      'email': email,
      'escola': school,
      'status': status,
      'data': joinDate,
      'iniciais': initials,
    };
  }
}