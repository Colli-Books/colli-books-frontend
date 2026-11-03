import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/invite_result_model.dart';

const _primaryTextColor = Color(0xFF4A2525);
const _secondaryTextColor = Color(0xFF6B6B6B);
const _buttonGreen = Color(0xFFA1A32D);

Future<void> showInviteDialog(BuildContext context, InviteResultModel invite) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF9F5EC),
      title: const Text(
        'Novo convite gerado',
        style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(child: InviteDetails(invite: invite)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Fechar',
            style: TextStyle(color: _buttonGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

class InviteDetails extends StatelessWidget {
  const InviteDetails({super.key, required this.invite});

  final InviteResultModel invite;

  String _formatExpiry(DateTime utc) {
    final d = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} às ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enviamos um novo convite para ${invite.email}. O convite anterior deixou de funcionar. '
              'Se o e-mail não chegar, envie o código ou o link abaixo por outro canal (ex.: WhatsApp).',
          style: const TextStyle(color: _secondaryTextColor, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        _CopyField(label: 'Código do convite', value: invite.inviteCode),
        const SizedBox(height: 12),
        _CopyField(label: 'Link do convite', value: invite.inviteLink),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: _secondaryTextColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Válido até ${_formatExpiry(invite.inviteExpiresAt)}',
                style: const TextStyle(color: _secondaryTextColor, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CopyField extends StatefulWidget {
  const _CopyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_CopyField> createState() => _CopyFieldState();
}

class _CopyFieldState extends State<_CopyField> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: _primaryTextColor, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2, right: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD6D6D6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  widget.value,
                  style: const TextStyle(color: _primaryTextColor, fontSize: 12.5, height: 1.3),
                ),
              ),
              IconButton(
                tooltip: _copied ? 'Copiado' : 'Copiar',
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 20,
                  color: _buttonGreen,
                ),
                onPressed: _copy,
              ),
            ],
          ),
        ),
      ],
    );
  }
}