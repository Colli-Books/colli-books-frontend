import 'package:flutter/material.dart';

import '../network/api_exception.dart';

/// Diálogo de confirmação para ações destrutivas. Devolve `true` só se o usuário confirmar.
///
/// O botão de confirmar leva a chave `confirm_delete` (usada nos testes E2E).
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF9F5EC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.delete_outline, color: Color(0xFFE56B6F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF4A2525),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF8C7A70), fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          key: const ValueKey('confirm_delete'),
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE56B6F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Mensagem para uma exclusão que falhou, por `code` (nunca pelo texto do servidor).
///
/// Depois de QUALQUER falha, a tela deve recarregar a lista: com `NOT_FOUND` o item já não
/// existe, e com falha de rede o resultado é incerto (a exclusão pode ter sido concluída).
String deleteErrorMessage(ApiException e) => switch (e.code) {
      'FORBIDDEN' => 'Você não tem permissão para excluir.',
      'NOT_FOUND' => 'Este item não existe mais. Atualizando a lista.',
      'RATE_LIMITED' => 'Muitas tentativas. Aguarde um instante e tente de novo.',
      // Rota DELETE ainda não publicada no servidor (FastAPI responde 405 sem o corpo padrão).
      _ when e.statusCode == 405 => 'O servidor ainda não oferece esta exclusão.',
      _ when e.isNetworkError =>
        '${e.message} A exclusão pode ter sido concluída: confira a lista antes de tentar de novo.',
      _ => e.message,
    };
