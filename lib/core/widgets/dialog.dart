import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  final String itemTitle;
  final VoidCallback onConfirm;
  final String dialogTitle;
  final String successMessage;

  const DeleteIconButton({
    super.key,
    required this.itemTitle,
    required this.onConfirm,

    this.dialogTitle = 'Excluir',
    this.successMessage = 'Excluído com sucesso!',
  });

  void _showConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          dialogTitle,
          style: const TextStyle(color: Color(0xFF4A2525)),
        ),
        content: Text('Tem certeza que deseja excluir "$itemTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE56B6F),
            ),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showConfirmDialog(context),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.delete_outline, size: 16, color: Color(0xFFE56B6F)),
      ),
    );
  }
}