# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Identity

**Next Breath** — an iOS breath pacer app built by StudioNext. Pivoted from "Socratic Journal" (AI journaling) to a science-backed breathing companion inspired by James Nestor's *Breath*.

- **App Store name:** Next Breath
- **Bundle ID:** `com.StudioNext.socraticJournal` — do NOT rename without coordinating across project.yml, entitlements, and GoogleService-Info.plist
- **Xcode target/scheme:** `SocraticJournal`
- **Min iOS:** 17.0 | **Swift:** 5.9 | **Version:** 1.5.0 (build 1)

## Build Commands

```bash
# Generate Xcode project (required after changing project.yml)
xcodegen generate

# Build
xcodebuild -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run tests
xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

The project uses **XcodeGen** — the `.xcodeproj` is generated from `project.yml`. Always run `xcodegen generate` after modifying `project.yml`. The `Package.swift` exists for SPM compatibility but the app is built via XcodeGen.

No tests exist yet (`Tests/SocraticJournalTests/` is empty). The test target is configured in `project.yml`.

## Architecture

Clean Architecture under `Sources/SocraticJournal/`:

| Layer | Path | Contains |
|-------|------|----------|
| **App** | `App/` | Entry point (`SocraticJournalApp.swift`), Firebase env config (`Environment.swift`) |
| **Domain** | `Domain/` | Entities, repository protocols, service protocols — no implementations |
| **Data** | `Data/` | Repository implementations (UserDefaults), analytics, notifications, network monitor |
| **Presentation** | `Presentation/` | SwiftUI views + `@Observable` ViewModels, organized by feature folder |

### Key Patterns

- **`@Observable` (not `@StateObject`)** — ViewModels use Swift 5.9 observation. In views, ViewModels are held as `@State`, not `@StateObject`/`@ObservedObject`.
- **`BreathPacingEngine`** — Core engine, `@Observable @MainActor`. Uses `CADisplayLink` (30-60fps) for phase transitions. Must stay `@MainActor`.
- **All persistence is UserDefaults** — no cloud sync, no user accounts. Repositories: `UserDefaultsBreathSessionRepository`, `UserDefaultsSettingsRepository`.
- **Navigation:** 3 tabs (Today/Breathe/Learn) via `MainTabView`. Cross-tab handoff uses `pendingPatternId`/`pendingDuration` bindings.
- **Sheets:** BOLT test and Progress from `TodayView`; Training exercises from `LearnView`.

### Dependencies

Firebase only (via SPM): `FirebaseAnalytics`, `FirebaseFirestore`, `FirebaseFunctions`, `FirebaseMessaging`. The app operates primarily offline.

## Design Tokens

| Token | Value |
|-------|-------|
| Background | `#FAF7F2` (warm cream) |
| Surface | `#F2EDE4` |
| Accent (teal) | `#2D5F5D` |
| Accent2 (coral) | `#C4502A` |
| Text Primary | `#1C1710` |
| Border | `#D8D0C4` |

Theme system in `Presentation/Theme/` — `AppColors`, `AppTypography`, `AppSpacing`, `AppShapes`, `ThemeManager`. Dark mode via `ThemeManager` (`ThemeMode`: light/dark/system). Font: SF Pro Rounded + system serif for headings.

## Firebase Configuration

- `Configuration/Debug.xcconfig` — set `FIREBASE_USE_EMULATOR = YES/NO` to toggle emulator
- `Configuration/Release.xcconfig` — always production
- xcconfig values → `Info.plist` → `AppEnvironment.swift` reads them at runtime

```bash
# Run emulator
cd Firebase/functions && npm run serve

# Deploy functions
cd Firebase/functions && npx firebase deploy --only functions
```

Firebase project: `socratic-journal` (see `Firebase/.firebaserc`). Cloud functions in `Firebase/functions/src/index.ts` are mostly legacy from the Socratic Journal era.

## Domain Quick Reference

- **8 breathing patterns** defined in `BreathPattern.swift` (Resonance, Coherent, Box, 4-7-8, Physiological Sigh, Buteyko, Tummo, Alternate Nostril)
- **3 programs** in `ProgramData.swift` (14-Day Nasal Reset, 7-Day Sleep, 10-Day Stress Resilience)
- **4 training exercises** in `TrainingData.swift`
- **BOLT score** (Body Oxygen Level Test) with 5 tiers in `BOLTScore.swift`
- **Learn content** — 4 chapters, 12 articles in `LearnContent.swift`
- Phase colors: teal=inhale, green=hold, coral=exhale
- Haptics: `UIImpactFeedbackGenerator` at phase transitions (togglable in settings)
