# Mercado App

Aplicativo Flutter para gerenciar registros de um mercado localmente (CMP2304 – P3).

Cada registro tem três campos de texto obrigatórios: **Produto**, **Categoria** e **Unidade**.

## Funcionalidades

- **Listagem**: produtos em lista, com o Produto como título e Categoria/Unidade como informações complementares.
- **Cadastro**: botão "+ Novo" abre o formulário para salvar um novo registro.
- **Edição**: tocar em um item abre o formulário preenchido; ao salvar, o registro é alterado sem criar duplicata.
- **Exclusão**: ícone de lixeira remove o item (com confirmação).
- **Validação**: impede salvar campos vazios ou só com espaços; a lista atualiza logo após cada operação.

Dados mantidos em uma lista em memória, usando `StatefulWidget`, `setState` e navegação entre telas (`Navigator`).

## Como executar

```bash
flutter create .
flutter pub get
flutter run
```

(`flutter create .` gera as pastas de plataforma — android, ios, web etc. — sem alterar o `lib/main.dart`.)

Para rodar os testes:

```bash
flutter test
```
