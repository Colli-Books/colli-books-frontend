import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'login_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9F9F22)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
