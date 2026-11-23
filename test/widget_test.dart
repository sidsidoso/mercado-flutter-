import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_app/main.dart';
import 'package:mercado_app/models/produto.dart';
import 'package:mercado_app/utils/texto.dart';

const _campoProduto = Key('campo_produto');
const _campoCategoria = Key('campo_categoria');
const _campoUnidade = Key('campo_unidade');
const _campoBusca = Key('campo_busca');
const _botaoSalvar = Key('botao_salvar');

Future<void> _abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(const MercadoApp());
  await tester.pumpAndSettle();
}

Future<void> _abrirCadastro(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _preencher(
  WidgetTester tester, {
  required String produto,
  required String categoria,
  required String unidade,
}) async {
  await tester.enterText(find.byKey(_campoProduto), produto);
  await tester.enterText(find.byKey(_campoCategoria), categoria);
  await tester.enterText(find.byKey(_campoUnidade), unidade);
  await tester.pumpAndSettle();
}

Future<void> _salvar(WidgetTester tester) async {
  final botao = find.byKey(_botaoSalvar);
  await tester.ensureVisible(botao);
  await tester.pumpAndSettle();
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

String _texto(WidgetTester tester, Key campo) {
  return tester.widget<TextFormField>(find.byKey(campo)).controller!.text;
}

void main() {
  group('Listagem', () {
    testWidgets('inicia com os produtos de exemplo', (tester) async {
      await _abrirApp(tester);

      expect(find.text('Feijão'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(4));
      expect(find.text('4 produtos · 4 categorias'), findsOneWidget);
    });

    testWidgets('busca ignora acentos e maiúsculas', (tester) async {
      await _abrirApp(tester);

      await tester.enterText(find.byKey(_campoBusca), 'FEIJAO');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Feijão'), findsOneWidget);
      expect(find.text('Mostrando 1 de 4 produtos'), findsOneWidget);
    });

    testWidgets('busca sem resultado permite limpar os filtros',
        (tester) async {
      await _abrirApp(tester);

      await tester.enterText(find.byKey(_campoBusca), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('Nada encontrado'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('filtra por categoria', (tester) async {
      await _abrirApp(tester);

      await tester.ensureVisible(find.text('Limpeza (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpeza (1)'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Detergente'), findsOneWidget);

      await tester.ensureVisible(find.text('Todas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todas'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('ordena por nome', (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.byTooltip('Ordenar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nome (A–Z)'));
      await tester.pumpAndSettle();

      final banana = tester.getTopLeft(find.text('Banana')).dy;
      final detergente = tester.getTopLeft(find.text('Detergente')).dy;
      final feijao = tester.getTopLeft(find.text('Feijão')).dy;
      expect(banana, lessThan(detergente));
      expect(detergente, lessThan(feijao));
    });
  });

  group('Cadastro', () {
    testWidgets('não salva campos com apenas espaços', (tester) async {
      await _abrirApp(tester);
      await _abrirCadastro(tester);

      await _preencher(tester, produto: '   ', categoria: ' ', unidade: '');
      await _salvar(tester);

      expect(find.text('Informe o campo Produto'), findsOneWidget);
      expect(find.text('Informe o campo Categoria'), findsOneWidget);
      expect(find.text('Informe o campo Unidade'), findsOneWidget);
      expect(find.text('Novo produto'), findsOneWidget);
    });

    testWidgets('cadastra um novo produto', (tester) async {
      await _abrirApp(tester);
      await _abrirCadastro(tester);

      await _preencher(
        tester,
        produto: '  Arroz ',
        categoria: 'Alimentos',
        unidade: 'Saco 5kg',
      );
      await _salvar(tester);

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(find.text('Produto cadastrado!'), findsOneWidget);
      expect(find.text('5 produtos · 4 categorias'), findsOneWidget);
    });

    testWidgets('impede cadastro repetido', (tester) async {
      await _abrirApp(tester);
      await _abrirCadastro(tester);

      await _preencher(
        tester,
        produto: 'feijao',
        categoria: 'ALIMENTOS',
        unidade: ' pacote ',
      );
      await _salvar(tester);

      expect(
          find.text('Já existe um produto igual cadastrado'), findsOneWidget);
      expect(find.text('Novo produto'), findsOneWidget);
    });

    testWidgets('sugestão preenche o campo', (tester) async {
      await _abrirApp(tester);
      await _abrirCadastro(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Bebidas'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Garrafa'));
      await tester.pumpAndSettle();

      expect(_texto(tester, _campoCategoria), 'Bebidas');
      expect(_texto(tester, _campoUnidade), 'Garrafa');
    });

    testWidgets('pede confirmação antes de descartar o que foi digitado',
        (tester) async {
      await _abrirApp(tester);
      await _abrirCadastro(tester);

      await tester.enterText(find.byKey(_campoProduto), 'Arroz');
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Descartar alterações?'), findsOneWidget);

      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('Novo produto'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(4));
    });
  });

  group('Edição', () {
    testWidgets('altera o registro sem criar duplicata', (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.text('Feijão'));
      await tester.pumpAndSettle();
      expect(find.text('Editar produto'), findsOneWidget);
      expect(_texto(tester, _campoCategoria), 'Alimentos');

      await tester.enterText(find.byKey(_campoProduto), 'Feijão preto');
      await _salvar(tester);

      expect(find.text('Feijão preto'), findsOneWidget);
      expect(find.text('Feijão'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(4));
      expect(find.text('Produto atualizado!'), findsOneWidget);
    });

    testWidgets('salvar sem mudar nada não acusa duplicidade', (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.text('Feijão'));
      await tester.pumpAndSettle();
      await _salvar(tester);

      expect(find.text('Editar produto'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(4));
    });
  });

  group('Exclusão', () {
    testWidgets('remove após confirmar e permite desfazer', (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      expect(find.text('Deseja remover "Feijão" da lista?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Feijão'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(3));

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(4));

      // O item volta para a posição original (primeiro da lista).
      final feijao = tester.getTopLeft(find.text('Feijão')).dy;
      final leite = tester.getTopLeft(find.text('Leite integral')).dy;
      expect(feijao, lessThan(leite));
    });

    testWidgets('cancelar mantém o produto', (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Feijão'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('arrastar o item também pede confirmação', (tester) async {
      await _abrirApp(tester);

      await tester.drag(find.text('Detergente'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(
        find.text('Deseja remover "Detergente" da lista?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Detergente'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });

  group('Regras', () {
    test('normalizar remove acentos, maiúsculas e espaços extras', () {
      expect(normalizar('  FEIJÃO   Preto '), 'feijao preto');
      expect(normalizar('Laticínios'), 'laticinios');
      expect(normalizar('Açúcar'), 'acucar');
    });

    test('mesmoConteudo compara os três campos', () {
      const a = Produto(
          id: 1, nome: 'Feijão', categoria: 'Alimentos', unidade: 'Pacote');
      const igual = Produto(
          id: 2, nome: 'feijao', categoria: 'ALIMENTOS', unidade: ' pacote ');
      const outraUnidade =
          Produto(id: 3, nome: 'Feijão', categoria: 'Alimentos', unidade: 'Kg');

      expect(a.mesmoConteudo(igual), isTrue);
      expect(a.mesmoConteudo(outraUnidade), isFalse);
    });
  });
}
