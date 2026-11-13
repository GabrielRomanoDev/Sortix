# CLAUDE.md

Directives for working in the Sortix repository. Read this file before any task and follow it in all code, tests, comments and commits.

## The project

Sortix is an iPhone app that organizes Secret Santa ("amigo secreto") without sign-up. The organizer creates the group, adds participants and restrictions, runs the draw on their own iPhone and sends a personal link to each participant. The participant opens the link in the app or on the website, reveals who they drew and adds gift suggestions.

The full v1 specification is `docs/SPEC.md`. It is the source of truth for business rules (BR-01 to BR-56), screens, flows, data model, Cloud Functions contracts and tests. **When the code and the specification disagree, one of them is wrong: fix the code or update the specification in the same commit.** Before implementing a screen or a flow, read the matching section of the specification.

## Language

- **Everything in the repository is written in English:** code, identifiers, comments, documentation (`docs/`, this file, README), commit messages and pull requests.
- **The only exception is user-facing text.** pt-BR (and any future language) appears only in `Localizable.xcstrings`, `InfoPlist.xcstrings`, `web/locales/<language>.json` and the localized static pages of the website.
- Localization keys, `accessibilityIdentifier` values and String Catalog comments are in English.

## Quality standard

This project treats engineering best practices as the rule, not as an option. When in doubt between the quick path and the correct path, choose the correct one:

- Organized, testable code with documented decisions.
- Responsibilities separated by layer, with no shortcuts that break the architecture.
- Dependencies injected, never global.
- No user-facing text in code, no loose visual values.
- Accessibility, dark mode and Dynamic Type are part of every screen, not a later step.
- All domain logic is tested.
- The simplest code that meets these rules. Avoid overly abstract layers: no extra layers, generic helpers or edge-case handling the app does not need yet. The code should read well to a developer moving from junior to mid-level.
- Simple does not mean fewer functions. Keep initializers short: they call small, named functions with one responsibility each, such as `setUpLayout()`, `setUpTextField()` and `setTexts(...)`. Never inline the body of those functions into `init`. Text is always set by its own function (`setTexts(...)` or `configure(...)`).

Do not introduce new dependencies, frameworks or patterns without a clear need. If a task requires stepping outside these directives, stop and ask first.

## Identity and configuration

| Item | Value |
|---|---|
| Bundle ID | `br.com.sortixamigosecreto.app.Sortix` |
| Domain | `sortixamigosecreto.com.br` |
| Firebase project | `sortix-amigo-secreto`, region `southamerica-east1` |
| Minimum iOS | 17.0 |
| Devices | iPhone only, portrait only |
| Language | pt-BR (development language), ready for others |
| Tooling | Xcode 26 or later, Swift 6 (language mode 6, strict concurrency) |
| Dependencies (SPM) | Firebase iOS SDK (FirebaseAuth, FirebaseFirestore, FirebaseFunctions, FirebaseCrashlytics). Nothing else without discussion |
| Backend | Firebase: anonymous Auth, Firestore, 2nd gen Cloud Functions in TypeScript, Hosting |

If the Xcode project settings diverge from this table (bundle ID, deployment target, device family, Swift version, default isolation), the table wins.

## Product principles

Never violate these principles, even if a task seems to ask for it:

1. **No sign-up, ever.** Invisible anonymous authentication. There is no login. Organizer recovery uses a link.
2. **Participants don't need to install anything.** The whole participant flow works on the website.
3. **The organizer takes part without seeing who drew whom.** The interface never shows someone else's result. The app never displays, logs or stores the draw result on the device.
4. **Simple and fast.** No field beyond what is needed.
5. **Native and accessible.** iOS grouped lists, dark mode, Dynamic Type and VoiceOver.
6. **Ready for other languages.** No user-facing text in code; dates, currency and numbers formatted by locale.

Tokens, assignments, names and suggestions never appear in logs, Crashlytics or the console (BR-55).

## Repository structure

Monorepo with the app, backend and website (details in section 7 of the specification):

- `ios/Sortix/` with `App/`, `Core/`, `Domain/`, `Models/`, `Services/`, `Features/`, `DesignSystem/`, `Extensions/` and `Resources/`.
- `ios/SortixTests/` mirroring the tested folders, plus `Mocks/` and `Support/`.
- `backend/` with `firestore.rules`, `firestore.indexes.json` and `functions/` (TypeScript).
- `web/` with the static website (HTML + JavaScript, no framework).
- `shared/test-vectors/` with JSON vectors read by both the Swift and TypeScript tests.
- `scripts/` with verification scripts.

File rules:

- Each scene lives in `Features/<Flow>/Scenes/<Scene>/` with `<Scene>View.swift`, `<Scene>ViewController.swift`, `<Scene>ViewModel.swift` and `<Scene>State.swift`. The `Navigation` enum is nested in the ViewModel.
- One main type per file, with the file named after the type. Extensions follow `Type+Topic.swift`.
- `GoogleService-Info.plist` never goes into Git.

## Architecture: UIKit view code with MVVM-C

No storyboards and no SwiftUI. The interface is 100% view code with Auto Layout.

| Layer | Does | Never does |
|---|---|---|
| View (`UIView`) | Subview hierarchy, Auto Layout with tokens, `configure(with:)` for ready-to-display data | Business rules, service calls, literal text |
| ViewController | Creates the View, binds to the ViewModel, implements `render(_ state:)`, forwards actions, presents simple alerts, posts accessibility notifications | Business rules, service calls, deciding navigation |
| ViewModel (`@MainActor`) | Screen state, validation (through the Domain), service calls, formatting with an injected `Locale`, navigation events | `import UIKit`, holding a reference to a ViewController or Coordinator |
| Coordinator (`@MainActor`) | Builds scenes, injects dependencies, navigates, presents system controllers (share, contacts, Safari), manages children | Business rules, screen state |
| Service | Firebase access behind a protocol, DTO ↔ Model conversion, error conversion | Knowing UIKit or screens |
| Domain | Draw, validation, normalization, currency input parsing | Importing UIKit or Firebase, doing I/O |
| Models | `Sendable` and `Equatable` value types | I/O or UI framework dependencies |
| DesignSystem | Tokens and visual components | Knowing features or services |

Only `Services` and `App` import Firebase.

### Communication

One pattern for the whole app, with closures:

- **ViewModel → View:** a single `State` per screen (`Equatable`), published through `onStateChange`. The ViewController has a single `render(_:)` that works for states in any order.
- **ViewModel → Coordinator:** a `Navigation` enum nested in the ViewModel, published through `onNavigation`. The coordinator handles it with an exhaustive `switch`, without `default`.
- **User actions:** ViewModel methods prefixed with `didTap`, `didSelect`, `didChange` or `didConfirm`.
- **System controllers:** the `Navigation` case carries a completion closure (e.g. `case share(ShareContent, onCompleted: @MainActor () -> Void)`).
- **Every closure is assigned with `[weak self]`.**
- Do not use per-screen delegates or Combine for this communication.

### Coordinators and navigation

- `AppCoordinator` (root, routes Universal Links), `CreateGroupCoordinator` (modal with its own navigation) and `GroupCoordinator` (modes `.organizer`, `.participant`, `.recovery`).
- Coordinators use the `NavigationRouting` protocol, never `UINavigationController` directly. Tests use `MockNavigationRouter`.
- Every child coordinator is removed from its parent when it finishes (`onFinish` or the first screen's `onPop`).
- Scenes are built in private `make<Scene>Scene()` methods, passing the ViewModel **only** the protocols it needs.

### Dependency injection

- There are no singletons (`static let shared` is forbidden). Firebase instances are obtained in a single place, `AppDependencies.live()`, and handed over through initializers.
- Every service has a protocol (`<Area>ServiceProtocol`) and a matching mock in `SortixTests/Mocks/`. The protocols are in section 6.5 of the specification.

### Concurrency

- Swift 6 with strict checking. **Default Actor Isolation: `nonisolated`.** Mark ViewControllers, ViewModels, coordinators, `NavigationRouter` and `LocalSettingsStore` with `@MainActor` explicitly.
- Models and Domain types are `Sendable` structs and enums.
- Services are `Sendable` with `async` methods. Firestore listeners become `AsyncThrowingStream`, and `onTermination` removes the listener.
- `DrawService.draw(_:)` is `@concurrent`, so it runs off the main thread.
- Every `Task` a ViewModel creates is stored in a property and cancelled in `deinit` or when it stops being relevant.
- Do not use `@unchecked Sendable`, `nonisolated(unsafe)` or `DispatchQueue` to silence concurrency diagnostics. Fix the isolation.

### Errors

- `ValidationError` (Domain), `DrawFailure` (Domain) and `ServiceError` (Services, through `FirebaseErrorMapper`).
- The ViewModel keeps the typed error in its state. The ViewController turns it into text with `ErrorMessageMapper` (an exhaustive `switch` returning `LocalizedStringResource`).
- Tests check the error type, never the text.
- Unexpected errors go to Crashlytics as non-fatal, with context made only of codes (`reason`, Function name, screen name).

## Interface

- **Dynamic lists:** `UICollectionView` with `UICollectionViewCompositionalLayout.list(using:)`, `.insetGrouped` appearance, `UICollectionViewDiffableDataSource`, `CellRegistration` with `UICollectionViewListCell` and `UIListContentConfiguration`. Do not use `UITableView`.
- **Fixed forms:** `FormScrollView` with Design System components (`FormSectionView`, `TextFieldRow`, `TextViewRow`, `ToggleRow`, `DatePickerRow`, `CurrencyFieldRow`). Keyboard handled with `view.keyboardLayoutGuide`.
- **Empty, loading and error states:** `UIContentUnavailableConfiguration`.
- **Primary button:** `PrimaryButton`, pinned to the bottom safe area, with `showsActivityIndicator` during operations.
- **Titles:** `prefersLargeTitles` only on the group list.
- **External links:** `SFSafariViewController`.

### Design System

Visual values exist only in `DesignSystem/Tokens`: `ColorToken`, `TypographyToken`, `SpacingToken`, `RadiusToken`, `SizeToken`, `IconToken`. Outside the Design System, no `UIColor(red:...)`, `systemFont(ofSize:)`, `UIFont(name:)`, radii or numeric layout constants. Asset Catalog colors are accessed through generated symbols (`UIColor(resource: .accent)`), never by string.

### Accessibility

Follow the table in section 6.10 of the specification. The essentials:

- Every icon-only button, every field and every grouped container has an `accessibilityLabel` from the String Catalog.
- Labels are short, capitalized, without a trailing period and without the element type.
- Grouped containers use a format key, never `+` concatenation; inner buttons become `accessibilityCustomActions`.
- Content changes on the same screen post `.layoutChanged`; transient confirmations post `.announcement`.
- Dynamic Type: fonts only through tokens, `adjustsFontForContentSizeCategory = true`, `numberOfLines = 0` when text can wrap, no fixed height on views with text, minimum touch target of 44×44 pt.
- `accessibilityIdentifier` is an English constant and is not localized.

## Localization

- No user-facing text in Swift, HTML or JavaScript code, including alerts, errors and accessibility text.
- Texts live in `Resources/Localizable.xcstrings` and are accessed **only** through the symbols generated by the String Catalog: `String(localized: .groupListEmptyTitle)`. `String(localized: "…")`, `NSLocalizedString` and literals assigned to UI properties are forbidden.
- Keys follow `<area>.<component>.<element>[.<variant>]`, camelCase within each segment, with the standard suffixes in section 8.2 of the specification. Every key has an English comment for translators.
- Counts use `%lld` with plural variation. Never concatenate a number and a word.
- Lists of names use `ListFormatStyle`; dates and currency are formatted with injected `Locale` and `Calendar`; never write "R$" in code. Money is `Money(amountMinor:currencyCode:)`.
- The server never returns user-facing text, only reason codes (`reason`).
- On the website, all text enters the DOM through `textContent`; `innerHTML` and equivalents are forbidden.

## Comments

- Comments explain why, never what.
- `///` on types and methods used by other layers and on any non-obvious behavior (preconditions, complexity, side effects).
- Forbidden: commented-out code, decorative comments (`---`, `***`, `===`) and the "Created by…" header Xcode generates.
- `// MARK: - Section` is allowed.
- TODO and FIXME only as `// TODO(<context>): <what is missing and why>`, with at least 15 characters of explanation.
- Teaching comments use exactly `// LEARNING: <explanation> — remove after code review`. They must be removed before merging to the main branch and before any TestFlight or App Store build.

## Code rules

- The architecture rules are checked in code review: no UIKit in ViewModels, pure Domain, Firebase only in Services and App, no singletons, no `print` (use `AppLogger`), design tokens only, typed localization only.
- Reference limits (guidelines, not enforced by a tool): line 120, function 40 lines, type 300 lines, file 400 lines. No force unwrapping and no implicitly unwrapped optionals.

## Logging

- Logs use `os.Logger` through `AppLogger`, with one category per area. Dynamic values always use `privacy: .private`.
- In the Functions and on the website, no `console.log`; use the Functions logger.

## Tests

- Framework: **Swift Testing** (`import Testing`, `@Test`, `#expect`, parameterized tests). XCTest only for performance measurement.
- All Domain logic has unit tests: `DrawEngine` (cases T1 to T16 in section 10.8), `AssignmentValidator`, validators, normalizers, `CurrencyInputParser` and `DeepLinkParser`.
- Every scene has a memory leak test (ViewController and ViewModel become `nil` after being released).
- Draw tests use `SeededRandomNumberGenerator` with a fixed seed; production uses `SystemRandomNumberGenerator`.
- Dates, calendar, clock and locale are injected so tests use fixed values.
- Rules that exist on both the app and the server (normalization, grapheme-based character counting, suggestion validation) are checked by the vectors in `shared/test-vectors/`. Field limits are identical in `FieldLimits` (Swift) and `limits.ts` (TypeScript).
- Functions are tested with Vitest, with the logic in `domain/` testable without Firebase.

## Backend and website

- 2nd gen Cloud Functions, TypeScript, all `onCall`, region `southamerica-east1`. One file per Function in `handlers/`, logic in `domain/`, data access in `data/`.
- Every input is validated against a schema before any read; unknown fields are rejected.
- The server re-validates the draw (BR-18 to BR-21) before writing. The app never reads the assignments collection.
- Static website in HTML and JavaScript without a framework, with texts in `web/locales/<language>.json`.

## Definition of done

A screen or feature is done only when:

- [ ] All states (loading, empty, error, success) are implemented.
- [ ] No text lives outside the String Catalog.
- [ ] Dark mode and the largest text sizes work.
- [ ] The screen's accessibility items are applied.
- [ ] Tests pass, including the memory leak test.
- [ ] No `LEARNING` comment is left before merging to the main branch.
- [ ] The specification is still consistent with the code.

## Workflow

- Development happens on the `dev` branch; pull requests target `dev`.
- Small commits with a clear message describing what changes and why.
- Out of v1 scope (section 19 of the specification): editing a group or redoing the draw, notifications, iPad, other languages, App Check, any kind of login. Do not implement these without an explicit request.
