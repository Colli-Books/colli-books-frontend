import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FaleConoscoScreen extends StatelessWidget {
  const FaleConoscoScreen({super.key});

  static const Color _bgColor = Color(0xFFF9F5EC);
  static const Color _primaryTextColor = Color(0xFF4A2525);
  static const Color _secondaryTextColor = Color(0xFF7A6B63);
  static const Color _borderColor = Color(0xFFE2DDD5);
  static const Color _tagColor = Color(0xFF6B8E23);

  static const String _mapsUrl =
      'https://www.google.com/maps?cid=16142510610135156578&g_mp=CiVnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLkdldFBsYWNlEAMYASAF';

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Colli Books',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cabeçalho
              const Text(
                'Fale Conosco',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Entre em contato diretamente pelos nossos canais oficiais de atendimento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card 1: WhatsApp Oficial
              _buildContactCard(
                category: 'WHATSAPP OFICIAL',
                title: '(61) 98212-7673',
                subtitle: 'Atendimento rápido comercial',
                icon: FontAwesomeIcons.whatsapp,
                iconColor: const Color(0xFF25D366),
                iconBgColor: const Color(0xFFE8F5E9),
                trailingIcon: Icons.open_in_new_rounded,
                onTap: () => _abrirLink('https://wa.me/5561982127673'),
              ),
              const SizedBox(height: 12),

              // Card 2: Telefone
              _buildContactCard(
                category: 'TELEFONE',
                title: '+55 (61) 98212-7673',
                subtitle: 'Ligação direta com a editora',
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFF1F8E9),
                trailingIcon: Icons.arrow_outward_rounded,
                onTap: () => _abrirLink('tel:+5561982127673'),
              ),
              const SizedBox(height: 12),

              // Card 3: E-mail Comercial
              _buildContactCard(
                category: 'E-MAIL COMERCIAL',
                title: 'vendas@collibooks.com',
                subtitle: 'Envie propostas e orçamentos',
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFFC07020),
                iconBgColor: const Color(0xFFFFF3E0),
                trailingIcon: Icons.send_outlined,
                onTap: () => _abrirLink('mailto:vendas@collibooks.com'),
              ),
              const SizedBox(height: 12),

              // Card 4: Endereço & Sede (Google Maps)
              _buildContactCard(
                category: 'ENDEREÇO & SEDE',
                title: 'Led Office - Salas 804 a 806',
                subtitle: '210 Led Office, Torre B - Águas Claras, Brasília - DF, 71950-770',
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFFD32F2F),
                iconBgColor: const Color(0xFFFFEBEE),
                trailingIcon: Icons.directions_outlined,
                onTap: () => _abrirLink(_mapsUrl),
              ),

              const SizedBox(height: 28),
              const Divider(color: Color(0xFFEAE5DA), thickness: 1),
              const SizedBox(height: 18),

              // Redes Sociais
              const Text(
                'CONECTE-SE NAS REDES SOCIAIS',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  _buildSocialCard(
                    icon: FontAwesomeIcons.instagram,
                    label: 'Instagram',
                    brandColor: const Color(0xFFE1306C),
                    onTap: () => _abrirLink('https://www.instagram.com/collibooks/'),
                  ),
                  const SizedBox(width: 8),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.facebook,
                    label: 'Facebook',
                    brandColor: const Color(0xFF1877F2),
                    onTap: () => _abrirLink('https://www.facebook.com/collibooks/'),
                  ),
                  const SizedBox(width: 8),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.youtube,
                    label: 'YouTube',
                    brandColor: const Color(0xFFCD201F),
                    onTap: () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                  ),
                  const SizedBox(width: 8),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.linkedin,
                    label: 'LinkedIn',
                    brandColor: const Color(0xFF0077B5),
                    onTap: () => _abrirLink('https://www.linkedin.com/company/collibooks/'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Rodapé institucional
              const Text(
                'Colli Books Editora • Literatura Infantojuvenil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Brasília - DF • Todos os direitos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA89A91),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String category,
    required String title,
    required String subtitle,
    required dynamic icon,
    required Color iconColor,
    required Color iconBgColor,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone com fundo suave
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: icon is IconData
                        ? Icon(icon, color: iconColor, size: 24)
                        : FaIcon(icon as FaIconData, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(width: 14),

                // Conteúdo central
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: _tagColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          color: _primaryTextColor,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Ação na direita
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F5EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    trailingIcon,
                    color: const Color(0xFF8D6E63),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialCard({
    required FaIconData icon,
    required String label,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(icon, color: brandColor, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
