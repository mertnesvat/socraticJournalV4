---
base_branch: feature/dark-theme-2
max_retries: 3
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
quality_mode: deep
---

# Feature Queue: Rumi Breathing — Dark Theme Complete + HealthKit Integration

---

## Feature 1: Complete Dark Theme Coverage Across All Views

### Context

The app has a working `ThemeManager` with dark/light/system modes, and the root `WindowGroup` applies `.preferredColorScheme(themeManager.colorScheme)`. However, there are two compounding problems:

**Problem A — Static colors don't adapt:** `AppColors` uses hardcoded hex values (e.g., `background = #FAF7F2`). When `preferredColorScheme(.dark)` is applied, SwiftUI system colors adapt, but `AppColors.*` remain cream/light. The file already defines `backgroundDark` and `surfaceDark` but they are never used conditionally.

**Problem B — Sheets/covers bypass theme inheritance:** In SwiftUI, sheets and fullScreenCovers do NOT inherit `preferredColorScheme` from their parent. Each modal must apply it independently. The following presentations are missing `.environment(themeManager)` and/or `.preferredColorScheme(themeManager.colorScheme)`:
- `ProgressHistoryView` sheet from `TodayView` — no theme propagation
- `BOLTTestView` sheet from `TodayView` — no theme propagation
- `TrainingFlowView` sheet from `LearnView` — no theme (LearnView also missing ThemeManager environment injection)
- `ProgramDetailView` sheet from `LearnView` — no theme
- `SessionCompleteOverlay` fullScreenCover from `BreatheView` — no theme (BreatheView also missing ThemeManager environment injection)
- `NewOnboardingView` fullScreenCover from `SocraticJournalApp` — missing `.environment(themeManager)` and `.preferredColorScheme`

### User Story

As a user who prefers dark mode, I want every screen, sheet, and overlay in the app to respect my chosen theme, so I never see a jarring light-mode flash when opening a session complete overlay, BOLT test, or progress history.

### Acceptance Criteria

**AppColors adaptive colors (the core fix):**
- [ ] `AppColors` is refactored so all semantic colors use `UIColor(dynamicProvider:)` wrapped in `Color(uiColor:)`, making them respond to the OS trait environment automatically — no `@Environment(\.colorScheme)` needed in any view
- [ ] Add a `UIColor(hex:)` convenience initializer alongside the existing `Color(hex:)` extension in AppColors.swift
- [ ] Dark variants for each semantic token:
  - `background` dark: `#0A0A0A`
  - `surface` dark: `#1A1A1A`
  - `surfaceElevated` dark: `#252525`
  - `textPrimary` dark: `#F5F0E8`
  - `textSecondary` dark: `#9E9688`
  - `textTertiary` dark: `#5C5650`
  - `border` dark: `#2C2C2C`
  - `borderStrong` dark: `#3C3C3C`
- [ ] Accent colors (`accent`, `accent2`, `accentLight`, `accentGradient`, tag colors, card colors) remain as static hex — they are intentional on both themes
- [ ] Existing static `backgroundDark` and `surfaceDark` properties are removed (superseded by the adaptive `background` and `surface`)

**Theme propagation to all sheets and covers:**
- [ ] `TodayView`: `ProgressHistoryView` sheet gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`
- [ ] `TodayView`: `BOLTTestView` sheet gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`
- [ ] `LearnView`: inject `@Environment(ThemeManager.self) private var themeManager`
- [ ] `LearnView`: `TrainingFlowView` sheet gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`
- [ ] `LearnView`: `ProgramDetailView` sheet gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`
- [ ] `BreatheView`: inject `@Environment(ThemeManager.self) private var themeManager`
- [ ] `BreatheView`: `SessionCompleteOverlay` fullScreenCover gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`
- [ ] `SocraticJournalApp`: `NewOnboardingView` fullScreenCover gets `.environment(themeManager).preferredColorScheme(themeManager.colorScheme)`

**Deep quality verification per surface:**
- [ ] `TodayView` — background, streak cells, week grid, session rows, goal ring all use adaptive `AppColors.*`
- [ ] `BreatheView` + all Breathe components (`PatternSelectorBar`, `DurationChipBar`, `BreathWaveView`, `PhaseLabelView`, `InsightCard`, `PatternInfoSection`, `SessionStatsGrid`) render correctly in dark mode
- [ ] `SessionCompleteOverlay` — intentional teal gradient background is preserved; text uses `.textOnAccent` / white which is correct
- [ ] `LearnView` + all Learn components (`ArticleRow`, `ChapterSection`, `ProgramCarousel`, `TrainingGrid`) — adaptive backgrounds and text
- [ ] `ProgressHistoryView` + all Progress components (`SummaryStatsRow`, `WeeklyBarChart`, `BOLTLineChart`, `PatternDistribution`, `RecentSessionsSection`, `SessionHistoryList`, `BOLTHistoryList`) — chart grid lines, axis labels, and backgrounds use adaptive colors
- [ ] `AllSessionsView` and `AllBOLTScoresView` — adaptive
- [ ] `BOLTInstructionsPage`, `BOLTTimerPage`, `BOLTResultPage` — all adaptive; navigation bar does not have hardcoded white background
- [ ] `ProgramDetailView` + `ProgramDayCard` — adaptive
- [ ] `TrainingFlowView` — adaptive
- [ ] `SettingsView` + `ThemeSelectorView` + `AboutView` — verify no regressions from color refactor
- [ ] `NewOnboardingView` — pages 1 and 2 use adaptive background; page 3 intentionally uses solid `AppColors.accent` background with white text (this is correct, do not change)
- [ ] `MainTabView` tab bar — tint stays `AppColors.accent`; tab bar background uses system material and adapts automatically
- [ ] `HairlineDivider` (wherever defined) uses `AppColors.border` which now adapts

**Priority:** 1
**Dependencies:** None

---

## Feature 2: HealthKit Integration — Breath Sessions as Mindful Minutes + HRV Insights

### Context

Zero HealthKit code exists in the app today. This feature adds two complementary health data connections that directly reinforce the app's science-backed positioning:

**Write direction:** Each completed `BreathSession` is saved to HealthKit as a **Mindful Session** (`HKCategoryType(.mindfulSession)`). This surfaces in Apple Health under Mindfulness and contributes to the Apple Watch mindfulness goal ring. Duration maps 1:1 to the session's duration in seconds.

**Read direction:** The app reads **Heart Rate Variability SDNN** (`HKQuantityType(.heartRateVariabilitySDNN)`) and **Resting Heart Rate** (`HKQuantityType(.restingHeartRate)`) from HealthKit. HRV is the validated physiological metric that resonance (5.5 s) and coherent (6-6) breathing directly improve — showing users their HRV trend alongside their breath practice streak creates the most compelling feedback loop in the app and directly differentiates Rumi Breathing from generic breath timers.

### Architecture

New files to create:
- `Sources/SocraticJournal/Domain/Services/HealthKitServiceProtocol.swift` — protocol + `HRVSample` and `HeartRateSample` value types
- `Sources/SocraticJournal/Data/Services/HealthKitService.swift` — real `HKHealthStore`-based implementation
- `Sources/SocraticJournal/Data/Services/MockHealthKitService.swift` — for previews and simulator

Files to modify:
- `SocraticJournal.entitlements` — add HealthKit entitlement key
- `project.yml` — add HealthKit capability + NSHealth Info.plist usage description keys
- `Sources/SocraticJournal/Domain/Entities/UserSettings.swift` — add `healthKitEnabled: Bool` field
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — call mindful session save on completion
- `Sources/SocraticJournal/Presentation/Progress/ProgressHistoryView.swift` — add Health Insights section
- `Sources/SocraticJournal/Presentation/Progress/ProgressViewModel.swift` — fetch HRV + resting HR
- `Sources/SocraticJournal/Presentation/Settings/SettingsView.swift` — add Health section
- `Sources/SocraticJournal/Presentation/Settings/SettingsViewModel.swift` — handle authorization flow
- `Sources/SocraticJournal/App/SocraticJournalApp.swift` — create and inject HealthKitService
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` — thread service to children

### User Story

As a user who tracks my health with the iPhone Health app or Apple Watch, I want my Rumi Breathing sessions to automatically appear as Mindful Minutes in Apple Health, and I want to see my HRV and resting heart rate trends alongside my practice history, so I can see the real physiological impact of my breathing habit.

### Acceptance Criteria

**Protocol & Service:**
- [ ] `HealthKitServiceProtocol` defined with:
  - `var isAvailable: Bool { get }`
  - `func requestAuthorization() async throws`
  - `func saveMindfulSession(start: Date, end: Date) async throws`
  - `func fetchHRVSamples(days: Int) async throws -> [HRVSample]`
  - `func fetchRestingHeartRate(days: Int) async throws -> [HeartRateSample]`
  - `HRVSample`: `struct { let date: Date; let valueMs: Double }`
  - `HeartRateSample`: `struct { let date: Date; let bpm: Double }`
- [ ] `HealthKitService` (real): uses `HKHealthStore`, requests write for `mindfulSession`, read for `heartRateVariabilitySDNN` and `restingHeartRate`
- [ ] `MockHealthKitService`: `isAvailable = false`, all methods are no-ops or return empty arrays — safe on simulator
- [ ] `SocraticJournalApp` creates `HealthKitService()` (or `MockHealthKitService()` when unavailable) and injects it through `MainTabView`

**Entitlements & project.yml:**
- [ ] `SocraticJournal.entitlements` — add `<key>com.apple.developer.healthkit</key><true/>`
- [ ] `project.yml` — add NSHealth usage description strings (under `info` section or build settings):
  - `NSHealthUpdateUsageDescription`: `"Rumi Breathing saves your completed breath sessions as Mindful Minutes in Apple Health."`
  - `NSHealthShareUsageDescription`: `"Rumi Breathing reads your Heart Rate Variability and Resting Heart Rate to show how your breathing practice improves your recovery."`

**UserSettings:**
- [ ] `UserSettings` entity gains `healthKitEnabled: Bool` with default `false`
- [ ] Codable conformance maintained (add coding key, handle missing key gracefully in decoding)

**Settings — Health section:**
- [ ] New `SectionHeaderView("Health")` section in `SettingsView`, positioned after the Appearance section
- [ ] Row: "Sync to Apple Health" with a toggle
  - When `!isAvailable`: row is shown but disabled with subtitle "Not available on this device"
  - On first enable: calls `requestAuthorization()`, on success persists `healthKitEnabled = true`
  - If authorization was previously denied: shows an alert "Health Access Needed" with "Open Settings" button linking to `UIApplication.openSettingsURLString`
  - Toggle off: sets `healthKitEnabled = false` (does not revoke HealthKit permission — that's the user's job in Settings.app)

**Session saving on completion:**
- [ ] `BreatheViewModel` receives `HealthKitServiceProtocol?` as an optional dependency
- [ ] After saving a completed session to `sessionRepository`, if `healthKitService != nil && settings.healthKitEnabled`, call `saveMindfulSession(start:end:)` using `session.date` as start and `session.date + session.duration` as end
- [ ] HealthKit save failure is caught and logged via `analyticsService` as a non-fatal event — does NOT interrupt the session complete overlay or show any error to the user
- [ ] If `BreathSession` does not have a clear `durationSeconds` field, use `durationMinutes * 60` or whichever field stores the actual session length

**Progress — Health Insights section:**
- [ ] `ProgressHistoryView` shows a "Health Insights" section when `healthKitEnabled && isAvailable`
- [ ] Section is hidden entirely (not just empty) when `!healthKitEnabled || !isAvailable`
- [ ] Section contains two side-by-side tiles (equal width HStack):

  **HRV tile:**
  - Title: "HRV", subtitle: "7-day avg"
  - Value: e.g. "42 ms"
  - Trend indicator compared to prior 7-day average:
    - ↑ in `AppColors.accent` (teal) — HRV improving (higher is better)
    - ↓ in `AppColors.accent2` (coral) — HRV declining
    - → in `AppColors.textSecondary` — stable (±1ms tolerance)
  - Context label:
    - ≥50ms → "Excellent recovery"
    - 30–49ms → "Good recovery"
    - 20–29ms → "Keep practicing"
    - <20ms → "Rest recommended"
  - Mini sparkline using last 7 data points in teal

  **Resting HR tile:**
  - Title: "Resting HR", subtitle: "7-day avg"
  - Value: e.g. "58 bpm"
  - Trend indicator:
    - ↓ in `AppColors.accent` (teal, good — lower RHR = better fitness)
    - ↑ in `AppColors.accent2` (coral, bad — higher RHR)
    - → in `AppColors.textSecondary` — stable (±1bpm tolerance)
  - Mini sparkline using last 7 data points in coral

- [ ] Both tiles use `AppColors.surface` background, `AppSpacing.cardPadding`, `AppShapes.card` corner radius — matching existing card aesthetics
- [ ] Empty state when no HealthKit data exists: tiles show "No data yet" in `AppColors.textTertiary` with a small note "Health data appears here as you build your practice"
- [ ] `ProgressViewModel` fetches both metrics on `loadData()` when `healthKitEnabled` is true; stores as arrays on the ViewModel

**Priority:** 2
**Dependencies:** Feature 1 must be complete (Health Insights cards must render correctly in dark mode)

---

## Implementation Notes for Night Agent

### Dark Theme — Recommended AppColors refactor technique

Use `UIColor` dynamic provider — zero changes needed in individual view bodies:

```swift
// Add UIColor(hex:) helper to AppColors.swift:
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// Then in AppColors, refactor each semantic color:
public static let background = Color(uiColor: UIColor { traits in
    traits.userInterfaceStyle == .dark
        ? UIColor(hex: "0A0A0A")
        : UIColor(hex: "FAF7F2")
})
```

Do NOT use `@Environment(\.colorScheme)` in view bodies for color switching — that requires injecting environment and adding conditional logic to every view.

### HealthKit — Simulator safety

`HKHealthStore.isHealthDataAvailable()` returns `false` on the simulator. Guard ALL HealthKit calls with `guard isAvailable else { return }`. Inject `MockHealthKitService` in simulator or let the `isAvailable` guard silently no-op everything.

### BreathSession duration field

Check `BreathSession` entity for the session length field. It likely has `durationMinutes: Int` — convert to seconds as `durationMinutes * 60` for the HealthKit end date calculation.

### project.yml HealthKit capability

Under the `SocraticJournal` target add:
```yaml
targets:
  SocraticJournal:
    capabilities:
      - com.apple.developer.healthkit
```
And add NSHealth keys to the `info` block or as `INFOPLIST_KEY_*` build settings.
