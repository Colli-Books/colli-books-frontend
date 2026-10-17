import 'package:flutter/material.dart';
import 'catalogo_data.dart';

class CadastrarEscolaridadeScreen extends StatefulWidget {
  const CadastrarEscolaridadeScreen({super.key});

  @override
  State<CadastrarEscolaridadeScreen> createState() => _CadastrarEscolaridadeScreenState();
}

class _CadastrarEscolaridadeScreenState extends State<CadastrarEscolaridadeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _cadastrar() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    if (CatalogoData.escolaridades.any((e) => e.toLowerCase() == value.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta escolaridade já existe!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        CatalogoData.escolaridades.add(value);
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escolaridade "$value" cadastrada com sucesso!'),
          backgroundColor: const Color(0xFFA1A32D),
        ),
      );
    }
  }

  void _confirmarExclusao(String item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a escolaridade "$item"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                CatalogoData.escolaridades.remove(item);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Escolaridade excluída!'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
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
          label: const Text('Voltar', style: TextStyle(color: primaryTextColor, fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cadastrar Escolaridade',
              style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
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
                    'Escolaridade',
                    style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ex: Fundamental I',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD6D6D6))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD6D6D6))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: buttonGreen)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFEBE8E0)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _cadastrar,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      label: const Text('Cadastrar Escolaridade', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Escolaridades Cadastradas',
              style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...CatalogoData.escolaridades.map((e) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEBE8E0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(e, style: const TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600))),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmarExclusao(e),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
