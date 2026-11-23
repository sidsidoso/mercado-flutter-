import 'package:flutter/material.dart';

import '../utils/categoria_visual.dart';

/// Círculo colorido com o ícone da categoria do produto.
class AvatarCategoria extends StatelessWidget {
  final String categoria;
  final double raio;

  const AvatarCategoria({super.key, required this.categoria, this.raio = 22});

  @override
  Widget build(BuildContext context) {
    final visual = visualDaCategoria(categoria);
    // Gera tons que combinam com o tema claro ou escuro a partir da cor base.
    final cores = ColorScheme.fromSeed(
      seedColor: visual.cor,
      brightness: Theme.of(context).brightness,
    );

    return CircleAvatar(
      radius: raio,
      backgroundColor: cores.primaryContainer,
      foregroundColor: cores.onPrimaryContainer,
      child: Icon(visual.icone, size: raio),
    );
  }
}
