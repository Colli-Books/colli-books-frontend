import 'package:flutter/material.dart';

void showMultiSelectDialog({
  required String title,
  required BuildContext context,
  required List<String> allItems,
  required List<String> selectedItems,
  required void Function(List<String>) onConfirm,
}) {
  final tempSelected = List<String>.from(selectedItems);
  showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(title, style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: const Color(0xFFF9F5EC),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: allItems.map((item) {
                  return CheckboxListTile(
                    title: Text(item, style: const TextStyle(color: Color(0xFF4A2525))),
                    activeColor: const Color(0xFFA1A32D),
                    value: tempSelected.contains(item),
                    onChanged: (bool? checked) {
                      setStateDialog(() {
                        if (checked == true) {
                          tempSelected.add(item);
                        } else {
                          tempSelected.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  onConfirm(tempSelected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA1A32D)),
                child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}


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
        padding: EdgeInsets.all(2.0),
        child: Icon(Icons.delete_outline, size: 16, color: Color(0xFFE56B6F)),
      ),
    );
  }
}