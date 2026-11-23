import 'package:flutter/material.dart';

import 'pages/lista_produtos_page.dart';

void main() {
  runApp(const MercadoApp());
}

class MercadoApp extends StatefulWidget {
  const MercadoApp({super.key});

  @override
  State<MercadoApp> createState() => _MercadoAppState();
}

class _MercadoAppState extends State<MercadoApp> {
  // Começa seguindo o tema do aparelho; o botão da tela inicial alterna
  // entre claro e escuro.
  ThemeMode _modoTema = ThemeMode.system;

  void _alternarTema(Brightness atual) {
    setState(() {
      _modoTema = atual == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  ThemeData _tema(Brightness brilho) {
    final cores = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: brilho,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      scaffoldBackgroundColor: cores.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cores.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado',
      debugShowCheckedModeBanner: false,
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      themeMode: _modoTema,
      home: ListaProdutosPage(onAlternarTema: _alternarTema),
    );
  }
}
