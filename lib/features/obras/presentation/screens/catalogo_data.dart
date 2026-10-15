class CatalogoData {
  static List<String> escolaridades = [
    'Educação Infantil',
    'Ensino Fundamental I',
    'Ensino Fundamental II',
    'Ensino Médio',
  ];

  static List<String> temas = [
    'Aventura',
    'Mistério',
    'Ficção Científica',
    'Bullying',
    'Inclusão',
  ];

  static List<Map<String, dynamic>> livros = [
    {
      'title': 'O Mistério da Floresta',
      'author': 'Ana Silva',
      'escolaridades': ['Ensino Fundamental I', 'Ensino Fundamental II'],
      'temas': ['Aventura', 'Mistério'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'O Pequeno Príncipe',
      'author': 'Antoine de S.',
      'escolaridades': ['Ensino Fundamental II'],
      'temas': ['Ficção Científica'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Aventuras no Espaço',
      'author': 'Marcos',
      'escolaridades': ['Ensino Fundamental I'],
      'temas': ['Ficção Científica', 'Aventura'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Histórias de Ninar',
      'author': 'Clarice',
      'escolaridades': ['Educação Infantil'],
      'temas': ['Mistério', 'Inclusão'],
      'image': 'https://via.placeholder.com/150',
    },
  ];
}
