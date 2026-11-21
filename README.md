🐂 NutriBov - Sistema de Balanceamento Nutricional para Bovinos de Corte
Aplicativo móvel desenvolvido em Flutter e Android Studio como projeto final da disciplina de Dispositivos Móveis 2 do curso de Engenharia de Software (6º período).

O objetivo do aplicativo é auxiliar pecuaristas e técnicos no gerenciamento de alimentos, cálculo de exigências nutricionais baseadas no sistema BR-Corte e formulação de dietas balanceadas para bovinos de corte.

🚀 Funcionalidades Principais
Central de Alimentos: Cadastro e gerenciamento de forragens e insumos, com parâmetros como Matéria Seca (MS), NDT, Proteína Bruta (PB), Cálcio e Fósforo.
Dados do Animal e Exigências: Definição de parâmetros como sistema de produção (pasto ou confinamento), grupo genético, sexo, peso corporal e Ganho Médio Diário (GMD) desejado, com cálculo automático das exigências nutricionais.
Formulação de Rações: Montagem de dietas, cálculo de custos por kg e por animal/dia, além de comparativo em tempo real entre os nutrientes fornecidos e as exigências nutricionais.
Histórico de Dietas: Armazenamento local das formulações para consulta rápida no campo.
🛠️ Tecnologias e Arquitetura
Linguagem: Dart
Framework: Flutter (Material 3)
Ambiente de Desenvolvimento: Android Studio
Arquitetura: Clean Architecture e separação por Features.


## Arquitetura MVVM

| Pasta | Responsabilidade |
|---|---|
| `lib/app/` | Composição do app, navegação e ciclo de vida dos ViewModels |
| `lib/core/design_system/` | Tema Material 3, tokens e componentes de interface |
| `lib/features/` | Views e ViewModels por funcionalidade |
| `lib/domain/` | Entidades do catálogo e calculadoras puras em Dart |
| `lib/data/` | Contrato de repositório e persistência local com SharedPreferences |
| `test/` | Regressão com valores da planilha e cobertura dos perfis de animal |

As Views usam `ListenableBuilder` para reagir aos ViewModels. O estado de formulário fica sob responsabilidade das Views. Os ViewModels, baseados em `ChangeNotifier`, coordenam operações e expõem resultados ou erros. O repositório é injetado no aplicativo e pode ser substituído na futura integração com o backend.

## Design system

- Verde floresta (#193D2C) e verde folha (#396948) na marca e nas ações.
- Palha (#F0DFAB) para destaque, terra (#6C5139) como cor secundária e creme (#F6F5ED) no fundo.
- Escala de espaçamento de 8, 16 e 24 dp. Cartões arredondados, botões de 50 dp e campos com unidade e validação.
- Interface em português do Brasil. Os campos numéricos aceitam vírgula ou ponto decimal.

## Regras e escopo desta etapa

- A aba **BR-CORTE** atende os nove perfis de confinamento da planilha e um perfil de pasto. As equações calculam ganho positivo. Os resultados usam a precisão completa internamente e arredondam apenas na tela.
- Quantidades de ingredientes são em matéria natural. O teor de MS é informado na matéria natural. NDT, PB, cálcio e fósforo são informados na matéria seca. A comparação diária usa a quantidade fornecida pela formulação e as exigências totais do animal na mesma unidade.
- Os alimentos cadastrados persistem no aparelho. O perfil animal e a formulação atual são mantidos enquanto o app está aberto. O backend e seu mock ficam para a etapa seguinte.
- As fórmulas foram traduzidas para Dart a partir da planilha. O exemplo de referência é um cenário acadêmico para demonstrar o funcionamento.
