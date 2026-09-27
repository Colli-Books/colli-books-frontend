import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class FaleConoscoScreen extends StatelessWidget {
  const FaleConoscoScreen({super.key});

  // Função para tentar abrir um link
  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  // Função para copiar texto para a área de transferência
  void _copiarTexto(BuildContext context, String texto, String mensagemFeedback) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagemFeedback),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFA1A32D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);
    const accentColor = Color(0xFFA1A32D);
    const iconContainerColor = Color(0xFFF0EEDB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Colli Books',
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEBE8E0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Fale Conosco',
              style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entre em contato diretamente pelos nossos canais oficiais de\natendimento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // CARDS DE CONTATO
            _buildContactCard(
              icon: Icons.phone_outlined,
              iconBgColor: iconContainerColor,
              iconColor: accentColor,
              overline: 'TELEFONE',
              title: '+55 (61) 98212-7673',
              subtitle: 'Ligação direta com a editora',
              trailingIcon: Icons.copy,
              onTap: () => _copiarTexto(context, '+5561982127673', 'Número de telefone copiado!'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email_outlined,
              iconBgColor: iconContainerColor,
              iconColor: accentColor,
              overline: 'E-MAIL COMERCIAL',
              title: 'vendas@collibooks.com',
              subtitle: 'Envie propostas e orçamentos',
              trailingIcon: Icons.copy,
              onTap: () => _copiarTexto(context, 'vendas@collibooks.com', 'Endereço de e-mail copiado!'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.location_on_outlined,
              iconBgColor: iconContainerColor,
              iconColor: accentColor,
              overline: 'ENDEREÇO & SEDE',
              title: 'Led Office - Salas 804 a 806',
              subtitle: '210 Led Office, Torre B - Águas Claras, Brasília - DF, 71950-770',
              trailingIcon: Icons.open_in_new,
              onTap: () => _abrirLink('https://maps.app.goo.gl/MufZ1YXCwNMQZfxEA'),
            ),

            const SizedBox(height: 32),
            const Divider(color: Color(0xFFEBE8E0), thickness: 1),
            const SizedBox(height: 32),

            const Text(
              'CONECTE-SE NAS REDES SOCIAIS',
              style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),

            // REDES SOCIAIS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSocialCard(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  iconBgColor: iconContainerColor,
                  iconColor: accentColor,
                  onTap: () => _abrirLink('https://www.instagram.com/collibooks/'),
                ),
                _buildSocialCard(
                  icon: Icons.public,
                  label: 'Facebook',
                  iconBgColor: iconContainerColor,
                  iconColor: accentColor,
                  onTap: () => _abrirLink('https://www.facebook.com/collibooks/'),
                ),
                _buildSocialCard(
                  icon: Icons.play_circle_outline,
                  label: 'YouTube',
                  iconBgColor: iconContainerColor,
                  iconColor: accentColor,
                  onTap: () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                ),
                _buildSocialCard(
                  icon: Icons.work_outline,
                  label: 'LinkedIn',
                  iconBgColor: iconContainerColor,
                  iconColor: accentColor,
                  onTap: () => _abrirLink('https://www.linkedin.com/in/colli-books-editora-1090071a7/'),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // FOOTER
            const Text(
              'Colli Books Editora • Literatura Infantojuvenil',
              style: TextStyle(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Brasília - DF • Todos os direitos reservados',
              style: TextStyle(color: Color(0xFFB5ABA3), fontSize: 10, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String overline,
    required String title,
    required String subtitle,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE8E0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overline,
                        style: const TextStyle(color: Color(0xFFA1A32D), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(color: Color(0xFF331212), fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF8C7A70), fontSize: 12, fontWeight: FontWeight.w500, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trailingIcon, color: const Color(0xFFCAC5BB), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String label,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE8E0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Color(0xFF331212), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
