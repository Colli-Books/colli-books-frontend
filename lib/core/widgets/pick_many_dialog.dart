import 'package:flutter/material.dart';

import 'pick_one_dialog.dart';

/// Seleção múltipla com checkboxes. Devolve null se cancelou e o conjunto
/// escolhido ao aplicar (vazio = "todos", quando usado como filtro).
Future<Set<int>?> showPickManyDialog(
  BuildContext context, {
  required String title,
  required String emptyMessage,
  required List<PickOption> options,
  required Set<int> selectedIds,
  String applyLabel = 'Aplicar',
  String clearLabel = 'Limpar',
}) {
  final temp = {...selectedIds};

  return showDialog<Set<int>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setStateDialog) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5EC),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4A2525),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: options.isEmpty
              ? Text(emptyMessage)
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final o in options)
                      CheckboxListTile(
                        key: ValueKey('pick_many_option_${o.id}'),
                        title: Text(
                          o.name,
                          style: const TextStyle(color: Color(0xFF4A2525)),
                        ),
                        activeColor: const Color(0xFFA1A32D),
                        value: temp.contains(o.id),
                        onChanged: (checked) => setStateDialog(() {
                          if (checked == true) {
                            temp.add(o.id);
                          } else {
                            temp.remove(o.id);
                          }
                        }),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            key: const ValueKey('pick_many_clear'),
            onPressed: temp.isEmpty ? null : () => setStateDialog(temp.clear),
            child: Text(
              clearLabel,
              style: const TextStyle(color: Color(0xFF4A2525)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            key: const ValueKey('pick_many_apply'),
            onPressed: () => Navigator.pop(dialogContext, {...temp}),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA1A32D),
            ),
            child: Text(
              applyLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
