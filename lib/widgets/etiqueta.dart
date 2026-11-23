import 'package:flutter/material.dart';

/// Pequena etiqueta com ícone e texto, usada para mostrar a categoria e a
/// unidade do produto na listagem.
class Etiqueta extends StatelessWidget {
  final IconData icone;
  final String texto;

  const Etiqueta({super.key, required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cores.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.labelMedium
                  ?.copyWith(color: cores.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
