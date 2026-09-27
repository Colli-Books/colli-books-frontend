import 'package:flutter/material.dart';

class SobreNosScreen extends StatelessWidget {
  const SobreNosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const secondaryTextColor = Color(0xFF4A2525); 
    const cardColor = Color(0xFFFEFCF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Colli Books', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sobre Nós',
              style: TextStyle(color: primaryTextColor, fontSize: 36, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cultivando o amor pela leitura e o\nconhecimento desde a infância.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // Nossa História (Image Card)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/600x400/8D6E63/FFFFFF?text=Imagem+Nossa+História'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.menu_book, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text('Nossa História', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Anos de dedicação à literatura de\nqualidade.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nossa Missão
            _buildCardInfo(
              icon: Icons.flag_outlined,
              title: 'Nossa Missão',
              text: 'Publicar literatura infantojuvenil de alto valor pedagógico, promovendo o desenvolvimento cognitivo, a empatia e o pensamento crítico em jovens leitores através de histórias cativantes e materiais educativos de excelência.',
              cardColor: cardColor,
              primaryTextColor: primaryTextColor,
            ),
            const SizedBox(height: 24),

            // Nossa Visão
            _buildCardInfo(
              icon: Icons.visibility_outlined,
              title: 'Nossa Visão',
              text: 'Ser reconhecida nacionalmente como a principal referência em literatura infantojuvenil educativa, presente em escolas e lares de todo o país, transformando a educação através do poder transformador da leitura.',
              cardColor: cardColor,
              primaryTextColor: primaryTextColor,
            ),
            const SizedBox(height: 24),

            // Nossos Valores
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Nossos Valores', style: TextStyle(color: primaryTextColor, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  
                  _buildValorItem(
                    icon: Icons.school,
                    title: 'Excelência Pedagógica',
                    text: 'Conteúdos rigorosamente avaliados para garantir o melhor aprendizado.',
                    primaryTextColor: primaryTextColor,
                  ),
                  const SizedBox(height: 32),

                  _buildValorItem(
                    icon: Icons.people,
                    title: 'Inclusão',
                    text: 'Histórias que refletem a diversidade e promovem a empatia entre os leitores.',
                    primaryTextColor: primaryTextColor,
                  ),
                  const SizedBox(height: 32),

                  _buildValorItem(
                    icon: Icons.diamond,
                    title: 'Qualidade Editorial',
                    text: 'Cuidado em cada detalhe, desde o texto até o acabamento gráfico.',
                    primaryTextColor: primaryTextColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo({required IconData icon, required String title, required String text, required Color cardColor, required Color primaryTextColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryTextColor, size: 28),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: primaryTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildValorItem({required IconData icon, required String title, required String text, required Color primaryTextColor}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E2CE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFA1A32D), size: 32),
        ),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
