const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

final _espacos = RegExp(r'\s+');

/// Deixa o texto em minúsculas, sem acentos e sem espaços sobrando.
///
/// Serve para comparar e buscar textos de forma tolerante: "Feijão",
/// "feijao" e "  FEIJÃO " viram a mesma coisa.
String normalizar(String texto) {
  final resultado = StringBuffer();
  for (final codigo in texto.trim().toLowerCase().runes) {
    final letra = String.fromCharCode(codigo);
    final posicao = _comAcento.indexOf(letra);
    resultado.write(posicao >= 0 ? _semAcento[posicao] : letra);
  }
  return resultado.toString().replaceAll(_espacos, ' ');
}

/// Retorna "1 produto" ou "3 produtos", conforme a quantidade.
String contar(int quantidade, String singular, String plural) {
  return '$quantidade ${quantidade == 1 ? singular : plural}';
}
