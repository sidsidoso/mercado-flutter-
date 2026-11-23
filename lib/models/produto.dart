import '../utils/texto.dart';

/// Modelo de um registro do mercado.
///
/// Os três campos de texto (nome, categoria e unidade) são obrigatórios.
/// O [id] identifica o registro na lista em memória, o que permite editar e
/// excluir o item certo mesmo com a lista filtrada ou reordenada.
class Produto {
  final int id;
  final String nome;
  final String categoria;
  final String unidade;

  const Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.unidade,
  });

  Produto copyWith({
    int? id,
    String? nome,
    String? categoria,
    String? unidade,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      unidade: unidade ?? this.unidade,
    );
  }

  /// Compara apenas o conteúdo, ignorando maiúsculas, acentos e espaços
  /// extras. Usado para impedir cadastros repetidos.
  bool mesmoConteudo(Produto outro) {
    return normalizar(nome) == normalizar(outro.nome) &&
        normalizar(categoria) == normalizar(outro.categoria) &&
        normalizar(unidade) == normalizar(outro.unidade);
  }
}
