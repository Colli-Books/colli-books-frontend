import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/invite_token.dart';
import 'accept_invite_screen.dart';

const _bgColor = Color(0xFFF9F5EC);
const _primaryText = Color(0xFF4A2525);
const _secondaryText = Color(0xFF6B6B6B);
const _accent = Color(0xFFA1A32D);

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty || !mounted) return;
    setState(() {
      _controller.text = text;
      _error = null;
    });
  }

  Future<void> _continue() async {
    final token = extractInviteToken(_controller.text);
    if (token == null) {
      setState(() => _error = 'Cole o código ou o link do convite que você recebeu.');
      return;
    }
    setState(() => _error = null);

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => AcceptInviteScreen(token: token)),
    );
    // O convite é um segredo de uso único: não deixa o texto na tela.
    if (mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _primaryText, size: 20),
          label: const Text('Voltar', style: TextStyle(color: _primaryText, fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tenho um convite',
              style: TextStyle(color: _primaryText, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cole o código ou o link de convite que você recebeu da editora para completar seu cadastro.',
              style: TextStyle(color: _secondaryText, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
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
                    'Código ou link do convite',
                    style: TextStyle(color: _primaryText, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('invite_code_input'),
                    controller: _controller,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continue(),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cole aqui',
                      errorText: _error,
                      errorMaxLines: 2,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.vpn_key_outlined, color: _accent, size: 20),
                      suffixIcon: IconButton(
                        tooltip: 'Colar',
                        icon: const Icon(Icons.content_paste_rounded, size: 20, color: _accent),
                        onPressed: _paste,
                      ),
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
                        borderSide: const BorderSide(color: _accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _continue,
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Continuar',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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