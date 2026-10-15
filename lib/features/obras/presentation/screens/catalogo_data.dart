class CatalogoData {
  static List<String> escolaridades = [
    'Educação Infantil',
    'Ensino Fundamental I',
    'Ensino Fundamental II',
    'Ensino Médio',
  ];

  static List<String> temas = [
    'Bullying',
    'Imaginação',
    'Higiene',
    'Alimentação',
    'Aventura',
    'Mistério',
    'Inclusão',
  ];

  static List<Map<String, dynamic>> livros = [
    {
      'title': 'O Segredo de Aurora',
      'author': 'Andréa Avelar',
      'ilustracoes': 'Rosy Albuquerque',
      'escolaridades': ['Educação Infantil', 'Ensino Fundamental I'],
      'temas': ['Imaginação', 'Inclusão'],
      'tags': ['INFANTIL', 'ARTE', 'DIVERSIDADE'],
      'sinopse':
          'Aurora ama dançar balé. Quando suas sapatilhas tocam o chão, tudo parece entrar no ritmo da alegria. Mas um segredo guardado quase tira dela a chance de subir ao palco. Com emoção e delicadeza, O Segredo de Aurora mostra que a arte existe para acolher, unir pessoas e fazer cada criança acreditar que também pode brilhar.',
      'isbn': '978-65-6079-046-9',
      'paginas': '38',
      'edicao': '1ª',
      'ano': '2026',
      'editora': 'Colli Books',
      'image': 'imagens/o_segredo_de_aurora.png',
      'storeUrl': 'https://www.collibooksloja.com/infantil/o-segredo-de-aurora',
      'lpUrl': 'https://www.collibooks.com/o-segredo-de-aurora-lp/',
      'disciplinas': [
        'Língua Portuguesa',
        'Artes',
        'Educação Física',
        'Desenvolvimento Socioemocional',
      ],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc':
              'Apresenta a obra, objetivos pedagógicos, temas, valores, ODS, possibilidades interdisciplinares, habilidades da BNCC e atividades.',
          'url':
              'https://www.collibooks.com/wp-content/uploads/2026/07/FICHA_O-SEGREDO-DE-AURORA.pdf',
        },
        {
          'title': 'Mediação de Leitura',
          'desc':
              'Propostas para antes, durante e depois da leitura, com caminhos para integração em sala.',
          'url':
              'https://www.collibooks.com/wp-content/uploads/2026/09/O_Segredo_de_Aurora_—_Mediacao_de_Leitura.pdf',
        },
        {
          'title': 'Manual do Professor',
          'desc':
              'Roteiro de apoio: sequência didática, mediação de leitura e integração interdisciplinar.',
          'url':
              'https://www.collibooks.com/wp-content/uploads/2026/09/Manual-do-professor_O-SEGREDO-DE-AURORA.pdf',
        },
        {
          'title': 'Atividades Imprimíveis',
          'desc':
              'Ficha de descobertas e mapa da expedição para os alunos registrarem o aprendizado.',
          'url':
              'https://www.collibooks.com/wp-content/uploads/2026/07/Atividades_Imprimiveis_Vivene_e_Florine.pdf',
        },
      ],
    },
    {
      'title': 'O Mistério da Floresta',
      'author': 'Isa Colli',
      'ilustracoes': 'Equipe Colli Books',
      'escolaridades': ['Ensino Fundamental I', 'Ensino Fundamental II'],
      'temas': ['Aventura', 'Mistério'],
      'tags': ['INFANTIL', 'AVENTURA'],
      'sinopse':
          'Uma aventura mágica que leva os pequenos leitores ao coração de uma floresta encantada. Quando dois amigos, Pedro e Sofia, descobrem um mapa antigo escondido no sótão de seus avós, eles embarcam em uma jornada para desvendar um segredo guardado há gerações pelas criaturas da mata. Repleto de lições sobre amizade, coragem e a importância de preservar a natureza, "O Mistério da Floresta" é uma obra que cativa a imaginação enquanto educa.',
      'isbn': '978-85-12345-67-8',
      'paginas': '48',
      'edicao': '1ª',
      'ano': '2023',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': [
        'Língua Portuguesa',
        'Ciências',
        'Educação Ambiental',
      ],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc':
              'Objetivos pedagógicos, habilidades da BNCC e atividades práticas sobre preservação ambiental.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
        {
          'title': 'Guia de Mediação de Leitura',
          'desc':
              'Roteiro de discussão em sala de aula e propostas para debate ecológico.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
    {
      'title': 'Aventuras na Matemática Vol. 1',
      'author': 'Maria Silva, João Santos',
      'escolaridades': ['Ensino Fundamental I'],
      'temas': ['Bullying', 'Imaginação'],
      'tags': ['DIDÁTICO', 'MATEMÁTICA'],
      'sinopse':
          'Uma jornada divertida pelo mundo dos números, estimulando o raciocínio lógico e a cooperação entre os alunos em sala de aula.',
      'isbn': '978-85-209-1234-1',
      'paginas': '84',
      'edicao': '2ª',
      'ano': '2023',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': ['Matemática', 'Língua Portuguesa'],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc': 'Jogos lógicos e desafios em grupo para sala de aula.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
    {
      'title': 'Caminhos da Leitura',
      'author': 'Ana Oliveira',
      'escolaridades': ['Ensino Fundamental I'],
      'temas': ['Imaginação', 'Bullying'],
      'tags': ['INFANTIL', 'LITERATURA'],
      'sinopse':
          'Contos e atividades pedagógicas dinâmicas para despertar o amor pela leitura e interpretação de texto.',
      'isbn': '978-85-209-5678-2',
      'paginas': '96',
      'edicao': '1ª',
      'ano': '2022',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': ['Língua Portuguesa', 'Artes'],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc': 'Propostas de escrita criativa e interpretação de texto.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
    {
      'title': 'Ciências: Descobertas e Aventuras',
      'author': 'Carlos Drummond',
      'escolaridades': ['Ensino Fundamental I'],
      'temas': ['Higiene', 'Alimentação'],
      'tags': ['CIÊNCIAS', 'SAÚDE'],
      'sinopse':
          'Explorações sobre o corpo humano, hábitos saudáveis e os mistérios da natureza para crianças curiosas.',
      'isbn': '978-85-209-9012-3',
      'paginas': '112',
      'edicao': '1ª',
      'ano': '2024',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': ['Ciências da Natureza', 'Educação Física'],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc': 'Experimentos práticos e guia de hábitos saudáveis.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
    {
      'title': 'Histórias de Ninar e Imaginação',
      'author': 'Clarice Lispector',
      'escolaridades': ['Educação Infantil'],
      'temas': ['Imaginação', 'Inclusão'],
      'tags': ['INFANTIL', 'POESIA'],
      'sinopse':
          'Narrativas poéticas para desenvolver a sensibilidade e imaginação na primeira infância.',
      'isbn': '978-85-209-3456-7',
      'paginas': '64',
      'edicao': '1ª',
      'ano': '2021',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': ['Língua Portuguesa', 'Artes'],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc': 'Roteiro de contação de histórias para a primeira infância.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
    {
      'title': 'O Pequeno Príncipe',
      'author': 'Antoine de Saint-Exupéry',
      'escolaridades': ['Ensino Fundamental II'],
      'temas': ['Aventura', 'Inclusão'],
      'tags': ['CLÁSSICO', 'AVENTURA'],
      'sinopse':
          'Uma fábula sobre a amizade, a empatia e o verdadeiro sentido das coisas que são invisíveis aos olhos.',
      'isbn': '978-85-209-7890-4',
      'paginas': '128',
      'edicao': '3ª',
      'ano': '2020',
      'editora': 'Colli Books',
      'image': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400&q=80',
      'storeUrl': 'https://www.collibooksloja.com/',
      'lpUrl': 'https://www.collibooks.com/editora/',
      'disciplinas': ['Língua Portuguesa', 'Filosofia'],
      'materiais': [
        {
          'title': 'Ficha Pedagógica',
          'desc': 'Debate sobre valores humanos e empatia.',
          'url': 'https://www.collibooks.com/pnld-2/',
        },
      ],
    },
  ];
}
