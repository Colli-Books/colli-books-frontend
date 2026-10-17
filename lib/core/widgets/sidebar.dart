import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import 'botaoTerciario.dart'; // Utilizamos o botão que já criamos para padronizar

// 1. Criamos um "molde" genérico para os itens que vão na barra lateral
class SidebarItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  SidebarItem({required this.label, required this.icon, required this.onTap});
}

// 2. A Sidebar genérica que apenas desenha o que recebe
class Sidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final SidebarItem
  logoutItem; // Tratamos o botão de sair separado para fixar no rodapé

  const Sidebar({super.key, required this.items, required this.logoutItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho / Logo
          const Padding(
            padding: EdgeInsets.all(AppSizes.spacingLg),
            child: SafeArea(
              child: Text(
                'Menu Colli Books',
                style: TextStyle(
                  fontSize: AppSizes.fontTitle,
                  color: AppColors.titleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Miolo: Lista de Itens injetados de fora
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoTerciario(
                      texto: item.label,
                      icone: item.icon,
                      cor: AppColors.textPrimary,
                      isVertical: false,
                      onPressed: item.onTap,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Rodapé: Botão de Sair fixo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              child: BotaoTerciario(
                texto: logoutItem.label,
                icone: logoutItem.icon,
                cor: AppColors.danger, // Vermelho padronizado
                isVertical: false,
                onPressed: logoutItem.onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
