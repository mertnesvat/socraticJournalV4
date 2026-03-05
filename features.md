---
base_branch: feature/next-phase-3
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Phase 3 — Depth, Science & Habit Formation

> Phase 3 deepens the Breathe app from a simple pacer into a complete breathing practice companion inspired by James Nestor's "Breath". New features: test cleanup and verification, session completion experience, BOLT score assessment, expanded science library with chapter-based editorial, weekly/monthly progress analytics, multi-day guided programs, and nasal breathing training exercises. Same design language: warm cream editorial with teal accent, serif headings, hairline grids.

---

### 7. Test Cleanup & Verification — Remove Stale Tests, Add Core Coverage

**User Story:** As a developer, I need to clean up broken test files left over from the Socratic Journal pivot, add proper test mocks for the new Breathe domain, and ensure the test suite compiles and passes — so the codebase has a reliable test foundation before adding new features.

**Description:** The pivot from Socratic Journal to Breathe left behind broken test files that reference deleted types (PaywallViewModel, SubscriptionService, SubscriptionProduct, etc.). These tests cannot compile. This feature deletes all stale tests, updates existing valid tests, creates proper mocks for the Breathe domain, and adds unit tests for the core domain logic.

**Files to DELETE (reference deleted types):**
- `Tests/SocraticJournalTests/Subscription/PaywallViewModelTests.swift` — references deleted `PaywallViewModel`, `SubscriptionProduct`, `SubscriptionStatus`, `SubscriptionError`
- `Tests/SocraticJournalTests/Subscription/SubscriptionServiceTests.swift` — references deleted `SubscriptionProduct`, `SubscriptionStatus`, `SubscriptionError`, `SubscriptionPeriod`
- `Tests/SocraticJournalTests/Subscription/SubscriptionIntegrationTests.swift` — references deleted `PaywallViewModel`, `SubscriptionProduct`, `SubscriptionStatus`
- `Tests/SocraticJournalTests/Mocks/MockSubscriptionService.swift` — mocks non-existent `SubscriptionServiceProtocol`
- Delete the empty `Tests/SocraticJournalTests/Subscription/` directory after removing files

**Files to UPDATE:**
- `Tests/SocraticJournalTests/SocraticJournalTests.swift` — The version test checks `== "1.0.0"` but the app is at version `2.0.0`. Update to test correct version, or replace with a basic smoke test.
- `Tests/SocraticJournalTests/OnboardingTests.swift` — Review for any references to `TestMockSubscriptionService` and remove if present. Ensure all tests reference only types that exist in the current codebase.

**Files to KEEP (valid):**
- `Tests/SocraticJournalTests/Mocks/MockAnalyticsService.swift` — implements `AnalyticsServiceProtocol`, still used
- `Tests/SocraticJournalTests/Mocks/MockSettingsRepository.swift` — implements `SettingsRepositoryProtocol`, still used

**New Mocks to CREATE:**

`Tests/SocraticJournalTests/Mocks/MockBreathSessionRepository.swift`:
- Implements `BreathSessionRepositoryProtocol`
- In-memory storage using a `[BreathSession]` array
- All methods work against the in-memory array
- `getStreak()` returns a configurable value (default 0)
- `getTotalMinutesToday()` sums today's sessions
- Useful for testing TodayViewModel, BreatheViewModel, and any new features

`Tests/SocraticJournalTests/Mocks/MockNotificationService.swift`:
- Implements `NotificationServiceProtocol`
- Tracks method calls (requestPermission called, schedule called, etc.)
- Returns configurable permission status
- No actual notification scheduling

**New Test Files to CREATE:**

`Tests/SocraticJournalTests/Domain/BreathPatternTests.swift`:
- Test all 8 patterns exist in `BreathPattern.allPatterns`
- Test `cycleDuration` computes correctly for each pattern
- Test each pattern has non-empty `importance` and `bestFor` text
- Test phase types are valid for each pattern (e.g., Resonance has inhale + exhale only)
- Test pattern IDs are unique
- Test difficulty levels are correctly assigned

`Tests/SocraticJournalTests/Domain/BreathSessionTests.swift`:
- Test `BreathSession` Codable encoding/decoding round-trip
- Test `date` computed property returns start of day
- Test session with zero duration
- Test session ID uniqueness

`Tests/SocraticJournalTests/Domain/UserSettingsTests.swift`:
- Test `UserSettings.default` has expected defaults (dailyGoalMinutes = 5, hapticRhythmEnabled = true, etc.)
- Test Codable round-trip
- Test backwards compatibility — decode settings JSON missing newer fields (should fall back to defaults)
- Test `formattedReminderTime` produces correct string

`Tests/SocraticJournalTests/Domain/DailyLogTests.swift`:
- Test `totalMinutes` computation from sessions array
- Test `sessionsCount` matches array length
- Test empty sessions returns 0 minutes

`Tests/SocraticJournalTests/Data/BreathSessionRepositoryTests.swift`:
- Test saving a session and retrieving it for the same date
- Test `getSessionsForDate` returns only sessions for that day
- Test `getSessionsForDateRange` returns correct range
- Test `getTotalMinutesToday` sums correctly
- Test `getStreak` returns 0 with no sessions
- Test `getStreak` returns 1 when today has a session
- Test streak continuity (sessions on consecutive days)
- Use a dedicated UserDefaults suite (not `.standard`) to isolate test data

`Tests/SocraticJournalTests/Presentation/BreatheViewModelTests.swift`:
- Test initial state: selectedPattern is Resonance, selectedDuration is .five
- Test `selectPattern` changes the selected pattern
- Test `selectPattern` is ignored when engine is running
- Test `actionButtonLabel` returns "Begin" when idle, "Pause" when running, "Resume" when paused
- Test `showStopButton` is true only when running
- Test `elapsedFormatted` formats correctly (e.g., "2:05")
- Test `handleSessionFinished` saves session to repository (verify via mock)
- Test sessions under 5 seconds are NOT saved

`Tests/SocraticJournalTests/Presentation/TodayViewModelTests.swift`:
- Test `greeting` returns correct greeting for morning/afternoon/evening
- Test `dateString` is non-empty
- Test `goalReached` when totalMinutesToday >= dailyGoalMinutes
- Test `goalReached` when totalMinutesToday < dailyGoalMinutes
- Test `loadData` populates streak, sessions, and week days from mock repository
- Test `patternName` returns correct name for known pattern IDs
- Test `patternName` returns the raw ID for unknown pattern IDs
- Test `sessionDurationFormatted` formats minutes correctly

**Build Verification:**
After all changes, run:
```bash
xcodegen generate
xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing SocraticJournalTests
```
All tests must compile and pass with zero failures.

**Acceptance Criteria:**
- All stale subscription/paywall test files deleted
- No references to `PaywallViewModel`, `SubscriptionProduct`, `SubscriptionService`, `SubscriptionStatus`, `SubscriptionError`, or `SubscriptionPeriod` in any test file
- `MockBreathSessionRepository` and `MockNotificationService` created and functional
- All new domain tests pass (BreathPattern, BreathSession, UserSettings, DailyLog)
- Repository tests pass with isolated UserDefaults
- ViewModel tests pass with mock dependencies
- `xcodebuild test` exits with zero test failures
- Existing valid tests (OnboardingTests) still pass
- No compiler warnings in test target

**Priority:** 7
**Dependencies:** None

---

### 8. Session Completion Overlay — Post-Practice Summary & Stats

**User Story:** As a user who just completed a breath session, I want to see a beautiful summary of what I accomplished — duration, cycles, pattern used, and an encouraging message — so I feel a sense of completion and motivation to continue my practice.

**Description:** Currently when a session ends, the Breathe tab simply returns to idle state. This is an emotional dead-end. The session completion screen is a full-screen overlay that celebrates the practice with elegant editorial typography, key stats, and a motivational insight. It should feel like closing a beautiful book — satisfying and grounding.

**Trigger:**
- When `BreathPacingEngine.sessionFinished` becomes `true` AND the session was at least 30 seconds long
- Called from `BreatheViewModel.handleSessionFinished()` after saving the session
- Add `@State var completedSession: BreathSession?` on BreatheView that triggers the overlay
- Add `@State var previousDailyTotal: Double` to capture the total BEFORE this session (for goal-crossing detection)

**Screen Layout (full-screen overlay with .transition(.opacity)):**

**Background:**
- Cream background (`AppColors.background`) with a subtle radial gradient — teal at center fading to cream at edges, at ~5% opacity. This gives a gentle "glow" effect without being distracting.

**Top Section (centered, generous top padding ~80pt):**
- Small checkmark icon in a teal-filled circle (24pt), subtle scale-in animation (0.6→1.0, spring with response: 0.5, dampingFraction: 0.6)
- "Session Complete" in 11pt uppercase tracked teal text, below the checkmark
- Hairline divider below

**Stats Grid (two-column, centered):**
- Left stat: Large duration number (e.g., "5:12") in 42pt serif bold dark, "duration" label in 9pt dim text below
- Right stat: Cycle count (e.g., "28") in 42pt serif bold dark, "cycles" label in 9pt dim text below
- Hairline divider between columns (vertical)
- Below the grid: pattern name in 15pt serif italic teal (e.g., "Resonance 5.5")
- Below pattern: "Best for: Morning practice · Daily baseline" in 11pt dim text

**Daily Progress Update:**
- Hairline divider
- "TODAY'S PROGRESS" in 11pt uppercase tracked dim text
- GeometricRing (same component used in TodayView) showing updated daily goal progress
- Text: "X.X / Y min" with serif bold, and "Goal reached!" in teal bold or "X.X min to go" in dim text below
- If this session pushed the user past their daily goal (previousTotal < goal AND previousTotal + sessionDuration >= goal), show celebratory state: ring fully filled in teal, "Goal reached!" text in teal bold

**Motivational Insight Card:**
- Light teal background card (`AppColors.accent` at ~8% opacity)
- Teal border at ~12% opacity, 8pt corner radius
- One of 8 insights keyed to pattern ID (deterministic, not random), in 13pt serif italic dark text with generous line height (1.75):
  1. **Resonance** (`resonance`): "Each session at 5.5 breaths per minute strengthens the baroreflex — the body's master blood pressure regulator. The effect is cumulative."
  2. **Coherent** (`coherent`): "Stephen Elliott's research shows coherent breathing rebuilds parasympathetic tone over weeks. You're rewiring your resting state."
  3. **Box** (`box`): "The Navy SEALs use box breathing because it works under the worst conditions. What you just practiced is battle-tested composure."
  4. **4-7-8** (`478`): "Dr Weil calls this the natural tranquiliser of the nervous system. Consistent evening practice measurably shortens sleep onset."
  5. **Physiological Sigh** (`physiological`): "Stanford's Andrew Huberman proved a single double-inhale sigh can lower cortisol in 30 seconds. You just did many."
  6. **Buteyko** (`buteyko`): "Every session of reduced breathing recalibrates your CO₂ chemoreceptors. The 'air hunger' reflex gets quieter over time."
  7. **Tummo** (`wim`): "The alkaline blood shift you just created temporarily suppresses inflammatory markers. Wim Hof's ice baths are built on this."
  8. **Alternate Nostril** (`nadi`): "Nadi Shodhana creates bilateral brain hemisphere balance. Ancient yogis knew what neuroscience confirmed centuries later."

**Dismiss Button:**
- "Done" in 12pt uppercase tracked serif, dark filled button (same style as "BEGIN" button in BreatheView: `#1C1710` bg, cream text, 6pt corner radius)
- Tapping dismisses the overlay and returns to Breathe tab idle state
- Also auto-dismisses after 30 seconds if untouched (use `.task { try? await Task.sleep(for: .seconds(30)) }`)

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Breathe/SessionCompleteOverlay.swift` — Full overlay view
- `Sources/SocraticJournal/Presentation/Breathe/Components/SessionStatsGrid.swift` — Two-column stat layout with duration + cycles
- `Sources/SocraticJournal/Presentation/Breathe/Components/InsightCard.swift` — Motivational insight card with pattern-specific text

**Data Flow:**
- `BreatheViewModel` stores the completed `BreathSession` before calling `engine.stop()`
- `BreatheViewModel` loads `previousDailyTotal` from repository before the session starts (in `startSession()`)
- Overlay receives: `session: BreathSession`, `pattern: BreathPattern`, `previousDailyTotal: Double`, `dailyGoalMinutes: Int`
- `dailyGoalMinutes` loaded from `settingsRepository` in `loadSettings()`
- Goal-crossed computed as: `previousDailyTotal < Double(dailyGoalMinutes) && (previousDailyTotal + session.totalDuration / 60.0) >= Double(dailyGoalMinutes)`

**Modifications to Existing Files:**
- `BreatheView.swift`:
  - Add `@State private var completedSession: BreathSession?`
  - Add `@State private var completedPattern: BreathPattern?`
  - Present `SessionCompleteOverlay` via `.fullScreenCover(item: $completedSession)`
  - In the `.onChange(of: engine.sessionFinished)` handler, set completedSession and completedPattern before calling handleSessionFinished
- `BreatheViewModel.swift`:
  - Add `private(set) var previousDailyTotal: Double = 0`
  - Add `private(set) var dailyGoalMinutes: Int = 5`
  - In `loadSettings()`, also load `dailyGoalMinutes`
  - In `startSession()`, load current daily total: `previousDailyTotal = try await sessionRepository.getTotalMinutesToday()`
  - Change `handleSessionFinished()` to return the saved `BreathSession` (or store it as a published property)
  - Change `saveSession()` to return the created `BreathSession?`

**Acceptance Criteria:**
- Overlay appears smoothly after every completed session >= 30 seconds
- Overlay does NOT appear for sessions stopped manually under 30 seconds
- Duration formatted as "M:SS" (e.g., "5:12")
- Cycle count accurate to actual cycles completed
- Pattern name and "best for" text match the session's pattern
- Daily progress ring shows correct updated total (previous + this session)
- Goal-reached celebratory state triggers only when threshold is first crossed by this session
- Motivational insight matches the pattern used (keyed by pattern ID)
- "Done" button dismisses cleanly, returning to idle Breathe tab
- Auto-dismiss after 30 seconds of inactivity
- Checkmark icon has a satisfying spring entrance animation (delay ~0.3s after overlay appears)
- All text follows the editorial design system (serif for display, system for body)
- Reuses `GeometricRing` component from TodayView
- Works in both light and dark mode

**Priority:** 8
**Dependencies:** 7

---

### 9. Session Completion — Unit Tests

**User Story:** As a developer, I want the session completion overlay logic to be tested — ensuring correct stat formatting, pattern-specific insights, goal-crossing detection, and auto-dismiss timing — so the feature works reliably.

**Description:** Add unit tests for the session completion logic and any new methods added to BreatheViewModel.

**Tests to Create:**

`Tests/SocraticJournalTests/Presentation/SessionCompletionTests.swift`:
- Test duration formatting: 312 seconds → "5:12", 60 seconds → "1:00", 5 seconds → "0:05"
- Test pattern insight lookup returns correct text for each of the 8 pattern IDs
- Test pattern insight lookup returns a default/fallback for unknown pattern ID
- Test goal-crossing detection:
  - previousTotal = 3.0, sessionMinutes = 3.0, goal = 5 → goal crossed ✓
  - previousTotal = 6.0, sessionMinutes = 3.0, goal = 5 → goal NOT crossed (already past)
  - previousTotal = 1.0, sessionMinutes = 1.0, goal = 5 → goal NOT crossed (still under)
- Test that sessions < 30 seconds should NOT trigger overlay
- Test that sessions >= 30 seconds SHOULD trigger overlay

**Acceptance Criteria:**
- All session completion tests pass
- Tests use mocks, no real UserDefaults or repositories
- Goal-crossing logic tested with edge cases
- `xcodebuild test` passes with zero failures

**Priority:** 9
**Dependencies:** 8

---

### 10. BOLT Score — Instructions & Timer UI

**User Story:** As a user learning about breathing science, I want to measure my BOLT (Body Oxygen Level Test) score — a simple breath-hold test that reveals my CO₂ tolerance — so I can track my baseline and understand why reduced breathing matters.

**Description:** The BOLT score is one of the most important concepts from James Nestor's "Breath" and Patrick McKeown's Buteyko Method. It's a simple test: after a normal exhale, time how long until you feel the first urge to breathe. A score of 40+ seconds means excellent CO₂ tolerance. Most untrained people score 15-20 seconds.

**Access Point on Today Tab:**
- New card placed between the streak/week section and today's sessions section in `TodayView.swift`
- Card design: Light teal background (`AppColors.accent` at ~8% opacity), teal border at 12%, 8pt corner radius
- Layout:
  - "BOLT SCORE" in 11pt uppercase tracked teal text at top-left
  - **If never tested:** "Measure your baseline" in 13pt mid text, right chevron (`chevron.right`) at trailing edge in dim color
  - **If previously tested:** Large score number (42pt serif bold dark), "seconds" label (11pt dim), "Last tested: X days ago" in 11pt dim text below
- Tapping opens the BOLT test flow as a `.sheet`

**BOLT Test Flow (3-page NavigationStack inside sheet):**

**Page 1 — Instructions (`BOLTInstructionsPage`):**
- "BOLT Score" in 22pt serif bold dark
- "Body Oxygen Level Test" in 12pt mid text below
- Hairline divider
- 4-step instruction list with teal numbered circles (20pt, 1pt border, number in 11pt bold):
  1. "Sit comfortably and breathe normally for 2 minutes"
  2. "Take a normal breath in, then a normal breath out"
  3. "Pinch your nose closed after the exhale"
  4. "Time how long until you feel the first urge to breathe — not until you can't breathe, just the first desire"
- Each step: 13pt body text, 14pt vertical spacing between steps
- Important note card (coral `#C4502A` background at 8%, coral border at 12%, 8pt corner radius):
  - "⚠ This is NOT a maximum breath-hold test. Stop timing at the first involuntary swallow, the first diaphragm contraction, or the first urge to inhale. Your next breath after the test should be calm — if you gasp, you held too long."
  - 12pt body text, coral-tinted dark text
- "Start Test" button: dark filled (`#1C1710` bg, cream text), 12pt uppercase tracked serif
- "What is BOLT?" disclosure link in 11pt teal below the button — tapping expands a collapsible section:
  - "The BOLT score was developed by Patrick McKeown as part of the Buteyko breathing method. It measures your body's tolerance to carbon dioxide — the real driver of the urge to breathe. James Nestor tested his own BOLT score throughout his research for 'Breath' and documented how it improved with practice. A higher BOLT score correlates with lower anxiety, better exercise tolerance, improved sleep quality, and stronger parasympathetic tone."
  - 13pt body, warm brown, line height 1.75

**Page 2 — Active Timer (`BOLTTimerPage`):**
- Large countdown-up timer in center: starts at "0.0" and counts up with 1 decimal place (100ms resolution)
- Timer font: 56pt serif bold dark, `.monospacedDigit()`
- Below timer: "Hold after a normal exhale" in 15pt serif italic teal
- Pulsing dot indicator below the instruction text: teal circle (8pt), gentle scale animation (0.8→1.2 at 1Hz, `.easeInOut`)
- Large "STOP" button: coral filled (`#C4502A`), white text, 14pt uppercase tracked serif, full-width minus padding, 6pt corner radius
- Tapping STOP records the score and advances to Page 3
- Timer auto-stops at 120 seconds with a note: "Most people stop well before this. If you reached 120s, your CO₂ tolerance is exceptional."
- Haptic: `UIImpactFeedbackGenerator(.medium)` at test start, `UIImpactFeedbackGenerator(.soft)` at stop
- Timer implementation: `Timer.publish(every: 0.1, on: .main, in: .common)` — counts elapsed time from start

**Page 3 — Result (`BOLTResultPage`):**
- Large score display: score with 1 decimal in 56pt serif bold, colored by tier:
  - < 10s: Coral `#C4502A` — tier label "Very Low"
  - 10-20s: Brown `#7A6030` — tier label "Below Average"
  - 20-30s: Teal `#2D5F5D` — tier label "Average"
  - 30-40s: Green `#5A6E3D` — tier label "Good"
  - 40+s: Teal `#2D5F5D` — tier label "Excellent"
- "seconds" label below score in 13pt dim
- Tier badge: colored pill with tier label text (10pt bold tracked, colored background at 8%, border at 20%)
- Hairline divider
- Interpretation paragraph in 13pt body text, warm brown (#3D3328), generous line height (1.75):
  - **Very Low (<10):** "Your CO₂ tolerance is very low — this is common in chronic mouth-breathers and people with anxiety. Buteyko Reduced breathing is your priority pattern. Even a few weeks of practice can dramatically improve this score."
  - **Below Average (10-20):** "Below average, but this is where most modern adults land. Your chemoreceptors are over-sensitive to CO₂, causing you to over-breathe. Resonance and Coherent patterns will gradually recalibrate."
  - **Average (20-30):** "Average range. You have reasonable CO₂ tolerance but there's significant room for growth. Regular practice with any pattern will improve this. Aim for 30+ as your next milestone."
  - **Good (30-40):** "Good CO₂ tolerance. Your breathing efficiency is above average. You'll notice this in better sleep, lower resting heart rate, and calmer stress response. Keep going — 40+ is excellent."
  - **Excellent (40+):** "Excellent. This indicates strong parasympathetic tone, efficient gas exchange, and well-calibrated chemoreceptors. Nestor found that experienced meditators and free divers consistently score here."
- If previous scores exist: "Previous: X.Xs (Y days ago)" in 11pt dim, with a small trend indicator (↑ green `#5A6E3D` if improved by >2s, ↓ coral if declined by >2s, → dim if within ±2s)
- "Save & Close" button: dark filled, 12pt uppercase tracked serif — saves score and dismisses sheet
- "Retake" text button in 11pt teal below — navigates back to Page 2 (timer), does NOT save the current score

**Domain Entity:**

`Sources/SocraticJournal/Domain/Entities/BOLTScore.swift`:
```swift
struct BOLTScore: Identifiable, Codable, Sendable {
    let id: String // UUID string
    let score: TimeInterval // seconds, 1 decimal
    let recordedAt: Date
}

enum BOLTTier: String, Codable, Sendable {
    case veryLow, belowAverage, average, good, excellent

    static func from(score: TimeInterval) -> BOLTTier {
        switch score {
        case ..<10: return .veryLow
        case 10..<20: return .belowAverage
        case 20..<30: return .average
        case 30..<40: return .good
        default: return .excellent
        }
    }

    var label: String {
        switch self {
        case .veryLow: return "Very Low"
        case .belowAverage: return "Below Average"
        case .average: return "Average"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }

    var colorHex: String {
        switch self {
        case .veryLow: return "C4502A"
        case .belowAverage: return "7A6030"
        case .average: return "2D5F5D"
        case .good: return "5A6E3D"
        case .excellent: return "2D5F5D"
        }
    }

    var interpretation: String {
        // (return the appropriate paragraph from above based on tier)
    }
}
```

**Repository Changes:**

Add to `BreathSessionRepositoryProtocol`:
```swift
func saveBOLTScore(_ score: BOLTScore) async throws
func getBOLTScores() async throws -> [BOLTScore]
func getLatestBOLTScore() async throws -> BOLTScore?
```

Implement in `UserDefaultsBreathSessionRepository` with UserDefaults key `"com.breathe.bolt"`, storing as JSON-encoded `[BOLTScore]` array.

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Today/Components/BOLTScoreCard.swift` — Card on Today tab
- `Sources/SocraticJournal/Presentation/BOLT/BOLTTestView.swift` — NavigationStack container
- `Sources/SocraticJournal/Presentation/BOLT/BOLTInstructionsPage.swift` — Page 1
- `Sources/SocraticJournal/Presentation/BOLT/BOLTTimerPage.swift` — Page 2 active timer
- `Sources/SocraticJournal/Presentation/BOLT/BOLTResultPage.swift` — Page 3 score & interpretation
- `Sources/SocraticJournal/Domain/Entities/BOLTScore.swift` — Entity + tier enum

**Modifications to Existing Files:**
- `TodayView.swift` — Add `BOLTScoreCard` between `streakAndWeekSection` and `todaySessionsSection`, add `@State private var showBOLTTest = false` and `.sheet` presentation
- `TodayViewModel.swift` — Add `private(set) var latestBOLTScore: BOLTScore?`, load in `loadData()`
- `BreathSessionRepositoryProtocol.swift` — Add 3 BOLT methods
- `UserDefaultsBreathSessionRepository.swift` — Implement BOLT persistence with `"com.breathe.bolt"` key

**Acceptance Criteria:**
- BOLT card on Today tab shows correct state (never tested vs. last score)
- Instructions page clearly explains the 4-step process
- Important note card uses coral color to signal caution
- Timer counts up smoothly at 100ms resolution with monospacedDigit
- Stop button immediately records the score
- Timer auto-stops at 120 seconds
- Score is color-coded by tier with correct interpretation text
- Tier badge has correct color matching
- Previous score comparison shows trend arrow (↑↓→)
- Retake navigates back to timer without saving
- "Save & Close" persists score and dismisses sheet
- Scores persist across app launches in UserDefaults
- "What is BOLT?" expands/collapses with animation
- Today tab refreshes to show new score after dismissing sheet
- Haptic feedback at test start and stop

**Priority:** 10
**Dependencies:** 7

---

### 11. BOLT Score — Unit Tests

**User Story:** As a developer, I want the BOLT score feature to be tested — tier classification, interpretation text, persistence, and trend calculation — so the medical-adjacent feature is reliable.

**Description:** Unit tests for BOLTScore entity, tier classification, and repository persistence.

**Tests to Create:**

`Tests/SocraticJournalTests/Domain/BOLTScoreTests.swift`:
- Test `BOLTTier.from(score:)` for each tier boundary:
  - 0s → veryLow, 9.9s → veryLow
  - 10.0s → belowAverage, 19.9s → belowAverage
  - 20.0s → average, 29.9s → average
  - 30.0s → good, 39.9s → good
  - 40.0s → excellent, 120.0s → excellent
- Test each tier has non-empty `label`, `colorHex`, and `interpretation`
- Test `BOLTScore` Codable round-trip
- Test trend calculation: previous 25.0 → current 30.0 = improved (↑), previous 30.0 → current 25.0 = declined (↓), previous 25.0 → current 26.0 = same (→)

Add BOLT methods to `MockBreathSessionRepository`:
- `saveBOLTScore` appends to in-memory array
- `getBOLTScores` returns the array
- `getLatestBOLTScore` returns last element

`Tests/SocraticJournalTests/Data/BOLTRepositoryTests.swift`:
- Test save and retrieve BOLT score
- Test `getLatestBOLTScore` returns most recent
- Test `getLatestBOLTScore` returns nil when empty
- Test multiple scores persist and return in order

**Acceptance Criteria:**
- All BOLT tests pass
- Tier boundaries are exactly correct at edges
- Mock repository works for all BOLT methods
- `xcodebuild test` passes with zero failures

**Priority:** 11
**Dependencies:** 10

---

### 12. Expanded Science Library — 12 Articles in 4 Chapters with Reading Progress

**User Story:** As a user exploring breathing science, I want a comprehensive library of articles organized into chapters — covering nasal breathing fundamentals, the resonance numbers, the CO₂ paradox, and practical techniques — so I can learn at my own pace and understand the "why" behind every pattern.

**Description:** Expand the Learn tab from 4 flat articles to 12 articles across 4 editorial chapters, add 3 more quick facts (total 8), and add reading progress tracking. Design stays editorial — like a beautifully typeset science magazine.

**Screen Layout Changes (LearnView.swift rewrite):**

**Header (enhanced):**
- "The Science" in 22pt serif bold dark (same)
- "Why slow nasal breathing changes everything" in 12pt mid text (same)
- NEW: "X of 12 read" in 11pt teal text below subtitle
- Hairline divider

**Quick Fact Strip (enhanced — 8 facts):**
Keep existing 5, add 3 more:
6. "70%" / "of breathing should be nasal"
7. "4x" / "more NO via humming"
8. "20%" / "more O₂ via nose"

**Chapter Sections (replace flat article list):**

Each chapter is a section with a collapsible header. Chapter 1 starts expanded, others collapsed.

**Chapter Header Design:**
- Teal left-border accent (4pt height of header, 2pt corner radius)
- "Chapter 1 · Foundations" in 15pt serif bold dark
- "The basics of nasal breathing" in 11pt mid text below
- Reading progress: "2 of 3 read" in 11pt teal, right-aligned
- Tapping header toggles article list visibility (`.easeInOut(duration: 0.25)` animation)
- Hairline divider below

**Article Row Design (enhanced from current):**
Same expandable card design as current, with these additions:
- Left side: read indicator — teal dot (6pt) for unread, teal checkmark circle (12pt, filled) for read
- Articles marked as "read" when expanded for 5+ seconds (use a timer that starts on expand, cancels on collapse)

**Chapter 1: "Foundations" (3 articles)**

1. **"You breathe 25,000 times a day. Most of them wrong."** (EXISTING — keep exact same content)
   - Tag: "Start here" (coral `#C4502A`)
   - Read time: 3 min

2. **"Your nose is a pharmacy"** (NEW)
   - Tag: "Fundamentals" (teal `#2D5F5D`)
   - Subtitle: "Nitric oxide, filtration, and the Nobel Prize discovery"
   - Read time: 4 min
   - Body: "The nasal cavity is lined with turbinates — bony shelves coated in mucous membrane that warm, filter, and humidify air. But the real discovery is nitric oxide. In 1998, Robert Furchgott, Louis Ignarro, and Ferid Murad won the Nobel Prize for discovering NO's role in vasodilation. Your paranasal sinuses produce nitric oxide continuously — but only when you breathe through your nose. NO dilates pulmonary blood vessels (improving O₂ absorption by up to 15%), kills bacteria and viruses on contact, and regulates blood pressure. Mouth breathing bypasses all of this. Humming increases nasal NO production by 15-fold — this is why traditions from yoga to Orthodox Christian chanting all involve sustained nasal exhalation with vibration."

3. **"The mouth-breathing epidemic"** (NEW)
   - Tag: "History" (brown `#7A6030`)
   - Subtitle: "George Catlin, skull records, and the Stanford experiment"
   - Read time: 5 min
   - Body: "George Catlin, a 19th-century painter who lived among 50 Native American tribes, observed that indigenous mothers gently closed their babies' mouths during sleep. His 1862 book 'Shut Your Mouth and Save Your Life' documented what he saw: tribes that breathed nasally had wide jaws, straight teeth, and robust health. Catlin's observations were dismissed for 150 years. Then came the Stanford mouth-breathing experiment Nestor participated in: 10 days of forced mouth breathing caused his blood pressure to spike 13 points, his snoring index to increase 4,820%, and his cognitive performance to measurably decline. The reversal was equally dramatic — 10 days of nasal-only breathing restored every metric. Modern orthodontics now acknowledges that mouth breathing during childhood literally reshapes the skull."

**Chapter 2: "The Numbers" (3 articles)**

4. **"5.5 — why this number"** (EXISTING — enhanced with additional paragraph)
   - Tag: "Science" (teal `#2D5F5D`)
   - Read time: 5 min
   - Body: (existing content) + " The prayer connection is remarkable: Nestor discovered that the Ave Maria recited in Latin, Japanese Buddhist mantras, and Hindu Japa Mala prayers all produce breathing rates between 5.5 and 6 breaths per minute. These traditions arrived at the resonance frequency independently, across centuries and continents, through subjective experience alone."

5. **"The nasal cycle and your brain"** (EXISTING — keep exact same content)
   - Tag: "Awareness" (teal `#2D5F5D`)
   - Read time: 4 min

6. **"Heart rate variability — the vital sign medicine forgot"** (NEW)
   - Tag: "Measurement" (teal `#2D5F5D`)
   - Subtitle: "Why HRV matters more than heart rate"
   - Read time: 5 min
   - Body: "HRV is the variation in time between consecutive heartbeats — and it's the single best non-invasive marker of autonomic nervous system health. High HRV means your vagus nerve is strong, your stress response is flexible, and your body recovers quickly. Low HRV predicts cardiovascular disease, depression, and all-cause mortality. The connection to breathing is direct: slow breathing at resonance frequency (5.5 BPM) produces the highest possible HRV for any given individual. This is not a subtle effect — a single 5-minute session can increase HRV by 50% compared to normal breathing. Wearable devices like Apple Watch now track HRV, making it possible to see the effect of your breath practice in real data."

**Chapter 3: "The Paradox" (3 articles)**

7. **"The CO₂ problem"** (EXISTING — enhanced with BOLT paragraph)
   - Tag: "Counter-intuitive" (brown `#7A6030`)
   - Read time: 4 min
   - Body: (existing content) + " The practical test is the BOLT score (Body Oxygen Level Test): after a normal exhale, time how long until you feel the first urge to breathe. Most untrained people score 15-20 seconds. Patrick McKeown's Buteyko training aims for 40+. The improvement curve is steep — a few weeks of reduced-volume breathing can add 10-15 seconds to your BOLT score."

8. **"Why athletes are taping their mouths shut"** (NEW)
   - Tag: "Performance" (teal `#2D5F5D`)
   - Subtitle: "Nasal breathing, VO₂, and Soviet Olympic training"
   - Read time: 4 min
   - Body: "Mouth taping during sleep sounds extreme, but the logic is sound. Nasal breathing during exercise forces the body to tolerate higher CO₂ levels — exactly the training stimulus that improves aerobic capacity. Olga Kharitidi, a Russian physician, documented how Soviet Olympic athletes used Buteyko-style reduced breathing to gain measurable performance advantages. The modern application: training at nasal-only breathing up to the ventilatory threshold teaches the body to extract more oxygen per breath. John Douillard's research with cyclists showed that nasal breathing during moderate exercise produced the same VO₂ with lower perceived exertion. The mouth tape during sleep simply prevents the jaw from falling open — maintaining nasal breathing for 8 hours of passive CO₂ tolerance training."

9. **"The Bohr Effect — why less is more"** (NEW)
   - Tag: "Deep dive" (brown `#7A6030`)
   - Subtitle: "Christian Bohr, haemoglobin, and the oxygen delivery paradox"
   - Read time: 6 min
   - Body: "Christian Bohr (father of Niels Bohr, the quantum physicist) discovered in 1904 that haemoglobin's affinity for oxygen changes with pH — specifically, with CO₂ concentration. When tissue CO₂ is high, haemoglobin releases oxygen more readily. When CO₂ is depleted by over-breathing, oxygen stays bound to haemoglobin and never reaches your cells. This is the Bohr Effect, and it's the foundational science behind Buteyko, behind altitude training, and behind the counter-intuitive finding that chronic over-breathers are often tissue-hypoxic despite having 99% blood oxygen saturation. The pulse oximeter on your finger tells you nothing — it measures arterial saturation, not tissue delivery. The real metric is the gap between arterial O₂ and venous O₂ — and slow, reduced breathing widens this gap in exactly the right direction."

**Chapter 4: "The Practice" (3 articles)**

10. **"The double inhale that Stanford validated"** (NEW)
    - Tag: "Technique" (teal `#2D5F5D`)
    - Subtitle: "Cyclic sighing, controlled trials, and one-breath rescue"
    - Read time: 3 min
    - Body: "In 2022, Stanford's Huberman Lab published a randomised controlled trial comparing cyclic sighing (the physiological sigh), mindfulness meditation, box breathing, and a control group. Cyclic sighing won decisively — it produced the greatest improvement in mood, the largest reduction in respiratory rate, and the most significant increase in HRV. The mechanism: the double inhale maximally inflates alveoli (the tiny air sacs where gas exchange occurs). Some alveoli collapse during normal breathing; the second sniff 'pops' them open, maximising the surface area for CO₂ offloading. The long exhale then activates the vagus nerve more powerfully than any single-inhale pattern. It's fast, it's free, and it works in a single breath."

11. **"Breathing before sleep — the 90-minute rule"** (NEW)
    - Tag: "Sleep" (purple `#6B4C8A`)
    - Subtitle: "Parasympathetic activation and sleep onset science"
    - Read time: 4 min
    - Body: "The transition from wakefulness to sleep requires a shift from sympathetic to parasympathetic dominance. Most people try to make this shift in bed — lying awake, minds racing. The research suggests starting 90 minutes before your target sleep time: dim the lights (melatonin is light-sensitive), lower the room temperature (core body temperature drops during sleep onset), and do 5-10 minutes of 4-7-8 or Coherent breathing. Andrew Weil reports that patients who do 4-7-8 consistently for 6-8 weeks fall asleep in under 2 minutes. The nasal cycle also plays a role: left-nostril dominance activates the parasympathetic right hemisphere. If you notice your right nostril is dominant before bed, 5 minutes of left-nostril-only breathing can manually shift your nervous system toward sleep."

12. **"Building a daily practice — from 5 minutes to transformation"** (NEW)
    - Tag: "Getting started" (green `#5A6E3D`)
    - Subtitle: "Minimum effective dose and the 4-week curve"
    - Read time: 4 min
    - Body: "The minimum effective dose is remarkably small. Five minutes of Resonance breathing (5.5 in, 5.5 out) produces a measurable HRV increase that lasts 30-60 minutes after the session. Two sessions per day — morning and evening — create a training effect that accumulates over weeks. By week 4, most practitioners notice: lower resting heart rate (2-5 bpm), longer BOLT score (+5-15 seconds), reduced sleep onset time, and a subjective sense of calm that wasn't there before. The key insight from Nestor's reporting is that breathing is a skill, not a gift. Every human can learn to breathe optimally. The patterns in this app aren't exotic — they're the natural rhythms your ancestors used. You're just remembering."

**Reading Progress Persistence:**
- Track which articles have been read using article index (0-11) stored as `Set<Int>`
- Add to `UserSettings`: `readArticleIndices: Set<Int>` (default empty set)
- Handle backwards compatibility in Codable decoder (missing field → empty set)
- Mark as read: when article has been expanded for 5+ seconds continuously

**Content Data Extraction:**
- Move all content data from inline in `LearnView.swift` to a separate `LearnContent.swift` file
- `Sources/SocraticJournal/Presentation/Learn/LearnContent.swift` — contains `QuickFact`, `Article`, `Chapter` structs and all static data
- `Chapter` struct: `id: Int, title: String, subtitle: String, articles: [Article]`
- `Article` struct: add `chapterIndex: Int` field for reading progress tracking

**Views to Create/Modify:**
- `Sources/SocraticJournal/Presentation/Learn/LearnContent.swift` — Extract and expand content data
- `Sources/SocraticJournal/Presentation/Learn/LearnView.swift` — Complete rewrite with chapters, reading progress, enhanced quick facts
- `Sources/SocraticJournal/Presentation/Learn/Components/ChapterSection.swift` — Collapsible chapter with header, progress, and article list
- `Sources/SocraticJournal/Presentation/Learn/Components/ArticleRow.swift` — Enhanced card with read/unread indicator

**Modifications to Existing Files:**
- `UserSettings.swift` — Add `readArticleIndices: Set<Int>` with Codable backwards compatibility
- `UserDefaultsSettingsRepository.swift` — Ensure new field is handled

**Acceptance Criteria:**
- 12 articles across 4 chapters, all with correct tags, colors, and content
- Quick fact strip has 8 facts, all scrollable
- Chapter 1 expanded by default, chapters 2-4 collapsed
- Tapping chapter header toggles visibility with smooth animation
- Chapter reading progress shows "X of 3 read" accurately
- Overall reading progress shows "X of 12 read" in header
- Read indicator: teal dot (unread) vs. teal checkmark (read)
- Article marked as read after 5 seconds of being expanded
- Only one article expanded at a time within a chapter
- Reading progress persists across app launches
- Backwards compatible — app doesn't crash for users upgrading from Phase 1
- Smooth scroll performance with 12 articles
- All content scientifically accurate, sourced from Nestor's book and referenced research
- Existing article content preserved exactly for articles 1, 4, 5, 7 (just enhanced where noted)

**Priority:** 12
**Dependencies:** 7

---

### 13. Progress & History — Weekly Bar Chart & Session History

**User Story:** As a regular practitioner, I want to see my breathing practice history over weeks — a bar chart of daily practice, session details, and pattern distribution — so I can track my progress and stay motivated.

**Description:** The Today tab shows only today. This feature adds a Progress view accessible from the Today tab header, showing weekly analytics with a bar chart and full session history. Design: same editorial warmth, clean data visualisation in teal/cream.

**Access Point:**
- New button in Today tab header, next to the settings gear icon
- Bar chart icon (`chart.bar`) in 18pt medium weight, teal color
- Tapping opens Progress view as a `.sheet` with NavigationStack

**Screen Layout (ScrollView):**

**Header:**
- "Progress" in 22pt serif bold dark
- Dismissable with X button (top-right toolbar, same style as Settings)
- Hairline divider below

**Summary Stats Row (3 columns with hairline vertical dividers):**
- Column 1: Total minutes (e.g., "47") in 28pt serif bold dark, "minutes" in 9pt dim below
- Column 2: Total sessions (e.g., "12") in 28pt serif bold dark, "sessions" in 9pt dim below
- Column 3: Average per day (e.g., "6.7") in 28pt serif bold dark, "min/day" in 9pt dim below
- Stats cover the last 7 days
- Hairline divider below

**Weekly Bar Chart:**
- "THIS WEEK" in 11pt uppercase tracked dim text
- 7 vertical bars for S-M-T-W-T-F-S
- Bar specifications:
  - Width: 8pt each, 4pt corner radius (top corners only)
  - Color: teal filled (`AppColors.accent`)
  - Height: proportional to minutes practiced. Max height = tallest day or daily goal, whichever is higher. Minimum height for non-zero days: 4pt.
  - Zero-minute days: no bar, just the day label
- Goal line: horizontal dashed hairline (1pt, `AppColors.border`, dash pattern [4,4]) at the daily goal level
  - "Goal" label at leading edge of the line in 9pt dim text
- Day label below each bar: "S" "M" "T" "W" "T" "F" "S" in 9pt dim
- Minutes label above each bar (only if > 0): e.g., "5" in 9pt teal
- Today's bar has a teal dot indicator (4pt) below the day label
- Chart area: full width minus padding, 120pt tall
- Hairline divider below chart

**Pattern Distribution:**
- "PATTERNS USED" in 11pt uppercase tracked dim text
- Horizontal list of pattern usage, each as a row:
  - Small colored circle (8pt) using pattern's `tagColorHex`
  - Pattern name in 13pt semibold dark
  - Count: "5 sessions" in 11pt dim, right-aligned
  - Percentage: "42%" in 11pt teal, right-aligned
- Only show patterns actually used (omit unused)
- Sorted by most-used first
- Hairline dividers between rows
- Hairline divider below section

**Session History (reverse chronological):**
- "RECENT SESSIONS" in 11pt uppercase tracked dim text
- Grouped by date:
  - Date header: "TODAY" / "YESTERDAY" / "MONDAY, 3 MARCH" in 11pt uppercase tracked dim
  - Each session row:
    - Teal filled circle (22pt) with pattern's first letter initial in 10pt white bold (e.g., "R" for Resonance, "B" for Box)
    - Pattern name in 13pt semibold dark
    - Duration: "5 min 12s" in 11pt dim
    - Time: "07:32" in 11pt dim, right-aligned
  - Hairline dividers between session rows
- Show last 30 sessions
- Empty state: "No sessions yet" in 13pt mid text, centered, with "Head to Breathe to start" in 11pt dim below

**Repository Changes:**

Add to `BreathSessionRepositoryProtocol`:
```swift
func getAllSessions() async throws -> [BreathSession]
```

Implement in `UserDefaultsBreathSessionRepository` — returns full array sorted by `startedAt` descending.

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Progress/ProgressView.swift` — Main progress screen
- `Sources/SocraticJournal/Presentation/Progress/ProgressViewModel.swift` — Data loading, computation (weekly totals, pattern distribution, grouping)
- `Sources/SocraticJournal/Presentation/Progress/Components/SummaryStatsRow.swift` — 3-column stats
- `Sources/SocraticJournal/Presentation/Progress/Components/WeeklyBarChart.swift` — 7-day bar chart with goal line
- `Sources/SocraticJournal/Presentation/Progress/Components/PatternDistribution.swift` — Pattern usage breakdown
- `Sources/SocraticJournal/Presentation/Progress/Components/SessionHistoryList.swift` — Date-grouped session list

**Modifications to Existing Files:**
- `TodayView.swift` — Add chart button to header HStack (next to gear), add `@State private var showProgress = false` and `.sheet` presentation
- `BreathSessionRepositoryProtocol.swift` — Add `getAllSessions()` method
- `UserDefaultsBreathSessionRepository.swift` — Implement `getAllSessions()`

**Acceptance Criteria:**
- Progress view accessible from Today tab header chart button
- Summary stats show accurate 7-day totals
- Bar chart renders correctly with proportional heights
- Goal line dashed and correctly positioned
- Today highlighted with teal dot below
- Zero-minute days show no bar
- Pattern distribution shows actual usage sorted by frequency
- Session history grouped by date, reverse chronological
- Date headers use "TODAY" / "YESTERDAY" for recent dates
- Empty state handles gracefully
- Dismisses cleanly back to Today tab
- Smooth scroll with many sessions
- All elements use editorial design system

**Priority:** 13
**Dependencies:** 7

---

### 14. Progress & History — Unit Tests

**User Story:** As a developer, I want the progress analytics logic tested — weekly totals, pattern distribution, date grouping, and average calculations — so the statistics are accurate.

**Description:** Unit tests for ProgressViewModel and related computation logic.

**Tests to Create:**

`Tests/SocraticJournalTests/Presentation/ProgressViewModelTests.swift`:
- Test weekly total minutes computed correctly from sessions across 7 days
- Test weekly total with zero sessions returns all zeros
- Test average per day calculation (total minutes / 7)
- Test pattern distribution percentage calculation:
  - 3 Resonance + 2 Box = Resonance 60%, Box 40%
- Test pattern distribution sorted by most-used first
- Test session date grouping: sessions on same day grouped together
- Test date group labels: today → "TODAY", yesterday → "YESTERDAY", other → formatted date
- Test summary stats with sessions spanning multiple days

Add `getAllSessions()` to `MockBreathSessionRepository`:
- Returns the in-memory array sorted by startedAt descending

**Acceptance Criteria:**
- All progress tests pass
- Weekly math is accurate with edge cases (no sessions, all same day, spread across week)
- Pattern distribution percentages sum to 100%
- Date grouping handles timezone correctly
- `xcodebuild test` passes with zero failures

**Priority:** 14
**Dependencies:** 13

---

### 15. Guided Programs — Data Model, Program Detail View & Day Cards

**User Story:** As a user who wants structured practice, I want multi-day guided programs — like "14-Day Nasal Breathing Reset" or "Better Sleep in 7 Days" — that prescribe exactly which patterns to practice each day, with progressive difficulty and educational tips.

**Description:** Programs are curated multi-day sequences combining specific breathing patterns with daily educational context. This feature adds program definitions, the program detail view, and progress tracking. Programs are accessed from the Learn tab.

**Access Point on Learn Tab:**
- New section at the TOP of the Learn tab, above the quick fact strip
- "PROGRAMS" section header in 11pt uppercase tracked dim text
- Horizontally scrollable program cards:
  - Each card: 200pt wide × 120pt tall
  - Light surface background (`AppColors.surface`), 8pt corner radius, hairline border
  - Program name in 15pt serif bold dark, max 2 lines
  - Duration badge: "14 days" in 10pt bold tracked teal, small pill background (teal at 8%)
  - If started: thin progress bar at bottom (3pt height, teal fill, cream track), "Day X" in 9pt teal
  - If not started: "START" in 10pt uppercase tracked teal at bottom-right
- Hairline divider below the program carousel
- Tapping a card opens the program detail as a `.sheet`

**3 Programs:**

**Program 1: "14-Day Nasal Breathing Reset"**
- Theme: Teal
- Description: "Retrain your body to breathe through the nose — day and night. Inspired by the Stanford mouth-breathing experiment James Nestor participated in."
- Days:
  1. Coherent · 5 min — "Today is about rhythm, not effort. Breathe in for 6 counts, out for 6. If you lose count, just restart the cycle."
  2. Coherent · 5 min — "Same pattern, same duration. Repetition builds the neural groove. Notice if your mind wanders less today."
  3. Coherent · 5 min — "Last day of Coherent focus. Pay attention to whether you naturally breathe through your nose more during the day."
  4. Resonance · 5 min — "Shift to 5.5-second rhythm. This is the resonance frequency — where your heart rate variability peaks."
  5. Resonance · 5 min — "Same pattern. Notice the rhythm feels slightly faster than Coherent. Both are effective; this one maximises HRV."
  6. Resonance · 5 min — "Three days at resonance. Your baroreflex is starting to entrain. You may notice calmer responses to stress."
  7. Resonance · 10 min — "Double the duration. The first 5 minutes warm up the system; the second 5 are where the real training happens."
  8. Resonance · 10 min — "Same extended session. If your mind wanders, that's normal — just return to the count."
  9. Resonance · 10 min — "Your third 10-minute session. By now the rhythm should feel natural. Check your BOLT score if you haven't."
  10. Buteyko Reduced · 5 min — "New pattern: shorter, reduced breaths. This builds CO₂ tolerance — the key to reducing chronic over-breathing."
  11. Buteyko Reduced · 5 min — "The air hunger you feel is not danger. It's your chemoreceptors recalibrating. Sit with the discomfort."
  12. Buteyko Reduced · 5 min + Resonance · 5 min — "Combine: Buteyko to build tolerance, then Resonance to integrate. This is a powerful pairing."
  13. Alternate Nostril · 5 min + Resonance · 5 min — "Alternate nostril balances hemispheres. Follow with Resonance for HRV benefit."
  14. Resonance · 10 min — "Final session. You've spent 14 days retraining your breathing. Check your BOLT score — compare to Day 1."

**Program 2: "Better Sleep in 7 Days"**
- Theme: Purple (#6B4C8A)
- Description: "A one-week protocol to improve sleep onset using parasympathetic activation. Practice within 90 minutes of bedtime."
- Days:
  1. 4-7-8 · 5 min — "Do this within 30 minutes of bedtime. The 8-second exhale activates the vagus nerve."
  2. 4-7-8 · 5 min — "Dim lights 90 minutes before bed. Melatonin is suppressed by blue light."
  3. Coherent · 10 min — "Try this lying in bed with eyes closed. Notice how your body temperature drops."
  4. 4-7-8 · 10 min — "Extended session tonight. If your mind races, don't fight it — just return to the count."
  5. Physiological Sigh · 3 min — "Use the sigh to clear any residual tension from the day, then settle into sleep."
  6. 4-7-8 · 5 min — "Left nostril breathing activates the parasympathetic hemisphere. Notice if sleep comes faster tonight."
  7. 4-7-8 · 10 min — "Final night. By now your body should be learning the pattern. Notice if sleep onset is faster."

**Program 3: "Stress Resilience — 10 Days"**
- Theme: Coral (#C4502A)
- Description: "Build your stress response toolkit. From immediate rescue breaths to deep CO₂ tolerance training."
- Days:
  1. Physiological Sigh · 5 min — "The fastest way to lower cortisol — practice this until it's automatic."
  2. Box Breathing · 5 min — "The Navy SEALs use this before operations. Equal phases demand total focus."
  3. Physiological Sigh · 3 min + Box · 7 min — "Sigh to reset, box to sustain. This is your acute stress protocol."
  4. Resonance · 10 min — "Long-term stress resilience comes from daily HRV training. This is the foundation."
  5. Resonance · 10 min — "Your BOLT score is a proxy for stress tolerance. Check it today."
  6. Buteyko Reduced · 5 min + Resonance · 5 min — "Reduced breathing trains the exact chemoreceptors that panic attacks hijack."
  7. Box · 10 min — "Extend to 10 minutes. Notice how the holds get more comfortable over time."
  8. Buteyko Reduced · 10 min — "The air hunger you feel is not danger — it's CO₂ sensitivity recalibrating."
  9. Physiological Sigh · 2 min + Box · 3 min + Resonance · 5 min — "Practice chaining patterns. Real stress doesn't come with a menu."
  10. Resonance · 10 min — "Final session. Compare how you feel now to Day 1. The toolkit is yours."

**Domain Entities:**

`Sources/SocraticJournal/Domain/Entities/Program.swift`:
```swift
struct Program: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let themeColorHex: String
    let days: [ProgramDay]
    var totalDays: Int { days.count }
}

struct ProgramDay: Identifiable, Sendable {
    let id: Int // 1-indexed day number
    let prescriptions: [ProgramPrescription]
    let tip: String
}

struct ProgramPrescription: Identifiable, Sendable {
    let id: String // UUID string
    let patternId: String
    let durationMinutes: Int
}
```

`Sources/SocraticJournal/Domain/Entities/ProgramProgress.swift`:
```swift
struct ProgramProgress: Codable, Sendable {
    let programId: String
    var startDate: Date
    var completedDays: Set<Int> // 1-indexed day numbers

    var currentDay: Int {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        return min(daysSinceStart + 1, 999) // 1-indexed
    }

    var isComplete: Bool { completedDays.count >= totalDays }
    var totalDays: Int // stored alongside
}
```

Store progress in UserDefaults with key `"com.breathe.programs"` as `[String: ProgramProgress]` dictionary (keyed by program ID).

**Program Detail View (sheet):**

**Header:**
- Program name in 22pt serif bold dark
- Description in 13pt mid text, line height 1.75
- "Day X of Y" in 11pt uppercase tracked teal
- Linear progress bar: thin (3pt) teal fill on cream track
- Hairline divider

**Day Cards (vertical list):**
- Each day as a row, expandable on tap:
- **Collapsed state:**
  - Status icon (left, 22pt):
    - Completed day: teal filled circle with white checkmark
    - Current day (today or first incomplete): teal border circle with small teal dot inside
    - Future/locked day: dim border circle, empty
  - "DAY X" in 10pt uppercase tracked dim
  - Prescription summary: "Resonance · 5 min" in 13pt semibold dark (or "Sigh · 3 min + Box · 7 min" for multi-pattern days)
  - Chevron: `chevron.down` when expandable, `chevron.right` when collapsed
- **Expanded state (only for today and past days — future days stay collapsed with lock icon):**
  - Full daily tip in 13pt body text, warm brown (#3D3328), line height 1.75
  - For each prescription in the day:
    - "Start [Pattern Name] · [X] min" button: teal outlined button (teal border, teal text, 12pt uppercase tracked serif)
    - Tapping this button: dismisses the program sheet and switches to the Breathe tab with the specified pattern and duration pre-selected
  - If day includes BOLT reference in tip: "Take BOLT Test" text button in 11pt teal (opens BOLT sheet if Feature 10 is built, otherwise just a text note)

**Day Completion Logic:**
- A day is marked complete when the user completes at least one session matching ANY of the prescribed patterns on that calendar day
- Check on session save in `BreatheViewModel`: compare saved session's patternId against active program's current day prescriptions
- If match found: mark the day as complete in `ProgramProgress`

**Navigation Integration:**
- When user taps "Start [Pattern] · [X] min" in a program day:
  - Dismiss the program sheet
  - Dismiss the Learn tab context
  - Switch `MainTabView.selectedTab` to `.breathe`
  - Pre-select the pattern and duration in `BreatheViewModel`
- This requires making `MainTabView.selectedTab` observable/bindable, and adding a method to `BreatheViewModel` to accept external pattern/duration selection:
  ```swift
  func preSelectForProgram(patternId: String, durationMinutes: Int)
  ```

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/Components/ProgramCarousel.swift` — Horizontal program card scroll
- `Sources/SocraticJournal/Presentation/Programs/ProgramDetailView.swift` — Full program sheet
- `Sources/SocraticJournal/Presentation/Programs/ProgramViewModel.swift` — Progress tracking, day completion logic
- `Sources/SocraticJournal/Presentation/Programs/Components/ProgramDayCard.swift` — Expandable day row
- `Sources/SocraticJournal/Presentation/Programs/ProgramData.swift` — Static program definitions (all 3 programs)
- `Sources/SocraticJournal/Domain/Entities/Program.swift` — Program, ProgramDay, ProgramPrescription
- `Sources/SocraticJournal/Domain/Entities/ProgramProgress.swift` — Progress entity

**Modifications to Existing Files:**
- `LearnView.swift` — Add `ProgramCarousel` section at top, above quick facts
- `BreatheViewModel.swift` — Add `preSelectForProgram(patternId:durationMinutes:)` method
- `MainTabView.swift` — Make `selectedTab` accessible for programmatic switching (e.g., via `@Binding` or environment)
- `BreatheViewModel.swift` — In `saveSession()`, check active program and mark day complete if pattern matches

**Acceptance Criteria:**
- 3 program cards visible in horizontal scroll on Learn tab
- Cards show name, duration badge, and progress bar (if started)
- Program detail shows all days with correct status icons
- Current day and past days are expandable, future days are locked
- Daily tip text displays correctly with editorial typography
- "Start [Pattern]" button navigates to Breathe tab with correct pattern/duration
- Multi-pattern days show multiple start buttons
- Day completion triggers automatically when matching session is completed on that calendar day
- Program progress persists across app launches
- Progress bar on Learn tab card updates correctly
- Sheet dismisses cleanly
- Works correctly when no programs have been started (all show "START")

**Priority:** 15
**Dependencies:** 12

---

### 16. Nasal Breathing Training — Interactive Exercises

**User Story:** As a user learning to switch from mouth to nasal breathing, I want guided interactive exercises — like "Nose Unblocking" and "Breath Awareness Check" — that teach me practical techniques from the Buteyko method and Nestor's book, so I can build nasal breathing habits throughout my day.

**Description:** Adds a "Training" section to the Learn tab with 4 interactive micro-exercises. These are NOT breath-pacing sessions — they're short instructional activities with timers, prompts, and self-assessment. Think of them as the practical "homework" from the book.

**Access Point on Learn Tab:**
- New section between the Programs carousel and the chapter articles
- "TRAINING" section header in 11pt uppercase tracked dim text
- 4 exercise cards in a 2×2 grid:
  - Each card: `(screenWidth - 48 - 12) / 2` wide × 100pt tall (48 = 2×24pt screen padding, 12 = gap between cards)
  - Light surface background (`AppColors.surface`), hairline border, 8pt corner radius
  - SF Symbol icon in 20pt teal (top-left of card)
  - Exercise name in 13pt serif bold dark (below icon)
  - Duration: "2 min" in 9pt dim (bottom-left)
  - Completion count: "Done 3×" in 9pt teal (bottom-right), or "New" badge (teal pill, 8pt bold white text) if never done
- Tapping a card opens the exercise flow as a `.sheet`

**Exercise Flow Architecture:**
Each exercise is a step-by-step flow presented in a sheet. Steps auto-advance or require user tap.

- State machine: `currentStep: Int`, each step has a type (instruction, timer, tap-response, result)
- Navigation: "Next" button or auto-advance after timer completes
- Top: exercise name, step progress dots (small circles, teal = current/past, dim = future)
- Middle: step content (varies by type)
- Bottom: action button or timer display
- Close button (X) in top-right at all times (with confirmation if mid-exercise: "End exercise?" alert)

**The 4 Exercises:**

**Exercise 1: "Nose Unblocking" (icon: `wind`, duration: 2 min)**

Description card (shown before steps): "A Buteyko technique to clear nasal congestion without medication. Works by deliberately increasing CO₂ levels to trigger vasodilation in the nasal passages."

Steps:
1. **Instruction:** "Take a small, gentle breath in through your nose" — auto-advance after 3s
2. **Instruction:** "Let a small, gentle breath out through your nose" — auto-advance after 3s
3. **Instruction:** "Pinch your nose closed with your fingers" — auto-advance after 1s
4. **Timer (count-up):** "Walk around the room, holding your breath, nodding your head up and down" — shows timer counting up from 0, "Tap when you need to breathe" button (teal outlined), auto-stop at 30s with note "Maximum reached"
5. **Instruction:** "Release your nose and breathe gently through it" — auto-advance after 5s
6. **Timer (countdown):** "Breathe very gently for 30 seconds — smaller breaths than normal" — 30s countdown timer, auto-advance when done
7. **Result:** "How clear does your nose feel?" — 5-point scale: tap 1 ("Still blocked") through 5 ("Completely clear"), teal highlight on selected, each number is a 36×36pt circle. Below: "Repeat if needed. The effect often improves with each round."

**Exercise 2: "Breath Awareness Check" (icon: `person.fill`, duration: 1 min)**

Description card: "A quick self-assessment of your current breathing pattern. Are you breathing through your nose? Is your tongue right? Are you using your diaphragm?"

Steps:
1. **Tap response:** "Close your mouth. Is your tongue resting on the roof of your mouth, just behind your front teeth?" — Two buttons: "Yes" (teal outlined) / "No" (dim outlined)
2. **Tap response:** "Place one hand on your chest and one on your belly. Take a normal breath. Which hand moves more?" — Two buttons: "Chest" / "Belly"
3. **Timer + tap counter:** "Without changing anything, count your breaths for 30 seconds. Tap the circle each time you complete a breath." — Large tappable circle (80pt, teal border, tap feedback: brief scale pulse + haptic), breath count displayed large (28pt serif bold) in center of circle, 30s countdown below
4. **Result card** showing all three assessments with feedback:
   - **Tongue:** If "Yes": "Correct — tongue on the palate is the natural resting position. This supports nasal breathing." (13pt, teal-tinted). If "No": "Try gently pressing your tongue to the roof of your mouth. This is called 'mewing' and helps maintain nasal breathing." (13pt, coral-tinted)
   - **Breathing type:** If "Belly": "Good — diaphragmatic breathing is correct. The belly moves because the diaphragm pushes down." If "Chest": "Chest breathing is shallow and activates the stress response. Practice directing breath into the belly."
   - **Breath rate:** Calculate BPM = taps × 2 (since it's 30 seconds). If > 14: "You're over-breathing at X BPM. The optimal resting rate is 5-8 breaths per minute." (coral). If 8-14: "Average range at X BPM. Practice will lower this." (brown). If < 8: "Excellent — X BPM indicates strong breathing efficiency." (teal)

**Exercise 3: "Mouth Tape Readiness" (icon: `xmark.circle`, duration: 3 min)**

Description card: "A guided introduction to mouth taping for sleep. James Nestor and Patrick McKeown both recommend this — this exercise tests your nasal breathing comfort."

Steps:
1. **Instruction:** "Sit comfortably and close your mouth" — auto-advance after 3s
2. **Timer (countdown):** "Breathe only through your nose for 60 seconds. Notice: can you breathe comfortably the entire time?" — 60s countdown, "I need to stop" panic button (coral outlined) that immediately advances to step 3 with "Very difficult" pre-selected
3. **Tap response:** "How was that?" — Three buttons: "Easy" (teal) / "Some difficulty" (brown) / "Very difficult" (coral)
4. **Result card** based on selection:
   - **Easy:** "You're ready for mouth taping during sleep. Start with a small piece of micropore tape vertically over your lips. If you can breathe around it, that's fine — it's a gentle reminder, not a seal. Nestor taped his mouth every night during his research and calls it the single most impactful change he made."
   - **Some difficulty:** "Your nasal passages may need more time. Practice the Nose Unblocking exercise daily for a week, then try this test again. Many people find dramatic improvement within days."
   - **Very difficult:** "Don't tape yet. Focus on the Nose Unblocking exercise and Buteyko Reduced pattern daily. If you have a deviated septum or chronic congestion, consider seeing an ENT specialist. The goal is comfort, not force."

**Exercise 4: "CO₂ Tolerance Builder" (icon: `lungs`, duration: 5 min)**

Description card: "A progressive hold exercise that gently extends your CO₂ tolerance over 5 rounds. Based on Buteyko's reduced breathing principles."

Steps (repeat 5 rounds — use a loop with round counter):
For each round (1-5):
1. **Timer (countdown):** "Breathe normally through your nose" — 15s countdown, "Round X of 5" in 11pt dim above
2. **Instruction:** "Take a normal breath in... and out" — auto-advance after 4s
3. **Timer (count-up):** "Hold after the exhale — tap when you feel the first urge to breathe" — counts up from 0.0 with 1 decimal, auto-stop at 60s. Tap anywhere to stop. Record the hold time.
4. **Brief result:** "Hold: X.Xs" displayed for 2s, then auto-advance to next round

After 5 rounds — **Summary result card:**
- "Your 5 holds" as a vertical list: Round 1: X.Xs, Round 2: X.Xs, etc. — each in 13pt with round label in dim
- Average: "Average: X.Xs" in 15pt serif bold teal
- Trend analysis:
  - If last hold > first hold by >3s: "Your holds got longer — CO₂ tolerance improves even within a single exercise." (teal text)
  - If holds are consistent (within ±3s): "Consistent holds — your tolerance is stable. Regular practice will extend these over weeks." (dim text)
  - If last hold < first hold by >3s: "Shorter toward the end — this is common. Try slower, gentler breathing between rounds next time." (brown text)
- "Your average (X.Xs) suggests a BOLT score in the [tier] range" in 11pt dim (use BOLTTier.from(score:) if Feature 10 is available, otherwise just show the average)

**Completion Tracking:**
- Store in UserDefaults with key `"com.breathe.training"` as `[String: Int]` dictionary (exercise ID → completion count)
- Increment count after reaching the final result card of each exercise
- Exercise IDs: "nose_unblocking", "breath_awareness", "mouth_tape", "co2_builder"

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/Components/TrainingGrid.swift` — 2×2 exercise card grid
- `Sources/SocraticJournal/Presentation/Training/TrainingFlowView.swift` — State machine container for step-by-step flow
- `Sources/SocraticJournal/Presentation/Training/TrainingViewModel.swift` — Step state management, timer logic, response tracking
- `Sources/SocraticJournal/Presentation/Training/Components/TrainingStepCard.swift` — Individual step view (renders instruction, timer, or tap-response based on step type)
- `Sources/SocraticJournal/Presentation/Training/Components/TrainingTimerView.swift` — Countdown and count-up timer display
- `Sources/SocraticJournal/Presentation/Training/Components/TrainingResultCard.swift` — Result display with feedback
- `Sources/SocraticJournal/Presentation/Training/TrainingData.swift` — Exercise definitions and step structures

**Modifications to Existing Files:**
- `LearnView.swift` — Add `TrainingGrid` section between program carousel and chapter articles

**Acceptance Criteria:**
- 4 exercises visible in 2×2 grid on Learn tab
- Each card shows correct icon, name, duration, and completion count
- "New" badge appears for never-completed exercises
- Step-by-step flow advances correctly (auto-advance for timed steps, tap for response steps)
- Timers are accurate — countdown decrements, count-up increments at 100ms resolution
- Breath Awareness tap counter works: tapping circle increments count with haptic + visual feedback
- BPM calculation correct: taps × 2 for 30-second window
- CO₂ Builder tracks all 5 rounds and shows accurate summary
- Results show correct interpretive text based on user responses
- Nose Unblocking 5-point scale is tappable with teal highlight
- Mouth Tape "panic button" works and pre-selects "Very difficult"
- Close button (X) shows confirmation alert mid-exercise
- Completion count increments after finishing (reaching result card)
- Completion counts persist across app launches
- All exercises follow editorial design system
- Haptic feedback: gentle tap at timer start/end, tap circle feedback in Breath Awareness

**Priority:** 16
**Dependencies:** 12

---

### 17. Final Integration Test & Build Verification

**User Story:** As a developer, I need to verify that all Phase 3 features compile, all tests pass, and the app runs without crashes — so the codebase is in a shippable state.

**Description:** Final pass to run the full test suite, verify compilation, and ensure no regressions.

**Steps:**
1. Run `xcodegen generate` to regenerate the Xcode project with any new files
2. Run `xcodebuild build -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` — must succeed with zero errors
3. Run `xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing SocraticJournalTests` — all tests must pass
4. Fix any compilation errors or test failures found
5. Verify no compiler warnings in the main target (test target warnings are acceptable)

**Acceptance Criteria:**
- `xcodegen generate` succeeds
- `xcodebuild build` exits with zero errors
- `xcodebuild test` exits with zero test failures
- No crashes when navigating all tabs
- No stale references to deleted types anywhere in the codebase
- All new features' views are reachable from the navigation

**Priority:** 17
**Dependencies:** 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
