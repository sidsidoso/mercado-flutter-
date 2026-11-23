import 'package:flutter/material.dart';

void main() {
  runApp(const MercadoApp());
}

/// Modelo de um registro do mercado.
class Produto {
  final String nome;
  final String categoria;
  final String unidade;

  const Produto({
    required this.nome,
    required this.categoria,
    required this.unidade,
  });
}

class MercadoApp extends StatelessWidget {
  const MercadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const ListaProdutosPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// TELA 1 - LISTAGEM
// ---------------------------------------------------------------------------

class ListaProdutosPage extends StatefulWidget {
  const ListaProdutosPage({super.key});

  @override
  State<ListaProdutosPage> createState() => _ListaProdutosPageState();
}

class _ListaProdutosPageState extends State<ListaProdutosPage> {
  // Lista em memória (não há persistência após fechar o app).
  final List<Produto> _produtos = [
    const Produto(nome: 'Feijão', categoria: 'Alimentos', unidade: 'Pacote'),
  ];

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // Cadastro: abre o formulário vazio e adiciona o novo registro.
  Future<void> _abrirCadastro() async {
    final novo = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(builder: (_) => const FormularioProdutoPage()),
    );

    if (!mounted || novo == null) return;
    setState(() => _produtos.add(novo));
    _mostrarMensagem('Produto cadastrado!');
  }

  // Edição: abre o formulário preenchido e substitui o registro na
  // mesma posição (não cria duplicata).
  Future<void> _abrirEdicao(int index) async {
    final editado = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioProdutoPage(produto: _produtos[index]),
      ),
    );

    if (!mounted || editado == null) return;
    setState(() => _produtos[index] = editado);
    _mostrarMensagem('Produto atualizado!');
  }

  // Exclusão: pede confirmação e remove o registro da lista.
  Future<void> _excluir(int index) async {
    final produto = _produtos[index];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja remover "${produto.nome}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;
    setState(() => _produtos.removeAt(index));
    _mostrarMensagem('Produto removido!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado'),
        centerTitle: true,
      ),
      body: _produtos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto cadastrado.\nToque em + para adicionar.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _produtos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final p = _produtos[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_basket),
                    ),
                    title: Text(
                      p.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Categoria: ${p.categoria}\nUnidade: ${p.unidade}',
                    ),
                    isThreeLine: true,
                    onTap: () => _abrirEdicao(index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: 'Excluir',
                      onPressed: () => _excluir(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TELA 2 - FORMULÁRIO (CADASTRO E EDIÇÃO)
// ---------------------------------------------------------------------------

class FormularioProdutoPage extends StatefulWidget {
  /// Quando vier preenchido, a tela funciona como edição.
  final Produto? produto;

  const FormularioProdutoPage({super.key, this.produto});

  @override
  State<FormularioProdutoPage> createState() => _FormularioProdutoPageState();
}

class _FormularioProdutoPageState extends State<FormularioProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _unidadeController;

  bool get _editando => widget.produto != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _categoriaController =
        TextEditingController(text: widget.produto?.categoria ?? '');
    _unidadeController =
        TextEditingController(text: widget.produto?.unidade ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _unidadeController.dispose();
    super.dispose();
  }

  // Validação: campo vazio ou só com espaços é recusado.
  String? _obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o campo $campo';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Produto(
        nome: _nomeController.text.trim(),
        categoria: _categoriaController.text.trim(),
        unidade: _unidadeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar produto' : 'Novo produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  hintText: 'Ex.: Feijão',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => _obrigatorio(v, 'Produto'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Ex.: Alimentos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => _obrigatorio(v, 'Categoria'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unidadeController,
                decoration: const InputDecoration(
                  labelText: 'Unidade',
                  hintText: 'Ex.: Pacote',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _salvar(),
                validator: (v) => _obrigatorio(v, 'Unidade'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(_editando ? 'Salvar alterações' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
