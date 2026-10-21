import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'core/theme/colors.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/professor/presentation/screens/home_professor_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Habilita o preview com a moldura de celular
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colli Books',
      debugShowCheckedModeBanner: false,

      // Configurações do Device Preview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: ThemeData(
        // 3. Substituímos a cor fixa pelo nosso token global
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        // 4. Define o fundo padrão para que as novas telas já nasçam com a cor certa
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const HomeProfessorScreen(),
    );
  }
}
