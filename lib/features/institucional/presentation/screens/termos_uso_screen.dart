import 'package:flutter/material.dart';

class TermosUsoScreen extends StatelessWidget {
  const TermosUsoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const bodyTextColor = Color(0xFF4D4D4D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Colli Books',
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Termos de Uso',
                style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFEBE8E0), height: 1),
              const SizedBox(height: 32),
              
              _buildSectionTitle('1. Aceitação dos Termos', primaryTextColor),
              _buildParagraph('Ao acessar e utilizar a plataforma educacional Colli Books, você concorda em cumprir e ficar vinculado aos seguintes termos e condições de uso. Se você não concordar com qualquer parte destes termos, não deverá utilizar nossos serviços.', bodyTextColor),

              _buildSectionTitle('2. Uso da Plataforma', primaryTextColor),
              _buildParagraph('A plataforma destina-se a fins educacionais e de leitura. Você concorda em usar a plataforma apenas para fins legais e de maneira que não infrinja os direitos de, ou restrinja ou iniba o uso e aproveitamento da plataforma por qualquer terceiro.', bodyTextColor),
              _buildListParagraph('É proibido o uso da plataforma para assédio, abuso ou qualquer forma de comportamento prejudicial a outros usuários.', bodyTextColor),
              _buildListParagraph('A reprodução, distribuição ou modificação não autorizada de qualquer conteúdo protegido por direitos autorais é estritamente proibida.', bodyTextColor),

              _buildSectionTitle('3. Propriedade Intelectual', primaryTextColor),
              _buildParagraph('Todo o conteúdo incluído na plataforma, como textos, gráficos, logotipos, ícones de botões, imagens, clipes de áudio, downloads digitais, compilações de dados e software, é propriedade da Colli Books ou de seus fornecedores de conteúdo e é protegido por leis internacionais de direitos autorais.', bodyTextColor),

              _buildSectionTitle('4. Limitação de Responsabilidade', primaryTextColor),
              _buildParagraph('A Colli Books não será responsável por quaisquer danos diretos, indiretos, incidentais, especiais ou consequentes resultantes do uso ou da incapacidade de usar a plataforma, incluindo, mas não se limitando a, confiança em qualquer informação obtida na plataforma.', bodyTextColor),

              _buildSectionTitle('5. Modificações dos Termos', primaryTextColor),
              _buildParagraph('A Colli Books reserva-se o direito de revisar estes termos de uso a qualquer momento sem aviso prévio. Ao usar esta plataforma, você concorda em ficar vinculado à versão atual destes termos e condições.', bodyTextColor),

              const SizedBox(height: 48),
              const Divider(color: Color(0xFFEBE8E0), height: 1),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Última atualização: 15 de Outubro de 2023',
                  style: TextStyle(color: Color(0xFF8C7A70), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildParagraph(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 16, height: 1.6),
      ),
    );
  }

  Widget _buildListParagraph(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 16, height: 1.6),
      ),
    );
  }
}
