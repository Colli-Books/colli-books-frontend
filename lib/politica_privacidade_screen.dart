import 'package:flutter/material.dart';

class PoliticaPrivacidadeScreen extends StatelessWidget {
  const PoliticaPrivacidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const bodyTextColor = Color(0xFF4D4D4D);
    const cardColor = Color(0xFFF3EFE4);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Política de Privacidade',
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
                'Compromisso com sua Privacidade',
                style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              _buildParagraph('A Colli Books valoriza a sua privacidade e está comprometida em proteger os seus dados pessoais. Esta Política de Privacidade explica como coletamos, usamos, compartilhamos e protegemos suas informações quando você utiliza nossa plataforma educacional.', bodyTextColor),
              _buildParagraph('Esta política foi elaborada em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018) e reflete nosso compromisso com a transparência e a segurança no ambiente digital.', bodyTextColor),

              _buildSectionTitle('1. Dados que Coletamos', primaryTextColor),
              _buildInfoCard(
                'Dados de Cadastro',
                'Nome completo, endereço de e-mail, instituição de ensino e informações profissionais necessárias para a criação da sua conta e acesso aos recursos da plataforma.',
                cardColor,
                primaryTextColor,
                bodyTextColor,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Dados de Uso e Interação',
                'Informações sobre como você interage com nossos livros, catálogos e turmas, incluindo tempo de leitura, páginas acessadas e atividades concluídas, essenciais para personalizar sua experiência de aprendizado.',
                cardColor,
                primaryTextColor,
                bodyTextColor,
              ),

              _buildSectionTitle('2. Como Protegemos Seus Dados', primaryTextColor),
              _buildParagraph('Implementamos medidas técnicas e organizacionais rigorosas para garantir a segurança dos seus dados contra acessos não autorizados, perdas, destruição ou alterações. Utilizamos criptografia de ponta a ponta e protocolos de segurança avançados para proteger as informações transitadas em nossa plataforma.', bodyTextColor),
              _buildListParagraph('Controle de acesso estrito aos bancos de dados.', bodyTextColor),
              _buildListParagraph('Criptografia de dados sensíveis em repouso e em trânsito.', bodyTextColor),
              _buildListParagraph('Auditorias de segurança regulares.', bodyTextColor),

              _buildSectionTitle('3. Seus Direitos (LGPD)', primaryTextColor),
              _buildParagraph('De acordo com a LGPD, você possui diversos direitos em relação aos seus dados pessoais, incluindo:', bodyTextColor),
              _buildRightCard(Icons.check_circle_outline, 'Confirmação da existência de tratamento.', cardColor, primaryTextColor),
              _buildRightCard(Icons.visibility_outlined, 'Acesso facilitado aos seus dados.', cardColor, primaryTextColor),
              _buildRightCard(Icons.edit_outlined, 'Correção de dados incompletos ou desatualizados.', cardColor, primaryTextColor),
              _buildRightCard(Icons.delete_outline, 'Eliminação dos dados tratados com seu consentimento.', cardColor, primaryTextColor),

              _buildSectionTitle('4. Contato', primaryTextColor),
              _buildParagraph('Se você tiver dúvidas, solicitações ou preocupações relacionadas à sua privacidade ou a esta política, entre em contato com nosso Encarregado pelo Tratamento de Dados Pessoais (DPO):', bodyTextColor),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Email: atendimento@collibooks.com',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
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
      padding: const EdgeInsets.only(bottom: 16.0, top: 32.0),
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

  Widget _buildInfoCard(String title, String text, Color bgColor, Color titleColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: textColor, fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildRightCard(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBE8E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D8E9E), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
