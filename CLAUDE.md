# CLAUDE.md

Diretivas para trabalhar no repositório do Sortix. Leia este arquivo antes de qualquer tarefa e siga-o em todo código, teste, comentário e commit.

## O projeto

Sortix é um app para iPhone que organiza amigo secreto sem cadastro. O organizador cria o grupo, cadastra participantes e restrições, faz o sorteio no próprio iPhone e envia um link pessoal para cada participante. O participante abre o link no app ou no site, revela quem tirou e cadastra sugestões de presente.

A especificação completa da v1 é `docs/SPEC.md`. Ela é a fonte da verdade para regras de negócio (RN-01 a RN-56), telas, fluxos, modelo de dados, contratos das Functions e testes. **Quando o código e a especificação divergirem, um dos dois está errado: corrija o código ou atualize a especificação no mesmo commit.** Antes de implementar uma tela ou um fluxo, leia a seção correspondente da especificação.

## Padrão de qualidade

Este projeto segue boas práticas de engenharia como regra, não como opção. Na dúvida entre o caminho rápido e o caminho correto, escolha o correto:

- Código organizado, testável e com as decisões documentadas.
- Responsabilidades separadas por camada, sem atalhos que quebrem a arquitetura.
- Dependências injetadas, nunca globais.
- Nenhum texto de interface no código, nenhum valor visual solto.
- Acessibilidade, modo escuro e Dynamic Type fazem parte de toda tela, não são etapa posterior.
- Toda lógica de domínio tem teste.
- SwiftLint sem erros antes de considerar qualquer tarefa concluída.

Não introduza dependências, frameworks ou padrões novos sem necessidade clara. Se uma tarefa exigir sair destas diretivas, pare e pergunte antes.

## Identidade e configuração

| Item | Valor |
|---|---|
| Bundle ID | `br.com.sortixamigosecreto.app.Sortix` |
| Domínio | `sortixamigosecreto.com.br` |
| Projeto Firebase | `sortix-amigo-secreto`, região `southamerica-east1` |
| iOS mínimo | 17.0 |
| Dispositivos | Somente iPhone, somente retrato |
| Idioma | pt-BR (idioma de desenvolvimento), preparado para outros |
| Ferramentas | Xcode 26 ou mais recente, Swift 6 (modo de linguagem 6, concorrência estrita) |
| Dependências (SPM) | Firebase iOS SDK (FirebaseAuth, FirebaseFirestore, FirebaseFunctions, FirebaseCrashlytics) e SwiftLintPlugins. Nada além disso sem discussão |
| Backend | Firebase: Auth anônimo, Firestore, Cloud Functions 2ª geração em TypeScript, Hosting |

Se as configurações do projeto Xcode divergirem desta tabela (bundle ID, deployment target, família de dispositivos, versão do Swift, isolamento padrão), a tabela vale.

## Princípios de produto

Nunca viole estes princípios, mesmo que a tarefa pareça pedir:

1. **Nenhum cadastro, nunca.** Autenticação anônima invisível. Não existe login. A recuperação do organizador usa um link.
2. **O participante não precisa instalar nada.** Todo o fluxo do participante funciona no site.
3. **O organizador participa sem ver quem tirou quem.** A interface nunca exibe o resultado de outra pessoa. O app nunca exibe, registra em log ou guarda o resultado do sorteio no aparelho.
4. **Simples e rápido.** Nenhum campo além do necessário.
5. **Nativo e acessível.** Listas agrupadas do iOS, modo escuro, Dynamic Type e VoiceOver.
6. **Pronto para outros idiomas.** Nenhum texto de interface no código; datas, moeda e números formatados pelo locale.

Tokens, atribuições, nomes e sugestões nunca aparecem em logs, Crashlytics ou console (RN-55).

## Estrutura do repositório

Monorepo com app, backend e site (detalhes na seção 7 da especificação):

- `ios/Sortix/` com `App/`, `Core/`, `Domain/`, `Models/`, `Services/`, `Features/`, `DesignSystem/`, `Extensions/` e `Resources/`.
- `ios/SortixTests/` espelhando as pastas testadas, mais `Mocks/` e `Support/`.
- `backend/` com `firestore.rules`, `firestore.indexes.json` e `functions/` (TypeScript).
- `web/` com o site estático (HTML + JavaScript sem framework).
- `shared/test-vectors/` com vetores JSON lidos pelos testes Swift e TypeScript.
- `scripts/` com scripts de verificação.

Regras de arquivo:

- Cada cena fica em `Features/<Fluxo>/Scenes/<Cena>/` com `<Cena>View.swift`, `<Cena>ViewController.swift`, `<Cena>ViewModel.swift` e `<Cena>State.swift`. O enum `Navigation` fica aninhado no ViewModel.
- Um tipo principal por arquivo, com o nome do arquivo igual ao do tipo. Extensões seguem `Tipo+Assunto.swift`.
- `GoogleService-Info.plist` nunca entra no Git.

## Arquitetura: UIKit em View Code com MVVM-C

Sem storyboards nem SwiftUI. Interface 100% em View Code com Auto Layout.

| Camada | Faz | Nunca faz |
|---|---|---|
| View (`UIView`) | Hierarquia de subviews, Auto Layout com tokens, `configure(with:)` para dados já prontos | Regra de negócio, chamada a serviço, texto literal |
| ViewController | Cria a View, liga-se ao ViewModel, implementa `render(_ state:)`, repassa ações, apresenta alertas simples, posta notificações de acessibilidade | Regra de negócio, chamada a serviço, decidir navegação |
| ViewModel (`@MainActor`) | Estado da tela, validação (pelo Domain), chamadas a serviços, formatação com `Locale` injetado, eventos de navegação | `import UIKit`, guardar referência a ViewController ou Coordinator |
| Coordinator (`@MainActor`) | Cria cenas, injeta dependências, navega, apresenta controladores do sistema (compartilhar, contatos, Safari), gerencia filhos | Regra de negócio, estado de tela |
| Service | Acesso ao Firebase atrás de protocolo, conversão DTO ↔ Model, conversão de erros | Conhecer UIKit ou telas |
| Domain | Sorteio, validações, normalização, parsing de valor monetário | Importar UIKit ou Firebase, fazer I/O |
| Models | Tipos de valor `Sendable` e `Equatable` | I/O ou dependência de framework de UI |
| DesignSystem | Tokens e componentes visuais | Conhecer features ou serviços |

Somente `Services` e `App` importam Firebase.

### Comunicação

Padrão único no app inteiro, com closures:

- **ViewModel → View:** um único `State` por tela (`Equatable`), publicado por `onStateChange`. A ViewController tem um único `render(_:)`, que funciona em qualquer ordem de estados.
- **ViewModel → Coordinator:** enum `Navigation` aninhado no ViewModel, publicado por `onNavigation`. O coordinator trata com `switch` exaustivo, sem `default`.
- **Ações do usuário:** métodos do ViewModel com prefixo `didTap`, `didSelect`, `didChange` ou `didConfirm`.
- **Controladores do sistema:** o caso de `Navigation` carrega uma closure de retorno (ex.: `case share(ShareContent, onCompleted: @MainActor () -> Void)`).
- **Toda closure é atribuída com `[weak self]`.**
- Não use delegates por tela nem Combine para essa comunicação.

### Coordinators e navegação

- `AppCoordinator` (raiz, roteia Universal Links), `CreateGroupCoordinator` (modal com navegação própria) e `GroupCoordinator` (modos `.organizer`, `.participant`, `.recovery`).
- Coordinators usam o protocolo `NavigationRouting`, nunca `UINavigationController` diretamente. Nos testes, `MockNavigationRouter`.
- Todo coordinator filho é removido do pai quando termina (`onFinish` ou `onPop` da primeira tela).
- Cenas são criadas em métodos privados `make<Cena>Scene()`, passando ao ViewModel **somente** os protocolos de que ele precisa.

### Injeção de dependências

- Não há singletons (`static let shared` é proibido). As instâncias do Firebase são obtidas em um único lugar, `AppDependencies.live()`, e entregues pelos inicializadores.
- Todo serviço tem protocolo (`<Área>ServiceProtocol`) e mock correspondente em `SortixTests/Mocks/`. Os protocolos estão na seção 6.5 da especificação.

### Concorrência

- Swift 6 com checagem estrita. **Default Actor Isolation: `nonisolated`.** Marque `@MainActor` explicitamente em ViewControllers, ViewModels, coordinators, `NavigationRouter` e `LocalSettingsStore`.
- Models e tipos do Domain são structs e enums `Sendable`.
- Serviços são `Sendable` com métodos `async`. Listeners do Firestore viram `AsyncThrowingStream`, e `onTermination` remove o listener.
- `DrawService.draw(_:)` é `@concurrent`, para rodar fora da main thread.
- Toda `Task` criada por um ViewModel fica guardada numa propriedade e é cancelada no `deinit` ou quando perde sentido.
- Não use `@unchecked Sendable`, `nonisolated(unsafe)` ou `DispatchQueue` para contornar avisos de concorrência. Corrija o isolamento.

### Erros

- `ValidationError` (Domain), `DrawFailure` (Domain) e `ServiceError` (Services, via `FirebaseErrorMapper`).
- O ViewModel guarda o erro tipado no estado. A ViewController converte em texto com `ErrorMessageMapper` (`switch` exaustivo que devolve `LocalizedStringResource`).
- Testes verificam o tipo do erro, nunca o texto.
- Erros inesperados vão para o Crashlytics como não fatais, com contexto só de códigos (`reason`, nome da Function, nome da tela).

## Interface

- **Listas dinâmicas:** `UICollectionView` com `UICollectionViewCompositionalLayout.list(using:)`, aparência `.insetGrouped`, `UICollectionViewDiffableDataSource`, `CellRegistration` com `UICollectionViewListCell` e `UIListContentConfiguration`. Não use `UITableView`.
- **Formulários fixos:** `FormScrollView` com componentes do Design System (`FormSectionView`, `TextFieldRow`, `TextViewRow`, `ToggleRow`, `DatePickerRow`, `CurrencyFieldRow`). Teclado com `view.keyboardLayoutGuide`.
- **Estados vazio, carregando e erro:** `UIContentUnavailableConfiguration`.
- **Botão principal:** `PrimaryButton`, preso à área segura inferior, com `showsActivityIndicator` durante operações.
- **Títulos:** `prefersLargeTitles` só na lista de grupos.
- **Links externos:** `SFSafariViewController`.

### Design System

Valores visuais existem só em `DesignSystem/Tokens`: `ColorToken`, `TypographyToken`, `SpacingToken`, `RadiusToken`, `IconToken`. Fora do Design System, nada de `UIColor(red:...)`, `systemFont(ofSize:)`, `UIFont(name:)`, raios ou constantes de layout numéricas. Cores do Asset Catalog pelos símbolos gerados (`UIColor(resource: .accent)`), nunca por string.

### Acessibilidade

Siga a tabela da seção 6.10 da especificação. O essencial:

- Todo botão só com ícone, todo campo e todo container agrupado tem `accessibilityLabel` vindo do String Catalog.
- Labels curtos, com inicial maiúscula, sem ponto final e sem o tipo do elemento.
- Containers agrupados usam chave de formato, nunca concatenação com `+`; botões internos viram `accessibilityCustomActions`.
- Mudança de conteúdo na mesma tela posta `.layoutChanged`; confirmações passageiras postam `.announcement`.
- Dynamic Type: fontes só pelos tokens, `adjustsFontForContentSizeCategory = true`, `numberOfLines = 0` quando o texto pode quebrar, nenhuma altura fixa em view com texto, área de toque mínima de 44×44 pt.
- `accessibilityIdentifier` é constante em inglês e não é localizado.

## Localização

- Nenhum texto de interface no código Swift, HTML ou JavaScript, inclusive alertas, erros e textos de acessibilidade.
- Textos ficam em `Resources/Localizable.xcstrings` e são acessados **só** pelos símbolos gerados pelo String Catalog: `String(localized: .groupListEmptyTitle)`. `String(localized: "…")`, `NSLocalizedString` e literais em propriedades de interface são proibidos.
- Chaves no formato `<área>.<componente>.<elemento>[.<variação>]`, em camelCase por segmento, com os sufixos padronizados da seção 8.2 da especificação. Toda chave tem comentário para tradutores.
- Contagens usam `%lld` com variação de plural. Nunca concatene número e palavra.
- Listas de nomes com `ListFormatStyle`; datas e moeda formatadas com `Locale` e `Calendar` injetados; nunca escreva "R$" no código. Dinheiro é `Money(amountMinor:currencyCode:)`.
- O servidor nunca devolve texto ao usuário, só códigos de motivo (`reason`).
- No site, todo texto entra no DOM por `textContent`; `innerHTML` e equivalentes são proibidos.

## Comentários

- Código e comentários em inglês. Documentação do projeto (`docs/`, este arquivo) em português.
- Comentários explicam o porquê, nunca o quê.
- `///` em tipos e métodos usados por outras camadas e em todo comportamento não óbvio (pré-condições, complexidade, efeitos colaterais).
- Proibido: código comentado, comentários decorativos (`---`, `***`, `===`) e o cabeçalho "Created by…" gerado pelo Xcode.
- `// MARK: - Seção` é permitido.
- TODO e FIXME só como `// TODO(<contexto>): <o que falta e por quê>`, com pelo menos 15 caracteres de explicação.
- Comentários didáticos seguem exatamente `// LEARNING: <explicação> — remove after code review`. Eles aparecem como aviso e precisam ser removidos antes do merge para a branch principal e antes de qualquer build de TestFlight ou App Store (`scripts/check-learning-comments.sh`).

## SwiftLint

- Instalado pelo pacote `SwiftLintPlugins` como build tool plugin nos targets `Sortix` e `SortixTests`. Configuração em `.swiftlint.yml` na raiz (conteúdo completo na seção 9.3 da especificação).
- As regras customizadas reforçam a arquitetura: sem UIKit em ViewModels, Domain puro, Firebase só em Services e App, sem singletons, sem `print` (use `AppLogger`), só tokens de design, só localização tipada.
- Código novo não pode gerar erros. Não desative regras para fazer passar. Um falso positivo isolado pode ser silenciado com `// swiftlint:disable:next <regra>`, sempre com o motivo no mesmo comentário.
- Limites de referência: linha 120, função 40 linhas, tipo 300 linhas, arquivo 400 linhas, complexidade ciclomática 10. Sem `!` de force unwrap nem optionals implicitamente desembrulhados.

## Logs

- Logs com `os.Logger` por meio de `AppLogger`, com categorias por área. Valores dinâmicos sempre com `privacy: .private`.
- Nas Functions e no site, sem `console.log`; use o logger das Functions.

## Testes

- Framework: **Swift Testing** (`import Testing`, `@Test`, `#expect`, testes parametrizados). XCTest só para medição de desempenho.
- Toda lógica do Domain tem testes unitários: `DrawEngine` (casos T1 a T16 da seção 10.8), `AssignmentValidator`, validadores, normalizadores, `CurrencyInputParser` e `DeepLinkParser`.
- Toda cena tem teste de vazamento de memória (ViewController e ViewModel viram `nil` depois de liberados).
- Testes de sorteio usam `SeededRandomNumberGenerator` com semente fixa; produção usa `SystemRandomNumberGenerator`.
- Datas, calendário, relógio e locale são injetados para os testes usarem valores fixos.
- Regras que existem no app e no servidor (normalização, contagem de caracteres por grafema, validação de sugestões) são conferidas pelos vetores em `shared/test-vectors/`. Os limites de campos são idênticos em `FieldLimits` (Swift) e `limits.ts` (TypeScript).
- Functions são testadas com Vitest, com a lógica em `domain/` testável sem Firebase.

## Backend e site

- Cloud Functions 2ª geração, TypeScript, todas `onCall`, região `southamerica-east1`. Um arquivo por Function em `handlers/`, lógica em `domain/`, acesso a dados em `data/`.
- Toda entrada é validada por esquema antes de qualquer leitura; campos desconhecidos são rejeitados.
- O servidor revalida o sorteio (RN-18 a RN-21) antes de gravar. O app nunca lê a coleção de atribuições.
- Site estático em HTML e JavaScript sem framework, com textos em `web/locales/<idioma>.json`.

## Definição de pronto

Uma tela ou funcionalidade só está pronta quando:

- [ ] Todos os estados (carregando, vazio, erro, sucesso) estão implementados.
- [ ] Nenhum texto está fora do String Catalog.
- [ ] Modo escuro e maior tamanho de texto funcionam.
- [ ] Os itens de acessibilidade da tela estão aplicados.
- [ ] Os testes passam, incluindo o de vazamento de memória.
- [ ] O SwiftLint não aponta erros.
- [ ] Não há comentário `LEARNING` pendente antes do merge para a branch principal.
- [ ] A especificação continua coerente com o código.

## Fluxo de trabalho

- Desenvolvimento na branch `dev`; pull requests apontam para `dev`.
- Commits pequenos, com mensagem clara descrevendo o que muda e por quê.
- Fora do escopo da v1 (seção 19 da especificação): editar grupo ou refazer sorteio, notificações, iPad, outros idiomas, App Check, login de qualquer tipo. Não implemente esses itens sem pedido explícito.
