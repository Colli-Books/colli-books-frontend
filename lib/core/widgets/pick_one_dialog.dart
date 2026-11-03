import 'package:flutter/material.dart';

typedef PickOption = ({int id, String name});

/// Devolve null se cancelou, e `(id: null)` se escolheu "todos".
Future<({int? id})?> showPickOneDialog(
    BuildContext context, {
      required String title,
      required String allLabel,
      required String emptyMessage,
      required List<PickOption> options,
      required int? selectedId,
    }) {
  return showDialog<({int? id})>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFFF9F5EC),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: options.isEmpty
            ? Text(emptyMessage)
            : ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              key: const ValueKey('pick_option_all'),
              title: Text(allLabel, style: const TextStyle(color: Color(0xFF6B6B6B))),
              trailing: selectedId == null
                  ? const Icon(Icons.check, color: Color(0xFFA1A32D))
                  : null,
              onTap: () => Navigator.pop(dialogContext, (id: null)),
            ),
            for (final o in options)
              ListTile(
                key: ValueKey('pick_option_${o.id}'),
                title: Text(o.name, style: const TextStyle(color: Color(0xFF4A2525))),
                trailing: o.id == selectedId
                    ? const Icon(Icons.check, color: Color(0xFFA1A32D))
                    : null,
                onTap: () => Navigator.pop(dialogContext, (id: o.id)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
      ],
    ),
  );
}