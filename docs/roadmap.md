# Next Breath — Development Roadmap

*Last updated: 2026-03-06*

---

## Overview

Three tiers of work, ordered by urgency and complexity:

| Tier | Items | Effort |
|------|-------|--------|
| **Now — Cleanup & Platform** | AppsFlyer removal, Widget, Apple Watch | Days–Weeks |
| **Next — Growth Features** | HealthKit, Streaks/Achievements, Sleep Mode | Weeks |
| **Later — Differentiation** | HRV overlay, Audio guidance, Community | Months |

---

## NOW — Immediate

---

### 1. Remove AppsFlyer

**Priority:** High — reduces binary size, removes unnecessary ATT prompt, eliminates dead code
**Effort:** ~30 minutes

#### Why it's safe to remove
`AppsFlyerService` is never initialised or called anywhere in the app. `SocraticJournalApp.swift` only instantiates `FirebaseAnalyticsService`, `LocalNotificationService`, `UserDefaultsBreathSessionRepository`, and `UserDefaultsSettingsRepository`. All tracked events (`af_session_completed`, `clarityScore`, `letterComposed`) are Socratic Journal relics — irrelevant to the breath pacer.

#### What to delete / change

**1. Delete the file:**
```
Sources/SocraticJournal/Data/Services/AppsFlyerService.swift
```

**2. Edit `project.yml` — remove the package declaration:**
```yaml
# DELETE these lines from the `packages:` block:
AppsFlyerFramework:
  url: https://github.com/AppsFlyerSDK/AppsFlyerFramework.git
  from: "6.15.0"
```

**3. Edit `project.yml` — remove the product dependency from the target:**
```yaml
# DELETE from targets.SocraticJournal.dependencies:
- package: AppsFlyerFramework
  product: AppsFlyerLib
```

**4. Regenerate the Xcode project:**
```bash
xcodegen generate
```

**5. Build and verify — expected result:** No `import AppsFlyerLib` anywhere, no ATT permission prompt on first launch, smaller binary.

#### Side effects to watch
- `Info.plist` — check for `NSUserTrackingUsageDescription` key. If it's only there for AppsFlyer, remove it. If Firebase or any other SDK needs it, leave it.
- `Package.resolved` — will update automatically when Xcode resolves packages after project regeneration.

---

### 2. Home Screen Widget — Launch Favourite Pattern

**Priority:** High — highest distribution leverage (Lock Screen / Home Screen daily touchpoint)
**Effort:** ~3–4 days

#### Concept
A small iOS widget on the user's Home Screen showing their favourite breathing pattern. One tap opens the Breathe tab with that pattern pre-selected and ready to start. No friction — from Home Screen to breathing in 2 seconds.

#### Widget variants

| Size | Content | Interaction |
|------|---------|------------|
| Small | Pattern name + timing (e.g. "Resonance · 5.5·5.5") + teal accent bar | Tap → open Breathe tab, pattern pre-selected |
| Medium | Pattern name + one-line science note + BOLT score (if recorded today) | Tap → open Breathe tab |

#### Technical plan

**Step 1 — App Group for shared UserDefaults**

Widget and main app need to share the user's favourite pattern setting. Add an App Group:
- Identifier: `group.com.StudioNext.socraticJournal`
- Enable in both the main target and the widget extension target (Xcode → Signing & Capabilities)
- Migrate `UserDefaultsSettingsRepository` to use `UserDefaults(suiteName: "group.com.StudioNext.socraticJournal")` for the `favouritePatternId` key

**Step 2 — Add widget target to `project.yml`**

```yaml
targets:
  NextBreathWidget:
    type: app-extension
    platform: iOS
    sources:
      - path: Sources/NextBreathWidget
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.StudioNext.socraticJournal.widget
        SWIFT_VERSION: "5.9"
    dependencies:
      # No Firebase, no AppsFlyer — widget must be lightweight
```

**Step 3 — Widget implementation structure**
```
Sources/NextBreathWidget/
├── NextBreathWidgetBundle.swift      # @main WidgetBundle
├── FavouritePatternWidget.swift # Widget definition + Provider
├── WidgetEntryView.swift        # SwiftUI view (small + medium)
└── WidgetPatternData.swift      # Reads from App Group UserDefaults
```

**Step 4 — Favourite pattern selection in Settings**

Add a "Favourite pattern" picker to `SettingsView` — a simple horizontal scroll of the 8 patterns (same design as `PatternSelectorBar`). Saved to `UserSettings.favouritePatternId`. This is what the widget reads from the App Group.

**Step 5 — Deep link to pre-select pattern**

Use a URL scheme or `AppIntent` to tell the main app which pattern to open.

Option A — URL scheme (simpler):
```swift
// In widget: widgetURL(URL(string: "nextbreath://breathe?pattern=resonance")!)
// In SocraticJournalApp: handle .onOpenURL { url in ... }
```

Option B — AppIntent (iOS 17, recommended for interactive widgets):
```swift
struct OpenPatternIntent: AppIntent {
    @Parameter var patternId: String
    func perform() async throws -> some IntentResult {
        // Navigate to Breathe tab with pattern pre-selected
    }
}
```

**Step 6 — Widget entry point for `MainTabView`**

`MainTabView` already has `pendingPatternId` binding machinery from the Programs feature — reuse it for widget deep links. When the widget deep link fires, set `pendingPatternId` and switch to `.breathe` tab.

#### Design notes
- Widget background: `#FAF7F2` (warm cream) — matches app identity
- Accent bar: `#2D5F5D` (teal)
- Font: SF Pro, not serif (widget text rendering at small sizes)
- Small widget: pattern name bold 16pt, timing 11pt secondary, teal bar on left edge
- Show a subtle "Tap to breathe" label at bottom

---

### 3. Apple Watch App — Simple Breath Pacer

**Priority:** High — retention driver + daily utility + Apple Watch App Store discoverability
**Effort:** ~5–7 days

#### Concept
The Apple Watch app is **not** a port of the full iOS app. It is a simple, focussed breath pacer for the wrist: pick a pattern, breathe, done. No BOLT, no Learn, no Programs, no settings. The watch is where you breathe; the phone is where you learn.

#### Pattern subset (3 only)

Reduce to the 3 patterns a watch user reaches for instinctively:

| Pattern | Why on watch |
|---------|-------------|
| Resonance (5.5·5.5) | Morning practice, HRV default |
| Box (4·4·4·4) | Pre-meeting stress control — most common use case for a quick wrist interaction |
| Physiological Sigh (2+1··8) | Fastest acute reset — single-breath, immediate need |

Advanced patterns (Tummo, Alternate Nostril) don't suit watch UX. Buteyko and 4-7-8 can be added later.

#### Screen flow

```
Watch App Launch
      │
      ▼
Pattern Picker
  [Resonance] [Box] [Sigh]
  (scrollable list, large tap targets)
      │
      ▼ (tap pattern)
Duration Picker
  2 min / 5 min / 10 min
  (Digital Crown or 3 large buttons)
      │
      ▼ (tap Start)
Active Session
  - Phase name full-screen ("INHALE")
  - Countdown number large (serif if possible)
  - Progress ring around watch face
  - Haptic at every phase transition
  - Stop button (force touch or crown press)
      │
      ▼ (session ends)
Done Screen
  - "X cycles · Y minutes"
  - Subtle checkmark
  - Auto-dismiss after 3 seconds
```

#### Technical plan

**Step 1 — Add watchOS target to `project.yml`**

```yaml
targets:
  NextBreathWatchApp:
    type: application
    platform: watchOS
    deploymentTarget: "10.0"
    sources:
      - path: Sources/NextBreathWatch
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.StudioNext.socraticJournal.watchkitapp

  NextBreathWatchExtension:
    # Only needed for watchOS < 7 — on watchOS 7+ use standalone app
    # Skip if targeting watchOS 10+
```

**Step 2 — Shared domain types**

`BreathPattern`, `BreathPhase`, and `BreathPhaseType` are already `Sendable` and `Codable` — they can be compiled into the watch target directly. No Firebase, no AppsFlyer, no UIKit dependencies in the domain layer.

Create a `WatchBreathPatterns.swift` with the 3 watch-only patterns (copy the static definitions, do not reference `BreathPattern.allPatterns` which pulls the full 8).

**Step 3 — Watch-specific pacing engine**

The iOS `BreathPacingEngine` uses `CADisplayLink` which is UIKit/iOS-only. For watchOS, use a `Timer`-based approach (60fps is unnecessary on a watch — 10fps is sufficient for phase progress):

```swift
// WatchPacingEngine.swift
@Observable @MainActor
final class WatchPacingEngine {
    // Same state as BreathPacingEngine
    // Uses Timer.scheduledTimer(withTimeInterval: 0.1, ...) instead of CADisplayLink
    // Haptics via WKHapticType: .start (inhale), .stop (exhale), .directionUp (hold start)
}
```

**Step 4 — Haptic pattern per phase**

watchOS haptics are the primary guidance (screen is small, glanced at not stared at):

| Phase | `WKHapticType` |
|-------|----------------|
| Inhale start | `.start` |
| Hold start | `.directionUp` |
| Exhale start | `.stop` |
| Top Up (sigh) | `.click` |

**Step 5 — Session data back to iPhone (optional, nice to have)**

Use `WCSession` (WatchConnectivity) to send completed session data to the iPhone, so watch sessions show up in TodayView and Progress. Not blocking for v1 — watch sessions can be silently dropped until this is implemented.

**Step 6 — Always On Display support (watchOS 10)**

For the session screen, implement `TimelineView(.animation(minimumInterval: 1))` so the phase name and countdown update even in Always On mode.

#### Design notes
- Full-screen phase label: large serif or heavy system font, white on teal (`#2D5F5D`) background for inhale, white on dark for exhale
- Progress ring: `Circle().trim()` animated, stroke width 6pt
- Countdown: `monospacedDigit()` to prevent layout jitter
- Pattern picker: `.listStyle(.carousel)` for easy scroll with Digital Crown

---

## NEXT — Growth Features

---

### 4. HealthKit Integration

**Why:** Apple Watch HRV data + writing breathing minutes creates a feedback loop that motivates users and enables WHOOP/Oura/Health audience crossover.

**Scope:**
- Write `HKQuantityType.mindfulSession()` after each breath session (duration)
- Read `HKQuantityType.heartRateVariabilitySDNN` from Health and display alongside BOLT score in TodayView
- "HRV this week" sparkline in Progress tab

**Effort:** 2–3 days

---

### 5. Streaks & Milestone Achievements

**Why:** The streak counter exists; achievements add the dopamine loop that converts occasional users into daily practitioners.

**Milestones to reward:**
- First session completed
- 7-day streak
- First BOLT score 20+, 30+, 40+
- First program completed
- 30 total sessions
- Tried all 8 patterns

**Effort:** 2 days

---

### 6. Sleep Mode / Goodnight Routine

**Why:** The Better Sleep program exists but there's no "tap here before sleep" shortcut. The sleep ICP is large.

**Scope:**
- Shortcut on Today tab: "Start Goodnight Routine"
- Pre-selects 4-7-8, 5-minute session
- Post-session: gentle full-screen "Goodnight" message, dims screen
- Optional: "Set as reminder" — schedules local notification for same time nightly

**Effort:** 1–2 days

---

### 7. Personalised Pattern Recommendation

**Why:** New users face choice paralysis with 8 patterns. The BOLT score and a simple questionnaire can route them to the right starting point.

**Logic:**
- BOLT < 20 → "Start with Buteyko Reduced"
- Anxiety / stress → Physiological Sigh + Box
- Sleep issues → 4-7-8
- Default → Resonance

**Scope:** Question prompt after BOLT score first recording, banner recommendations in Today tab.

**Effort:** 1–2 days

---

## LATER — Differentiation

---

### 8. Optional Whispered Audio Cues

Soft audio phase guidance ("Inhale... hold... exhale...") as an alternative to the visual wave for eyes-closed practice. Inspirational quotes read aloud between sessions.

**Effort:** 1 week (recording + playback implementation)

---

### 9. Live HRV Overlay During Session (Apple Watch required)

Real-time HRV during a Resonance session via Apple Watch `HKLiveWorkoutBuilder`. The ultimate biofeedback — you see your HRV rise as you breathe. This is a genuine differentiator no competitor offers.

**Effort:** 1–2 weeks (requires WatchConnectivity integration + HealthKit workout session)

---

### 10. Community Challenges

"Join 10,000 people doing the 14-Day Nasal Reset this month." Leaderboard-free accountability — just a shared counter and optional reminder. Requires backend (Firebase Firestore).

**Effort:** 1–2 weeks

---

## Technical Debt

These don't ship features but keep the codebase healthy:

| Item | Notes |
|------|-------|
| Rename Xcode target / bundle ID to `nextbreath` | Coordinate with new App Store listing, provisioning profiles, Firebase project rename |
| `CharacterDiscovery/` folder in Presentation | Leftover from Socratic Journal — check if empty and delete |
| `Statistics/` folder in Presentation | Currently empty — delete or plan |
| `functions/src/` at root | Duplicate of `Firebase/functions/` — clarify which is live, delete the other |
| Firebase Functions | Most are Socratic Journal era — audit and delete unused functions |
| Copyright headers | All say "Copyright 2024 StudioNext" — update to 2026 |

---

## Priority Order Summary

```
1. [Now]  Remove AppsFlyer            ~30 min — do this first
2. [Now]  Widget                      ~3–4 days
3. [Now]  Apple Watch app             ~5–7 days
4. [Next] HealthKit                   ~2–3 days
5. [Next] Achievements / Streaks      ~2 days
6. [Next] Sleep Mode                  ~1–2 days
7. [Next] Pattern recommendation      ~1–2 days
8. [Later] Audio cues                 ~1 week
9. [Later] Live HRV overlay           ~2 weeks
10.[Later] Community challenges       ~2 weeks
```
