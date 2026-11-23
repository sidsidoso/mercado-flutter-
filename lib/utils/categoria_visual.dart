import 'package:flutter/material.dart';

import 'texto.dart';

/// Ícone e cor usados para representar uma categoria na interface.
class CategoriaVisual {
  final IconData icone;
  final Color cor;

  const CategoriaVisual(this.icone, this.cor);
}

class _Regra {
  final List<String> palavras;
  final CategoriaVisual visual;

  const _Regra(this.palavras, this.visual);
}

const _regras = <_Regra>[
  _Regra(
    ['hortifruti', 'fruta', 'verdura', 'legume'],
    CategoriaVisual(Icons.eco, Color(0xFF2E7D32)),
  ),
  _Regra(
    ['bebida', 'suco', 'refrigerante', 'agua'],
    CategoriaVisual(Icons.local_drink, Color(0xFF0277BD)),
  ),
  _Regra(
    ['limpeza'],
    CategoriaVisual(Icons.cleaning_services, Color(0xFF00838F)),
  ),
  _Regra(
    ['higiene', 'beleza', 'perfumaria'],
    CategoriaVisual(Icons.soap, Color(0xFF8E24AA)),
  ),
  _Regra(
    ['padaria', 'pao', 'confeitaria'],
    CategoriaVisual(Icons.bakery_dining, Color(0xFFB26A00)),
  ),
  _Regra(
    ['carne', 'acougue', 'peixe', 'frango'],
    CategoriaVisual(Icons.set_meal, Color(0xFFC62828)),
  ),
  _Regra(
    ['laticinio', 'frios', 'queijo', 'leite'],
    CategoriaVisual(Icons.egg_alt, Color(0xFF3949AB)),
  ),
  _Regra(
    ['congelado', 'sorvete'],
    CategoriaVisual(Icons.ac_unit, Color(0xFF1565C0)),
  ),
  _Regra(
    ['pet', 'racao', 'animal'],
    CategoriaVisual(Icons.pets, Color(0xFF6D4C41)),
  ),
  _Regra(
    ['alimento', 'mercearia', 'grao', 'cereal'],
    CategoriaVisual(Icons.rice_bowl, Color(0xFFEF6C00)),
  ),
];

/// Cores usadas para categorias que não se encaixam em nenhuma regra.
const _coresExtras = <Color>[
  Color(0xFF00897B),
  Color(0xFF5E35B1),
  Color(0xFFD81B60),
  Color(0xFF546E7A),
  Color(0xFF7CB342),
  Color(0xFFF4511E),
];

/// Escolhe ícone e cor de acordo com o nome da categoria.
///
/// Categorias desconhecidas recebem sempre a mesma cor para o mesmo nome.
CategoriaVisual visualDaCategoria(String categoria) {
  final chave = normalizar(categoria);

  for (final regra in _regras) {
    if (regra.palavras.any(chave.contains)) return regra.visual;
  }

  var soma = 0;
  for (final codigo in chave.codeUnits) {
    soma += codigo;
  }
  return CategoriaVisual(
    Icons.shopping_basket,
    _coresExtras[soma % _coresExtras.length],
  );
}
