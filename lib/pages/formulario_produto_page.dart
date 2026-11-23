import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/produto.dart';
import '../utils/texto.dart';
import '../widgets/avatar_categoria.dart';
import '../widgets/etiqueta.dart';

// ---------------------------------------------------------------------------
// TELA 2 - FORMULÁRIO (CADASTRO E EDIÇÃO)
// ---------------------------------------------------------------------------

class FormularioProdutoPage extends StatefulWidget {
  /// Quando vier preenchido, a tela funciona como edição.
  final Produto? produto;

  /// Demais registros da lista, usados para impedir cadastros repetidos.
  final List<Produto> existentes;

  /// Categorias já usadas na lista, oferecidas como sugestão.
  final List<String> categorias;

  const FormularioProdutoPage({
    super.key,
    this.produto,
    this.existentes = const [],
    this.categorias = const [],
  });

  @override
  State<FormularioProdutoPage> createState() => _FormularioProdutoPageState();
}

class _FormularioProdutoPageState extends State<FormularioProdutoPage> {
  static const _tamanhoMaximo = 40;

  static const _categoriasPadrao = [
    'Alimentos',
    'Bebidas',
    'Hortifruti',
    'Laticínios',
    'Limpeza',
    'Higiene',
    'Padaria',
    'Carnes',
  ];

  static const _unidadesPadrao = [
    'Unidade',
    'Pacote',
    'Kg',
    'Litro',
    'Caixa',
    'Dúzia',
    'Garrafa',
    'Lata',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _unidadeController;

  // Depois da primeira tentativa de salvar, os erros passam a ser
  // atualizados enquanto o usuário digita.
  bool _validarAoDigitar = false;

  bool get _editando => widget.produto != null;

  String get _nome => _nomeController.text.trim();
  String get _categoria => _categoriaController.text.trim();
  String get _unidade => _unidadeController.text.trim();

  /// Indica se algum campo foi alterado em relação ao valor inicial.
  bool get _alterado {
    return _nome != (widget.produto?.nome ?? '') ||
        _categoria != (widget.produto?.categoria ?? '') ||
        _unidade != (widget.produto?.unidade ?? '');
  }

  Produto get _rascunho => Produto(
        id: widget.produto?.id ?? 0,
        nome: _nome,
        categoria: _categoria,
        unidade: _unidade,
      );

  /// Categorias já usadas primeiro, depois as mais comuns, sem repetir.
  List<String> get _sugestoesCategoria {
    final vistas = <String>{};
    return [...widget.categorias, ..._categoriasPadrao]
        .where((c) => vistas.add(normalizar(c)))
        .take(8)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _categoriaController =
        TextEditingController(text: widget.produto?.categoria ?? '');
    _unidadeController =
        TextEditingController(text: widget.produto?.unidade ?? '');

    // Mantém a pré-visualização e o aviso de alterações sempre atualizados.
    for (final c in [
      _nomeController,
      _categoriaController,
      _unidadeController
    ]) {
      c.addListener(_aoDigitar);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _unidadeController.dispose();
    super.dispose();
  }

  void _aoDigitar() => setState(() {});

  // -------------------------------------------------------------------------
  // Validação
  // -------------------------------------------------------------------------

  // Campo vazio ou só com espaços é recusado.
  String? _obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o campo $campo';
    }
    return null;
  }

  // Além de obrigatório, o produto não pode repetir um registro existente
  // (mesmo nome, categoria e unidade).
  String? _validarNome(String? valor) {
    final erro = _obrigatorio(valor, 'Produto');
    if (erro != null) return erro;

    final rascunho = _rascunho;
    if (widget.existentes.any(rascunho.mesmoConteudo)) {
      return 'Já existe um produto igual cadastrado';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _validarAoDigitar = true);
      return;
    }
    Navigator.pop(context, _rascunho);
  }

  Future<void> _confirmarSaida() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você digitou não será salvo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (!mounted || descartar != true) return;
    Navigator.pop(context);
  }

  // -------------------------------------------------------------------------
  // Interface
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final formatadores = [LengthLimitingTextInputFormatter(_tamanhoMaximo)];

    // Avisa antes de sair se houver alterações não salvas.
    return PopScope(
      canPop: !_alterado,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _confirmarSaida();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editando ? 'Editar produto' : 'Novo produto'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _validarAoDigitar
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _construirPreVisualizacao(context),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('campo_produto'),
                        controller: _nomeController,
                        autofocus: !_editando,
                        decoration: const InputDecoration(
                          labelText: 'Produto',
                          hintText: 'Ex.: Feijão',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        inputFormatters: formatadores,
                        validator: _validarNome,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('campo_categoria'),
                        controller: _categoriaController,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          hintText: 'Ex.: Alimentos',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        inputFormatters: formatadores,
                        validator: (v) => _obrigatorio(v, 'Categoria'),
                      ),
                      _Sugestoes(
                        opcoes: _sugestoesCategoria,
                        controller: _categoriaController,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('campo_unidade'),
                        controller: _unidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          hintText: 'Ex.: Pacote',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        inputFormatters: formatadores,
                        onFieldSubmitted: (_) => _salvar(),
                        validator: (v) => _obrigatorio(v, 'Unidade'),
                      ),
                      _Sugestoes(
                        opcoes: _unidadesPadrao,
                        controller: _unidadeController,
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        key: const Key('botao_salvar'),
                        onPressed: _salvar,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_editando ? 'Salvar alterações' : 'Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Cartão que mostra como o produto vai aparecer na listagem.
  Widget _construirPreVisualizacao(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarCategoria(categoria: _categoria, raio: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nome.isEmpty ? 'Pré-visualização' : _nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _nome.isEmpty ? cores.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Etiqueta(
                        icone: Icons.category_outlined,
                        texto: _categoria.isEmpty ? '—' : _categoria,
                      ),
                      Etiqueta(
                        icone: Icons.straighten,
                        texto: _unidade.isEmpty ? '—' : _unidade,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opções prontas exibidas abaixo de um campo; tocar em uma preenche o campo.
class _Sugestoes extends StatelessWidget {
  final List<String> opcoes;
  final TextEditingController controller;

  const _Sugestoes({required this.opcoes, required this.controller});

  @override
  Widget build(BuildContext context) {
    final atual = normalizar(controller.text);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final opcao in opcoes)
            ChoiceChip(
              label: Text(opcao),
              selected: normalizar(opcao) == atual,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => controller.text = opcao,
            ),
        ],
      ),
    );
  }
}
