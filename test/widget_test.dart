import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_app/main.dart';

void main() {
  testWidgets('Lista inicia com o produto de exemplo', (tester) async {
    await tester.pumpWidget(const MercadoApp());
    expect(find.text('Feijão'), findsOneWidget);
  });

  testWidgets('Não salva campos com apenas espaços', (tester) async {
    await tester.pumpWidget(const MercadoApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '   ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o campo Produto'), findsOneWidget);
    expect(find.text('Novo produto'), findsOneWidget);
  });

  testWidgets('Cadastra um novo produto', (tester) async {
    await tester.pumpWidget(const MercadoApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Arroz');
    await tester.enterText(find.byType(TextFormField).at(1), 'Alimentos');
    await tester.enterText(find.byType(TextFormField).at(2), 'Saco 5kg');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Arroz'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
