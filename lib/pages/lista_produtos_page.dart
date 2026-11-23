import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../utils/texto.dart';
import '../widgets/avatar_categoria.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/etiqueta.dart';
import 'formulario_produto_page.dart';

/// Formas de ordenar a listagem.
enum Ordenacao {
  cadastro('Ordem de cadastro', Icons.schedule),
  nomeAz('Nome (A–Z)', Icons.arrow_downward),
  nomeZa('Nome (Z–A)', Icons.arrow_upward),
  categoria('Categoria', Icons.category_outlined);

  const Ordenacao(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}

/// Categoria presente na lista, com a quantidade de produtos dela.
class _Categoria {
  final String chave;
  final String rotulo;
  final int quantidade;

  const _Categoria(this.chave, this.rotulo, this.quantidade);
}

// ---------------------------------------------------------------------------
// TELA 1 - LISTAGEM
// ---------------------------------------------------------------------------

class ListaProdutosPage extends StatefulWidget {
  /// Chamado ao tocar no botão de tema, recebendo o brilho atual da tela.
  final void Function(Brightness atual)? onAlternarTema;

  const ListaProdutosPage({super.key, this.onAlternarTema});

  @override
  State<ListaProdutosPage> createState() => _ListaProdutosPageState();
}

class _ListaProdutosPageState extends State<ListaProdutosPage> {
  // Lista em memória (não há persistência após fechar o app).
  final List<Produto> _produtos = [
    const Produto(
        id: 1, nome: 'Feijão', categoria: 'Alimentos', unidade: 'Pacote'),
    const Produto(
        id: 2,
        nome: 'Leite integral',
        categoria: 'Laticínios',
        unidade: 'Litro'),
    const Produto(
        id: 3, nome: 'Detergente', categoria: 'Limpeza', unidade: 'Unidade'),
    const Produto(
        id: 4, nome: 'Banana', categoria: 'Hortifruti', unidade: 'Kg'),
  ];
  int _proximoId = 5;

  final _buscaController = TextEditingController();
  String? _categoriaFiltro;
  Ordenacao _ordenacao = Ordenacao.cadastro;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Dados derivados da lista (busca, filtro e ordenação)
  // -------------------------------------------------------------------------

  /// Categorias existentes na lista, em ordem alfabética.
  List<_Categoria> get _categorias {
    final rotulos = <String, String>{};
    final quantidades = <String, int>{};

    for (final p in _produtos) {
      final chave = normalizar(p.categoria);
      rotulos.putIfAbsent(chave, () => p.categoria);
      quantidades[chave] = (quantidades[chave] ?? 0) + 1;
    }

    final chaves = rotulos.keys.toList()..sort();
    return [
      for (final chave in chaves)
        _Categoria(chave, rotulos[chave]!, quantidades[chave]!),
    ];
  }

  /// Produtos que passam pela busca e pelo filtro, já ordenados.
  List<Produto> get _visiveis {
    final termo = normalizar(_buscaController.text);

    final lista = _produtos.where((p) {
      if (_categoriaFiltro != null &&
          normalizar(p.categoria) != _categoriaFiltro) {
        return false;
      }
      if (termo.isEmpty) return true;
      return normalizar(p.nome).contains(termo) ||
          normalizar(p.categoria).contains(termo) ||
          normalizar(p.unidade).contains(termo);
    }).toList();

    int porNome(Produto a, Produto b) =>
        normalizar(a.nome).compareTo(normalizar(b.nome));

    switch (_ordenacao) {
      case Ordenacao.cadastro:
        break;
      case Ordenacao.nomeAz:
        lista.sort(porNome);
      case Ordenacao.nomeZa:
        lista.sort((a, b) => porNome(b, a));
      case Ordenacao.categoria:
        lista.sort((a, b) {
          final porCategoria =
              normalizar(a.categoria).compareTo(normalizar(b.categoria));
          return porCategoria != 0 ? porCategoria : porNome(a, b);
        });
    }
    return lista;
  }

  bool get _filtrando =>
      _categoriaFiltro != null || _buscaController.text.trim().isNotEmpty;

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _categoriaFiltro = null;
    });
  }

  /// Se a categoria filtrada deixou de existir, volta a mostrar todas.
  void _ajustarFiltro() {
    final existe =
        _produtos.any((p) => normalizar(p.categoria) == _categoriaFiltro);
    if (!existe) _categoriaFiltro = null;
  }

  // -------------------------------------------------------------------------
  // Operações (cadastro, edição e exclusão)
  // -------------------------------------------------------------------------

  void _mostrarMensagem(String texto, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          action: acao,
          duration: const Duration(seconds: 4),
          persist: false,
        ),
      );
  }

  // Cadastro: abre o formulário vazio e adiciona o novo registro.
  Future<void> _abrirCadastro() async {
    final novo = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioProdutoPage(
          existentes: List.unmodifiable(_produtos),
          categorias: [for (final c in _categorias) c.rotulo],
        ),
      ),
    );

    if (!mounted || novo == null) return;
    setState(() {
      final cadastrado = novo.copyWith(id: _proximoId++);
      _produtos.add(cadastrado);
      // Garante que o item recém-criado apareça, mesmo com filtros ativos.
      if (!_visiveis.any((p) => p.id == cadastrado.id)) {
        _buscaController.clear();
        _categoriaFiltro = null;
      }
    });
    _mostrarMensagem('Produto cadastrado!');
  }

  // Edição: abre o formulário preenchido e substitui o registro na
  // mesma posição (não cria duplicata).
  Future<void> _abrirEdicao(Produto produto) async {
    final editado = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioProdutoPage(
          produto: produto,
          existentes: [
            for (final p in _produtos)
              if (p.id != produto.id) p,
          ],
          categorias: [for (final c in _categorias) c.rotulo],
        ),
      ),
    );

    if (!mounted || editado == null) return;
    final indice = _produtos.indexWhere((p) => p.id == produto.id);
    if (indice < 0) return;

    setState(() {
      _produtos[indice] = editado.copyWith(id: produto.id);
      _ajustarFiltro();
    });
    _mostrarMensagem('Produto atualizado!');
  }

  Future<bool> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Excluir produto'),
        content: Text('Deseja remover "${produto.nome}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 40),
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return confirmar ?? false;
  }

  // Exclusão: remove o registro e oferece a opção de desfazer.
  void _remover(Produto produto) {
    final indice = _produtos.indexWhere((p) => p.id == produto.id);
    if (indice < 0) return;

    setState(() {
      _produtos.removeAt(indice);
      _ajustarFiltro();
    });

    _mostrarMensagem(
      'Produto removido!',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            _produtos.insert(math.min(indice, _produtos.length), produto);
          });
        },
      ),
    );
  }

  Future<void> _excluir(Produto produto) async {
    final confirmado = await _confirmarExclusao(produto);
    if (!mounted || !confirmado) return;
    _remover(produto);
  }

  // -------------------------------------------------------------------------
  // Interface
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final brilho = Theme.of(context).brightness;
    final escuro = brilho == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado'),
        actions: [
          PopupMenuButton<Ordenacao>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            initialValue: _ordenacao,
            onSelected: (valor) => setState(() => _ordenacao = valor),
            itemBuilder: (_) => [
              for (final opcao in Ordenacao.values)
                PopupMenuItem(
                  value: opcao,
                  child: Row(
                    children: [
                      Icon(opcao.icone, size: 20),
                      const SizedBox(width: 12),
                      Flexible(child: Text(opcao.rotulo)),
                    ],
                  ),
                ),
            ],
          ),
          if (widget.onAlternarTema != null)
            IconButton(
              tooltip: escuro ? 'Tema claro' : 'Tema escuro',
              icon: Icon(
                escuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () => widget.onAlternarTema!(brilho),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          // Limita a largura para a lista não esticar demais em telas grandes.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _produtos.isEmpty
                ? const EstadoVazio(
                    icone: Icons.shopping_basket_outlined,
                    titulo: 'Nenhum produto cadastrado',
                    mensagem: 'Toque em "Novo" para adicionar o primeiro.',
                  )
                : _construirConteudo(context),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Widget _construirConteudo(BuildContext context) {
    final tema = Theme.of(context);
    final categorias = _categorias;
    final visiveis = _visiveis;

    final resumo = _filtrando
        ? 'Mostrando ${visiveis.length} de '
            '${contar(_produtos.length, 'produto', 'produtos')}'
        : '${contar(_produtos.length, 'produto', 'produtos')} · '
            '${contar(categorias.length, 'categoria', 'categorias')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Busca
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            key: const Key('campo_busca'),
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar produto, categoria ou unidade',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_buscaController.clear),
                    ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              fillColor: tema.colorScheme.surfaceContainerHigh,
            ),
          ),
        ),

        // Filtro por categoria
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: _categoriaFiltro == null,
                    onSelected: (_) => setState(() => _categoriaFiltro = null),
                  ),
                ),
                for (final c in categorias)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${c.rotulo} (${c.quantidade})'),
                      selected: _categoriaFiltro == c.chave,
                      onSelected: (marcado) => setState(
                        () => _categoriaFiltro = marcado ? c.chave : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Resumo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            resumo,
            key: const Key('resumo'),
            style: tema.textTheme.labelLarge
                ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ),

        // Lista
        Expanded(
          child: visiveis.isEmpty
              ? EstadoVazio(
                  icone: Icons.search_off,
                  titulo: 'Nada encontrado',
                  mensagem: 'Nenhum produto corresponde à busca ou ao filtro.',
                  acao: OutlinedButton.icon(
                    onPressed: _limparFiltros,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Limpar filtros'),
                  ),
                )
              : ListView.separated(
                  // Espaço no fim para o botão "Novo" não cobrir o último item.
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: visiveis.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _construirItem(context, visiveis[index]),
                ),
        ),
      ],
    );
  }

  Widget _construirItem(BuildContext context, Produto p) {
    final cores = Theme.of(context).colorScheme;

    // Arrastar para a esquerda também exclui (com a mesma confirmação).
    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarExclusao(p),
      onDismissed: (_) => _remover(p),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: cores.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: cores.onErrorContainer),
      ),
      child: Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: AvatarCategoria(categoria: p.categoria),
          title: Text(
            p.nome,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Etiqueta(icone: Icons.category_outlined, texto: p.categoria),
                Etiqueta(icone: Icons.straighten, texto: p.unidade),
              ],
            ),
          ),
          onTap: () => _abrirEdicao(p),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: cores.error,
            tooltip: 'Excluir',
            onPressed: () => _excluir(p),
          ),
        ),
      ),
    );
  }
}
