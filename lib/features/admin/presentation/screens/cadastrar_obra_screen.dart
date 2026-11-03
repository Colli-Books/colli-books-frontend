import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalogo/data/services/catalog_api_service.dart';
import '../widgets/book_form_view.dart';

class CadastrarObraScreen extends StatelessWidget {
  const CadastrarObraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    final service = context.read<CatalogApiService>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 20),
          label: const Text('Voltar', style: TextStyle(color: primaryTextColor, fontSize: 16)),
        ),
      ),
      body: BookFormView(
        heading: 'Cadastrar Nova Obra',
        centerHeading: true,
        submitLabel: 'Cadastrar Obra',
        submittingLabel: 'Cadastrando...',
        submitIcon: Icons.add_circle_outline,
        // POST não é idempotente: sem resposta, a obra pode ter sido criada.
        uncertainOutcomeHint:
        'Se o envio chegou a sair, a obra pode ter sido cadastrada: confira o catálogo antes de tentar de novo.',
        onSubmit: service.createBook,
        onSaved: (book) => Navigator.pop(context, book),
      ),
    );
  }
}