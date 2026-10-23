
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class PerfilAdminScreen extends StatefulWidget{
  const PerfilAdminScreen({super.key});

  @override
  State<PerfilAdminScreen> createState() => _PerfilAdminScreenState();
}

class _PerfilAdminScreenState extends State<PerfilAdminScreen>{
  @override
  Widget build(BuildContext buildContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Admin Colli',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administrador Master',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MATRIZ COLLI BOOKS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXXl),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.exit_to_app, color: AppColors.danger),
            label: const Text(
              'Sair',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXl, vertical: AppSizes.spacingXMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}