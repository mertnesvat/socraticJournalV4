# Rumi Breathing — Project Guide

## Overview

**Rumi Breathing** is an iOS breath pacer app built by StudioNext. The app pivoted from "Socratic Journal" (AI journaling) to a science-backed breathing practice companion inspired by James Nestor's *Breath*. The bundle ID and Xcode target still use the `SocraticJournal` name (do not change without a coordinated rename effort across project.yml, entitlements, and GoogleService-Info.plist).

**App name in stores:** Rumi Breathing
**Bundle ID:** `com.StudioNext.socraticJournal`
**Xcode target:** `SocraticJournal`
**Min iOS:** 17.0
**Version:** 1.4.0 (build 9)

---

## Architecture

Clean Architecture layers under `Sources/SocraticJournal/`:

- `App/` — App entry point (`SocraticJournalApp.swift`) and `Environment.swift` (Firebase env config)
- `Domain/` — Entities + repository/service protocols
- `Data/` — Repository implementations (UserDefaults), analytics, notifications, network monitor
- `Presentation/` — SwiftUI views + `@Observable` ViewModels, organised by feature

### Key Domain Entities

| Entity | Purpose |
|--------|---------|
| `BreathPattern` | One of 8 patterns (Resonance, Coherent, Box, 4-7-8, Physiological Sigh, Buteyko, Tummo, Alternate Nostril) |
| `BreathPhase` | A single inhale/hold/exhale/inhaleTopUp phase within a pattern |
| `BreathSession` | A completed practice session (patternId, duration, cycles) |
| `BOLTScore` | Body Oxygen Level Test result with tier classification |
| `Program` + `ProgramDay` | Multi-day guided program (14-day, 7-day, 10-day) |
| `UserSettings` | Daily goal, reminders, haptics, theme, onboarding state |

### Navigation (3 tabs)

| Tab | Screen | Purpose |
|-----|--------|---------|
| Today | `TodayView` | Greeting, streak, week grid, BOLT card, today's sessions, daily goal ring |
| Breathe | `BreatheView` | Pattern selector, wave animator, pacing controls, session complete overlay |
| Learn | `LearnView` | Programs carousel, training exercises, quick facts strip, 4-chapter science library |

### Core Engine

`BreathPacingEngine` — `@Observable @MainActor` class. Uses `CADisplayLink` at 30–60fps to drive phase transitions, progress, and countdown. Supports pause/resume with `pauseAccumulator`. Phase colour changes per type (teal=inhale, green=hold, coral=exhale).

### The 8 Breathing Patterns

| Pattern | Timing | Tag | Difficulty |
|---------|--------|-----|-----------|
| Resonance | 5.5·5.5 | HRV · Default | Beginner |
| Coherent | 6·6 | Beginner · Calm | Beginner |
| Box | 4·4·4·4 | Focus · Stress | Beginner |
| 4-7-8 | 4·7·8 | Sleep · Parasympathetic | Intermediate |
| Physiological Sigh | 2+1··8 | Fastest reset | Beginner |
| Buteyko Reduced | 3·3·3 | CO₂ · Asthma | Intermediate |
| Tummo / Power | 30× + hold | Advanced · Energy | Advanced |
| Alternate Nostril | 4·4·4 per side | Balance · Ancient | Intermediate |

### Programs

| Program | Days | Focus |
|---------|------|-------|
| 14-Day Nasal Breathing Reset | 14 | Retrain nasal breathing (Nestor Stanford experiment) |
| Better Sleep in 7 Days | 7 | Sleep onset via parasympathetic activation |
| Stress Resilience | 10 | Acute rescue + CO₂ tolerance + HRV baseline |

### Training Exercises (Learn tab)

- **Nose Unblocking** — Buteyko CO₂ technique to clear congestion without medication
- **Breath Awareness** — Tongue posture, chest vs belly, breath rate self-assessment
- **Mouth Tape Readiness** — Guided nasal-only breathing intro (60-second test)
- **CO₂ Tolerance Builder** — 5-round progressive hold exercise

### BOLT Score

Body Oxygen Level Test: time-after-exhale until first urge to breathe. Tiers: VeryLow (<10s), BelowAverage (10–20s), Average (20–30s), Good (30–40s), Excellent (40s+). Stored via `BreathSessionRepositoryProtocol` (UserDefaults implementation).

---

## Design Language

**Theme:** Warm cream editorial with teal accent, serif headings, hairline grid dividers.

| Token | Value |
|-------|-------|
| Background | `#FAF7F2` (warm cream) |
| Surface | `#F2EDE4` |
| Accent (teal) | `#2D5F5D` |
| Accent2 (coral) | `#C4502A` |
| Text Primary | `#1C1710` |
| Border | `#D8D0C4` |
| Font | SF Pro Rounded + system serif for headings |

---

## Firebase Configuration

### Environment Switching (Emulator vs Production)

**Configuration Files:**
- `Configuration/Debug.xcconfig` — Debug build settings
- `Configuration/Release.xcconfig` — Release build settings (always production)

**To switch to emulator (Debug builds):**
```
// In Configuration/Debug.xcconfig
FIREBASE_USE_EMULATOR = YES
```

**To switch to production (Debug builds):**
```
// In Configuration/Debug.xcconfig
FIREBASE_USE_EMULATOR = NO
```

Release builds always use production Firebase (hardcoded in Release.xcconfig).

### How It Works

1. xcconfig values are injected into `Info.plist` via variable substitution
2. `AppEnvironment.swift` reads `FirebaseUseEmulator`, `FirebaseEmulatorHost`, `FirebaseFunctionsEmulatorPort`
3. Firebase services check `AppEnvironment.Firebase.useEmulator` to configure the emulator

### Running the Firebase Emulator

```bash
cd Firebase/functions
npm run serve
```

This starts the emulator at:
- Functions: http://127.0.0.1:5001
- Firestore: http://127.0.0.1:8080
- Auth: http://127.0.0.1:9099

### Deploying Firebase Functions

```bash
cd Firebase/functions
npx firebase deploy --only functions
```

Default project: `socratic-journal` (configured in `Firebase/.firebaserc`)

---

## Data Persistence

All data is stored **locally** via `UserDefaults` — no user accounts, no cloud sync.

| Repository | What it stores |
|-----------|---------------|
| `UserDefaultsBreathSessionRepository` | `BreathSession` array, `BOLTScore` array |
| `UserDefaultsSettingsRepository` | `UserSettings` (goal, theme, haptics, reminders, onboarding, readArticles) |

---

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the app
xcodebuild -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## File Locations

```
Sources/SocraticJournal/
├── App/                    # Entry point, Firebase env
├── Domain/
│   ├── Entities/           # BreathPattern, BreathSession, BOLTScore, Program, User, UserSettings, DailyLog
│   ├── Repositories/       # BreathSessionRepositoryProtocol, SettingsRepositoryProtocol
│   └── Services/           # AnalyticsServiceProtocol, NotificationServiceProtocol
├── Data/
│   ├── Repositories/       # UserDefaults implementations
│   └── Services/           # Firebase analytics, notifications, AppsFlyer, NetworkMonitor
└── Presentation/
    ├── Breathe/            # BreatheView, BreatheViewModel, BreathPacingEngine, components
    ├── Today/              # TodayView, TodayViewModel, components
    ├── Learn/              # LearnView, LearnContent, components
    ├── BOLT/               # BOLTTestView, BOLTInstructionsPage, BOLTTimerPage, BOLTResultPage
    ├── Programs/           # ProgramDetailView, ProgramViewModel, ProgramData
    ├── Training/           # TrainingFlowView, TrainingViewModel, TrainingData
    ├── Progress/           # ProgressHistoryView, ProgressViewModel, components
    ├── Settings/           # SettingsView, SettingsViewModel, components
    ├── Onboarding/         # NewOnboardingView (3-page swipeable)
    ├── Navigation/         # MainTabView (Today/Breathe/Learn)
    ├── Theme/              # AppColors, AppTypography, AppSpacing, AppShapes, ThemeManager
    └── Resources/          # Assets.xcassets, wisdom_quotes.json
```

---

## Firebase Cloud Functions (Legacy — minimal use)

Located in `Firebase/functions/src/index.ts`. Most functions are from the Socratic Journal era. The Breathe app operates primarily offline.

| Function | Status |
|----------|--------|
| `helloWorld` | Health check |
| Others | Legacy — not actively used by Breathe app |

---

## Analytics

`FirebaseAnalyticsService` + `AppsFlyerService`. Logged via `AnalyticsServiceProtocol`. Events tracked via `AnalyticsEvent` enum (see `Data/Services/FirebaseAnalyticsService.swift`).

---

## Notes for Development

- The app uses `@Observable` (Swift 5.9 observation framework) — ViewModels are `@State` in views, not `@StateObject`
- `BreathPacingEngine` is `@MainActor` and must remain so (CADisplayLink runs on main)
- Program → Breathe tab handoff uses `pendingPatternId` / `pendingDuration` bindings on `MainTabView`
- BOLT test and Progress are presented as sheets from `TodayView`
- Training exercises are presented as sheets from `LearnView`
- Dark mode supported via `ThemeManager` (`ThemeMode`: light/dark/system)
- Haptic rhythm: `UIImpactFeedbackGenerator` at phase transitions if enabled in settings
