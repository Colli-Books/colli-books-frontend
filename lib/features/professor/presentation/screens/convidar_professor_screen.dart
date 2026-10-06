import 'package:flutter/material.dart';

class ConvidarProfessorScreen extends StatefulWidget {
  const ConvidarProfessorScreen({super.key});

  @override
  State<ConvidarProfessorScreen> createState() => _ConvidarProfessorScreenState();
}

class _ConvidarProfessorScreenState extends State<ConvidarProfessorScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _enviarConvite() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Envio', style: TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold)),
          content: Text('Deseja realmente enviar um convite para $email?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fecha o dialog
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Convite enviado com sucesso para $email'),
                    backgroundColor: const Color(0xFFA1A32D),
                  ),
                );
                Navigator.pop(context); // Fecha a tela de convidar
              },
              child: const Text('Sim', style: TextStyle(color: Color(0xFFA1A32D), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um e-mail válido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const secondaryTextColor = Color(0xFF6B6B6B);
    const buttonGreen = Color(0xFFA1A32D);
    const buttonRed = Color(0xFFE56B6F);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 20),
          label: const Text(
            'Voltar',
            style: TextStyle(color: primaryTextColor, fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Convidar Professor',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Envie um convite para que o educador possa acessar a plataforma.',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE8E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-mail Institucional',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Ex: maria.silva@escola.edu.br',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: buttonGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _enviarConvite,
                      icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'Enviar Convite',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
