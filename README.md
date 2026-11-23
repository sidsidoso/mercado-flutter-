# Mercado App

Aplicativo Flutter para gerenciar registros de um mercado localmente (CMP2304 – P3).

Cada registro tem três campos de texto obrigatórios: **Produto**, **Categoria** e **Unidade**.

## Funcionalidades

### Requisitos da atividade

- **Listagem**: produtos em lista, com o Produto como título e Categoria/Unidade como informações complementares.
- **Cadastro**: botão "+ Novo" abre o formulário para salvar um novo registro.
- **Edição**: tocar em um item abre o formulário preenchido; ao salvar, o registro é alterado sem criar duplicata.
- **Exclusão**: ícone de lixeira remove o item (com confirmação).
- **Validação**: impede salvar campos vazios ou só com espaços; a lista atualiza logo após cada operação.

### Recursos extras

- **Busca** por produto, categoria ou unidade, ignorando acentos e maiúsculas ("feijao" encontra "Feijão").
- **Filtro por categoria** em chips, com a quantidade de produtos de cada uma.
- **Ordenação** por ordem de cadastro, nome (A–Z / Z–A) ou categoria.
- **Desfazer exclusão** pelo aviso exibido logo após remover um item.
- **Arrastar para excluir**: deslizar o item para a esquerda também pede a confirmação.
- **Bloqueio de duplicados**: não deixa cadastrar o mesmo produto com a mesma categoria e unidade.
- **Sugestões** de categoria e unidade no formulário (um toque preenche o campo).
- **Pré-visualização** do item no formulário enquanto se digita.
- **Aviso de alterações não salvas** ao sair do formulário.
- **Ícone e cor por categoria**, **tema claro/escuro** e layout que se adapta a telas grandes.

Dados mantidos em uma lista em memória, usando `StatefulWidget`, `setState` e navegação entre telas (`Navigator`), sem dependências além do próprio Flutter.

## Estrutura

```
lib/
├── main.dart                         # App e temas (claro/escuro)
├── models/
│   └── produto.dart                  # Modelo do registro
├── pages/
│   ├── lista_produtos_page.dart      # Tela 1: listagem, busca, filtro, exclusão
│   └── formulario_produto_page.dart  # Tela 2: cadastro e edição com validação
├── utils/
│   ├── categoria_visual.dart         # Ícone e cor de cada categoria
│   └── texto.dart                    # Normalização de texto (acentos, espaços)
└── widgets/
    ├── avatar_categoria.dart
    ├── estado_vazio.dart
    └── etiqueta.dart
test/
└── widget_test.dart                  # Testes de listagem, cadastro, edição e exclusão
```

## Como executar

```bash
flutter create .
flutter pub get
flutter run
```

(`flutter create .` gera as pastas de plataforma — android, ios, web etc. — sem alterar o conteúdo de `lib/`.)

Para rodar os testes:

```bash
flutter test
```
