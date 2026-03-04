---
base_branch: feature/breath-pivot-1
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breath Pacer — Science-Backed Breathing Companion

> A complete pivot from Socratic Journal to a minimal, science-backed breathing companion. Four tabs: **Today** (daily driver with streak + quick start), **Breathe** (core session experience with mountain wave animation), **Learn** (bite-sized breathing science), **Progress** (stats, heatmap, session history). Phase 1 MVP: Resonant (5.5/5.5) + Coherent (6/6) patterns, 5 and 10 min sessions, mountain wave breath guide, streak tracking, 3 core articles, onboarding.
>
> **Pillars:** Science-backed. Habit-first. iOS native feel. Non-spiritual. Offline-first.

---

### 1. Strip Socratic Journal & Scaffold Breath App Foundation

**User Story:** As a developer, I need to remove all Socratic Journal domain logic, data services, and presentation code so the codebase is clean and ready for the new Breath Pacer app — while preserving the infrastructure (theme system, Firebase config, settings persistence, app shell).

**What to REMOVE (delete these files/directories entirely):**
- `Sources/SocraticJournal/Domain/Entities/` — Delete: DailyQuestion.swift, VoiceAnswer.swift, QuestionStreak.swift, AnswerReveal.swift, Friendship.swift, FriendGroup.swift, SpicyTakeAward.swift, Subscription.swift. Keep User.swift but gut it to a minimal stub (just id, displayName, createdAt).
- `Sources/SocraticJournal/Domain/Repositories/` — Delete: QuestionRepositoryProtocol.swift, UserRepositoryProtocol.swift, FriendshipRepositoryProtocol.swift, VoiceAnswerRepositoryProtocol.swift. Keep SettingsRepositoryProtocol.swift.
- `Sources/SocraticJournal/Domain/Services/` — Delete: QuestionFeedServiceProtocol.swift, VoiceRecordingServiceProtocol.swift, UserProfileServiceProtocol.swift, FriendServiceProtocol.swift, AnswerRevealServiceProtocol.swift, SubscriptionServiceProtocol.swift, NotificationServiceProtocol.swift. Keep AnalyticsServiceProtocol.swift.
- `Sources/SocraticJournal/Data/Services/` — Delete: VoiceRecordingService.swift, StoreKitSubscriptionService.swift, OfflineSyncHandler.swift, OfflineSyncQueue.swift, BackendHealthService.swift, FirebaseFunctionsService.swift. Keep: FirebaseAnalyticsService.swift, LocalNotificationService.swift, NetworkMonitor.swift, AppsFlyerService.swift.
- `Sources/SocraticJournal/Data/Mock/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/QuestionFeed/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Recording/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Friends/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Reveals/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/History/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Sharing/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Paywall/` — Delete entire directory.
- `Sources/SocraticJournal/Presentation/Components/Audio/` — Delete entire directory.

**What to KEEP (preserve but update):**
- `App/SocraticJournalApp.swift` — Strip journal-specific init code. Remove Firebase Messaging delegate, AppsFlyer config, OfflineSyncQueue, BackendHealthService. Keep Firebase.configure(), ThemeManager, basic app structure with onboarding check.
- `App/Environment.swift` — Keep as-is.
- `Presentation/Theme/` — Keep entire directory intact (AppColors.swift, AppTypography.swift, AppSpacing.swift, AppShapes.swift, ThemeManager.swift). This is the design foundation.
- `Presentation/Settings/SettingsView.swift` — Strip journal-specific settings (friend activity, FOMO alerts, streak reminders, subscription settings). Keep theme selector, notification time picker. Add daily goal picker.
- `Presentation/Settings/Components/ThemeSelectorView.swift` — Keep.
- `Presentation/Settings/Components/NotificationSettingsView.swift` — Keep, update copy for breath reminders.
- `Presentation/Settings/Components/AboutView.swift` — Keep, update app name.
- `Presentation/Settings/Components/SubscriptionSettingsView.swift` — Delete.
- `Presentation/Navigation/MainTabView.swift` — Rewrite with 4 tabs (see below).
- `Domain/Entities/UserSettings.swift` — Strip subscription fields and journal booleans. Add: dailyGoalMinutes (Int, default 5), breathReminderEnabled (Bool), breathReminderHour/Minute.
- `Data/Repositories/UserDefaultsSettingsRepository.swift` — Keep, update key prefix.

**What to CREATE (new foundation):**

**New Domain Entities:**

`Sources/SocraticJournal/Domain/Entities/BreathTechnique.swift`:
```swift
// Defines available breath techniques with their phases and metadata
enum BreathPhaseType: String, Codable, Sendable {
    case inhale, hold, exhale
}

struct BreathPhase: Codable, Sendable, Identifiable {
    let id: String // e.g. "inhale", "hold1", "exhale", "hold2"
    let name: String // Display name: "inhale", "hold", "exhale" (lowercase serif style)
    let duration: TimeInterval
    let phaseType: BreathPhaseType
}

enum BreathDifficulty: String, Codable, Sendable {
    case beginner, intermediate
}

struct BreathTechnique: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let phases: [BreathPhase]
    let defaultDurationMinutes: Int
    let difficulty: BreathDifficulty
    let bestFor: String

    var cycleDuration: TimeInterval { phases.reduce(0) { $0 + $1.duration } }

    // Phase 1 — two patterns only
    static let resonant = BreathTechnique(
        id: "resonant",
        name: "Resonance Breathing",
        subtitle: "The Perfect Breath",
        description: "Inhale and exhale at 5.5 seconds each — the rate that synchronizes heart, lungs, and circulation for peak efficiency. ~5.5 BPM hits HRV resonance frequency.",
        phases: [
            BreathPhase(id: "inhale", name: "inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "exhale", duration: 5.5, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Daily wellness, HRV, calm focus"
    )

    static let coherent = BreathTechnique(
        id: "coherent",
        name: "Coherent Breathing",
        subtitle: "Calm Entry Point",
        description: "A slightly more accessible rhythm — 6 seconds in, 6 seconds out. Same coherence principle as resonance breathing. Great for beginners.",
        phases: [
            BreathPhase(id: "inhale", name: "inhale", duration: 6.0, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "exhale", duration: 6.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Beginners, relaxation, coherence"
    )

    static let allTechniques: [BreathTechnique] = [.resonant, .coherent]
}
```

`Sources/SocraticJournal/Domain/Entities/BreathSession.swift`:
```swift
struct BreathSession: Identifiable, Codable, Sendable {
    let id: String // UUID string
    let techniqueId: String
    let startedAt: Date
    let completedAt: Date
    let totalDuration: TimeInterval // seconds
    let cyclesCompleted: Int

    var date: Date { Calendar.current.startOfDay(for: startedAt) }
}
```

`Sources/SocraticJournal/Domain/Entities/DailyLog.swift`:
```swift
struct DailyLog: Identifiable, Codable, Sendable {
    let date: Date
    let sessions: [BreathSession]

    var id: Date { date }
    var totalMinutes: Double { sessions.reduce(0) { $0 + $1.totalDuration } / 60.0 }
    var sessionsCount: Int { sessions.count }
}
```

`Sources/SocraticJournal/Domain/Entities/LearningBit.swift`:
```swift
enum LearningCategory: String, Codable, Sendable, CaseIterable {
    case science = "The Science"
    case nasal = "Nasal Breathing"
    case ancient = "Ancient Wisdom"
}

struct LearningBit: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let body: String
    let category: LearningCategory
    let sourceNote: String? // optional attribution
}
```

**New Domain Protocols:**

`Sources/SocraticJournal/Domain/Repositories/BreathSessionRepositoryProtocol.swift`:
```swift
protocol BreathSessionRepositoryProtocol: Sendable {
    func saveSession(_ session: BreathSession) async throws
    func getSessionsForDate(_ date: Date) async throws -> [BreathSession]
    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession]
    func getTotalMinutesToday() async throws -> Double
    func getStreak() async throws -> Int // consecutive days with at least one session
}
```

`Sources/SocraticJournal/Domain/Services/BreathContentServiceProtocol.swift`:
```swift
protocol BreathContentServiceProtocol: Sendable {
    func getAllLearningBits() -> [LearningBit]
    func getLearningBitsForCategory(_ category: LearningCategory) -> [LearningBit]
}
```

**New Data Implementations:**

`Sources/SocraticJournal/Data/Repositories/UserDefaultsBreathSessionRepository.swift`:
- Implements BreathSessionRepositoryProtocol
- Persists sessions via UserDefaults with JSON encoding (key: "com.breathe.sessions")
- Streak calculation: iterate backwards from today counting consecutive days with sessions

`Sources/SocraticJournal/Data/Services/BreathContentService.swift`:
- Implements BreathContentServiceProtocol
- Returns hardcoded array of 3 LearningBit items (content provided in Feature 4)

**New Navigation — 4-Tab MainTabView (rewrite MainTabView.swift):**
```
Today  |  Breathe  |  Learn  |  Progress
```
- **Today** (SF Symbol: `sun.max.fill`) → TodayDashboardView (placeholder for now)
- **Breathe** (SF Symbol: `wind`) → BreathSessionView (placeholder for now)
- **Learn** (SF Symbol: `book.fill`) → LearnFeedView (placeholder for now)
- **Progress** (SF Symbol: `chart.bar.fill`) → ProgressView (placeholder for now)
- Keep existing minimal bottom bar aesthetic (hairline divider, cream background)
- Active tab: accent coral. Inactive: gray.

**Acceptance Criteria:**
- Project compiles with zero errors after all removals and additions
- All deleted directories/files are completely gone
- No references to questions, voice answers, friends, reveals, subscriptions, recording, paywall, or sharing remain anywhere in the codebase
- New entity files exist with proper Codable, Sendable, Identifiable conformance
- BreathTechnique.allTechniques returns 2 properly configured techniques (Resonant + Coherent)
- New protocols exist with async/await signatures
- UserDefaultsBreathSessionRepository can save and retrieve sessions
- BreathContentService returns learning bits
- MainTabView shows 4 tabs (Today, Breathe, Learn, Progress) with placeholder views
- App launches and shows the four-tab interface
- Theme system (colors, typography, spacing, shapes) is fully intact and unchanged
- Settings view works with breath-specific settings (daily goal, reminders, theme)
- SocraticJournalApp.swift compiles with stripped init code

**Priority:** 1
**Dependencies:** None

---

### 2. Breath Pacing Engine & Breathe Screen

**User Story:** As a user, I want to start a breath exercise and follow a beautiful, meditative mountain-wave animation that guides me through each phase (inhale, hold, exhale) with clear timing and haptic cues, so I can breathe with intention.

**Description:** This is the core interactive experience — the Breathe tab. The defining visual: a mountain/triangle wave animation where the line rises during inhale, holds flat at the peak, and descends during exhale. Calm, precise, immersive.

**The Mountain Wave Animation (core visual — this is the app's signature):**
- A triangle/mountain wave shape drawn as a live SVG-like path
- The line rises smoothly up the left slope during **inhale**
- Holds flat at the peak during any **hold** phase
- Descends smoothly down the right slope during **exhale**
- Like watching a mountain from the front — the breath literally climbs and descends
- Rendered as a custom SwiftUI Shape/Path that animates in real time
- Soft rounded vertices, no sharp corners (use `.quadCurve` or bezier smoothing at vertices)
- The peak glows gently during hold phases (subtle opacity pulse)
- The wave path draws from left to right as breath progresses through a cycle
- Wave color: Soft teal (AppColors.cardTeal) or warm accent on a near-black background
- Background: Deep navy transitioning subtly to warmer blue-teal over the session duration (the "colour arc" — imperceptible shift that creates a subliminal emotional arc)

**Phase Labels:**
- Large calm **lowercase** text: *inhale* / *hold* / *exhale*
- Use a serif-style font for phase labels — `Font.system(.largeTitle, design: .serif)` weight: .regular
- Fades smoothly between phases (crossfade transition)
- Phase countdown below the label: "3.2" in monospaced timer font (AppTypography.timer)
- Positioned center-screen below the mountain wave

**Session UI (minimal — immersive focus):**
- During session: just the mountain wave, phase label, and a quiet progress arc at the top
- Single tap pauses. No buttons visible unless paused
- Full-screen immersion, always dark themed regardless of system setting
- Total elapsed time shown subtly at top in caption
- Cycles completed shown subtly next to elapsed time

**BreathPacingEngine (@Observable, @MainActor):**
```
Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift
```
- Properties:
  - technique: BreathTechnique
  - currentPhase: BreathPhase
  - currentPhaseIndex: Int
  - phaseProgress: Double (0.0 → 1.0)
  - phaseTimeRemaining: TimeInterval
  - cyclesCompleted: Int
  - totalElapsedTime: TimeInterval
  - isRunning: Bool
  - isPaused: Bool
  - sessionDurationTarget: TimeInterval
- Methods:
  - start() — begins pacing
  - pause() / resume()
  - stop() → BreathSession (returns completed session data)
- Timer: Use DisplayLink or high-frequency Timer (~60Hz) for smooth animation
- Haptic feedback:
  - Phase transitions: UIImpactFeedbackGenerator(.soft)
  - No haptic mid-breath
  - Session complete: UINotificationFeedbackGenerator(.success)
- Session completes when totalElapsedTime >= sessionDurationTarget (finish the current cycle)

**Breathe Tab Flow:**
1. Breathe tab shows pattern selector (Resonant vs Coherent) + duration picker
2. Pattern cards show: name, subtitle, timing (e.g., "5.5s in · 5.5s out")
3. Duration picker: 5 min and 10 min (segmented control or pill buttons)
4. "Begin" button (AccentPillButton)
5. Tap Begin → 3-2-1 countdown overlay (large serif numbers, fading)
6. Pacing screen runs with mountain wave animation until duration reached
7. Session complete → summary bottom sheet: duration, cycles, streak update, affirming message ("Well done" — never ask for a rating)
8. Summary saves to repository, dismisses back to Breathe tab

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Breathe/BreatheTabView.swift` — Pattern selector + duration + begin
- `Sources/SocraticJournal/Presentation/Breathe/BreathPacingView.swift` — Main pacing screen (dark, immersive)
- `Sources/SocraticJournal/Presentation/Breathe/BreathSessionCompleteView.swift` — Completion summary sheet
- `Sources/SocraticJournal/Presentation/Breathe/Components/MountainWaveView.swift` — The animated mountain wave Shape
- `Sources/SocraticJournal/Presentation/Breathe/Components/PhaseLabel.swift` — Phase name + countdown (lowercase serif)
- `Sources/SocraticJournal/Presentation/Breathe/Components/CountdownOverlay.swift` — 3-2-1 pre-session countdown
- `Sources/SocraticJournal/Presentation/Breathe/Components/DurationPicker.swift` — 5/10 min selector
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternCard.swift` — Technique selector card
- `Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift` — The engine

**Acceptance Criteria:**
- Engine correctly cycles through all phases of both techniques
- Resonant: 2 phases (inhale 5.5s, exhale 5.5s) = 11s cycle
- Coherent: 2 phases (inhale 6s, exhale 6s) = 12s cycle
- Mountain wave animation draws smoothly — line rises on inhale, descends on exhale
- Phase labels show in lowercase serif, crossfade between phases
- Countdown timer accurate to 0.1s resolution
- Haptic feedback fires at each phase transition (.soft)
- 3-2-1 countdown appears before session starts
- Session complete summary shows accurate stats (duration, cycles, streak)
- Completed session is saved to BreathSessionRepository
- Pause/resume works (single tap to pause, resume button when paused)
- Duration picker allows 5 and 10 minute selections
- Dark background on pacing view — immersive, no visible UI chrome
- Background colour arc: subtle navy → blue-teal shift over session
- Setup view uses cream theme; pacing view is always dark

**Priority:** 2
**Dependencies:** 1

---

### 3. Today Dashboard — Daily Breath Tracking

**User Story:** As a user, I want to see my daily breath practice at a glance — what I've done today, my streak status, and a quick-start CTA — so I stay motivated and can easily begin a session.

**Description:** The Today tab is the home screen and daily driver. Shows streak ring, session status, reminder status, quick start, and tip of the day. Calm editorial design.

**Screen Layout (top to bottom in ScrollView):**

**Header:**
- "Today" in AppTypography.displayMedium (40pt bold), left-aligned
- Current date below: "Monday, 3 March" in AppTypography.caption
- Generous top padding (AppSpacing.heroTopPadding)

**Streak Ring + Status (hero section):**
- Centered GeometricRing (from AppShapes) showing daily goal progress
- Ring size: 200pt, accent color when progressing, success green when goal met
- Inside the ring: total minutes practiced today as large stat number (AppTypography.stat, 56pt)
- Below ring: "minutes today" label in caption
- Below that: daily goal context — "of 5 min goal" in textTertiary

**Streak Counter:**
- Below the ring: flame icon (SF Symbol: `flame.fill`) + streak count in bodyBold
- "3 day streak" or "Start your streak today" if zero
- 1-day grace window keeps streak alive (with a visual warning state)

**Quick Start CTA:**
- Full-width AccentPillButton: "Start Session" with play.fill icon
- Tapping navigates to Breathe tab (or directly to pacing with default technique)

**Tip of the Day:**
- A subtle card (AppColors.surfaceElevated) with a random breathing fact
- Small category badge, title in bodyBold, body in caption
- Rotates daily from the Learn content pool

**Today's Sessions (shown only if sessions exist):**
- Section header: "TODAY'S SESSIONS" (SectionHeaderView)
- List of completed sessions, most recent first
- Each row: technique name + duration + time (e.g., "Resonance · 5 min · 9:30 AM")
- Hairline dividers between rows

**Reminder Status:**
- If reminder is set: small text "Reminder set for 9:00 AM" in caption
- If not: "Set a daily reminder" as a tappable link to Settings

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardView.swift`
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardViewModel.swift` — loads daily data from BreathSessionRepository
- `Sources/SocraticJournal/Presentation/Today/Components/DailyProgressRing.swift` — streak ring with stat
- `Sources/SocraticJournal/Presentation/Today/Components/StreakIndicator.swift` — flame + count
- `Sources/SocraticJournal/Presentation/Today/Components/TipOfTheDayCard.swift` — daily fact card
- `Sources/SocraticJournal/Presentation/Today/Components/SessionHistoryRow.swift` — session list row

**Data Flow:**
- ViewModel loads sessions for today from BreathSessionRepository on appear
- Daily goal from UserSettings.dailyGoalMinutes
- Streak computed by repository
- Tip of day: pick a random LearningBit based on day-of-year seed (deterministic per day)
- ViewModel refreshes when returning from a completed session

**Acceptance Criteria:**
- Dashboard displays correctly with zero sessions (empty state is welcoming, not sad)
- Streak ring shows progress toward daily goal accurately
- Streak counter shows consecutive day count correctly
- Quick start CTA navigates to Breathe tab
- Tip of the day shows one fact, changes daily
- After completing a session, returning to Today shows updated stats immediately
- Session history lists today's completed sessions with correct times
- Uses existing theme system throughout (cream background, editorial typography)
- ScrollView performance is smooth

**Priority:** 3
**Dependencies:** 1, 2

---

### 4. Learn Tab — Breathing Science & Education

**User Story:** As a user, I want to browse interesting, bite-sized facts about breathing science so I understand why these techniques work and stay engaged with my practice.

**Description:** The Learn tab is an editorial-style feed of educational content cards. Phase 1 has 3 core articles. Content is hardcoded. Tone: fascinating and accessible, inspired by James Nestor's storytelling. No woo — just science.

**Content (3 hardcoded LearningBit items for Phase 1):**

1. **"Your Nose Makes Medicine"** (Nasal Breathing)
   "Your nasal sinuses produce nitric oxide — a molecule that opens blood vessels, fights bacteria, and helps your lungs absorb 10-15% more oxygen. Mouth breathing bypasses this entirely. Humming increases nasal nitric oxide by 15x. Every breath through your nose is a dose of your body's own pharmacy."
   Source: Lundberg et al. 1995, Weitzberg & Lundberg 2002

2. **"The Perfect Breath is 5.5 Seconds"** (The Science)
   "Researchers found that breathing at 5.5 breaths per minute creates 'coherence' — when heart, lungs, and circulation synchronize for peak efficiency. Buddhist monks chanting Om Mani Padme Hum and Catholics reciting the rosary in Latin both breathe at exactly this rate. These traditions developed independently, yet converged on the same optimal rhythm."
   Source: Bernardi et al. 2001, James Nestor "Breath"

3. **"We Are the Worst Breathers on Earth"** (The Science)
   "No other species suffers from chronic snoring, sleep apnea, or breathing dysfunction at the rates humans do. The shift to soft processed foods over millennia shrank our jaws and narrowed our airways. When James Nestor plugged his nose for 10 days, his blood pressure hit stage 2 hypertension, snoring increased 4,800%, and he averaged 25 sleep apnea events per night. Switching back to nasal breathing reversed it all."
   Source: James Nestor "Breath", Stanford experiment

**Screen Layout:**
- "Learn" in AppTypography.displayMedium, left-aligned at top with heroTopPadding
- Subtitle: "The science of breathing" in AppTypography.body, textSecondary
- Vertical stack of LearningCard components
- Each card:
  - Rounded corners (16pt), padding (AppSpacing.cardPadding)
  - Category tag at top: small colored pill badge with category name
  - Title: AppTypography.headline (bold)
  - Body: AppTypography.bodyLarge (20pt), generous line spacing for readability
  - Card backgrounds alternate: AppColors.surface (white), AppColors.surfaceElevated (cream)
  - Cards separated by AppSpacing.cardGap

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedView.swift`
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedViewModel.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/LearningCard.swift`

**Acceptance Criteria:**
- All 3 learning bits display in a clean scrollable feed
- Cards have clear typography hierarchy (category badge, title, body)
- Content is factually accurate and attributed
- Scrolling performance is smooth
- Design feels editorial, calm, and meditative
- No walls of text — each card is a digestible chunk

**Priority:** 4
**Dependencies:** 1

---

### 5. Progress Tab — Stats & Session History

**User Story:** As a user, I want to see my breathing practice history and stats over time — my streak calendar, total minutes, session count, and a log of past sessions — so I can see my progress and stay motivated.

**Description:** The Progress tab provides a stats overview and session history. A clean, data-rich view that rewards consistency. Uses the existing editorial design language.

**Screen Layout (top to bottom in ScrollView):**

**Header:**
- "Progress" in AppTypography.displayMedium, left-aligned with heroTopPadding

**Stats Row (horizontal, 3 stat cards):**
- Three compact stat cards side by side in an HStack:
  1. **Total Minutes** — Large number (AppTypography.statSmall, 32pt) + "minutes" caption. Background: AppColors.cardTeal
  2. **Sessions** — Total session count + "sessions" caption. Background: AppColors.surface with border
  3. **Best Streak** — Longest consecutive day streak + "day streak" caption. Background: AppColors.cardYellow
- Each card: rounded corners, compact (equal width, ~100pt height)

**Streak Calendar Heatmap:**
- Section header: "THIS MONTH" (SectionHeaderView)
- A calendar grid showing the current month
- Each day cell: small square or circle
  - Days with sessions: filled accent color (opacity based on minutes — more minutes = more opaque)
  - Today: bordered accent circle
  - Future days: empty/dimmed
  - Days without sessions: light border only
- Shows day-of-week headers (M T W T F S S)
- Simple, not over-engineered — a LazyVGrid with 7 columns

**Session History:**
- Section header: "RECENT SESSIONS" (SectionHeaderView)
- Reverse chronological list of all sessions (last 30 days)
- Each row shows: date header (if different from previous), technique name, duration, time
- Group by date with date headers: "Today", "Yesterday", "Monday, 28 Feb"
- Each session row: technique icon/color dot + technique name + duration + time
- Hairline dividers between rows

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Progress/ProgressDashboardView.swift`
- `Sources/SocraticJournal/Presentation/Progress/ProgressDashboardViewModel.swift`
- `Sources/SocraticJournal/Presentation/Progress/Components/StatsRow.swift`
- `Sources/SocraticJournal/Presentation/Progress/Components/StreakCalendarView.swift`
- `Sources/SocraticJournal/Presentation/Progress/Components/SessionHistoryList.swift`
- `Sources/SocraticJournal/Presentation/Progress/Components/SessionHistoryRow.swift`

**Data Flow:**
- ViewModel loads all sessions from repository
- Computes: total minutes (all time), total sessions, best streak, this month's daily data
- Groups sessions by date for history list
- Refreshes on appear

**Acceptance Criteria:**
- Stats row shows accurate total minutes, session count, best streak
- Calendar heatmap shows current month with correct session indicators
- Days with sessions are visually distinct from days without
- Session history is grouped by date, sorted reverse chronologically
- Empty state: welcoming message ("Complete your first session to see progress here")
- Scrolling is smooth even with many sessions
- Uses existing theme components (SectionHeaderView, HairlineDivider, etc.)

**Priority:** 5
**Dependencies:** 1, 2

---

### 6. Onboarding Flow — Welcome to Breath

**User Story:** As a new user, I want a brief, beautiful onboarding that introduces breath pacing and gets me excited to start my first session — in 3 screens or fewer, with no account creation.

**Description:** A 3-page swipeable onboarding. Replace existing NewOnboardingView and all onboarding pages. Calm, confident, inviting tone. Minimal text, strong typography, meditative visuals.

**Delete existing onboarding page files:**
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingWelcomePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingUnlockPage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingVoicePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingFriendsPage.swift`

**Page 1 — "You breathe 25,000 times a day.":**
- Cream background (AppColors.background)
- Large display text: "You breathe 25,000 times a day." (AppTypography.display, 34pt)
- Below: "Most of them wrong." in bodyLarge, textSecondary
- Center of screen: a gentle animated preview of the mountain wave breathing at resonant pace (5.5s in, 5.5s out) — small, subtle, decorative. Use the MountainWaveView from Feature 2 in a demo/preview mode.
- Teal color at ~50% opacity, no phase labels — just the visual breathing motion
- Sets the tone: honest, scientific, beautiful

**Page 2 — "Science-Backed Breathing":**
- Cream background
- Display text: "Science-Backed Breathing" (AppTypography.display)
- Below: the 2 Phase 1 techniques listed vertically with subtle left border accents (4pt accent-colored left border):
  - **Resonance Breathing** — 5.5s in · 5.5s out — The perfect breath
  - **Coherent Breathing** — 6s in · 6s out — Calm entry point
- Each item: technique name in bodyBold, timing + subtitle in caption
- Subtitle at bottom: "Each backed by research. Guided by a simple visual." (body, textSecondary)

**Page 3 — "Just 5 Minutes a Day":**
- Accent coral background (AppColors.accent) with white text
- Display text: "Just 5 Minutes a Day" (AppTypography.displayLarge, white)
- Subtitle: "Track your practice. Learn the science. Breathe with intention." (bodyLarge, white at 80% opacity)
- "Get Started" button: white filled pill with accent text (inverted AccentPillButton)
- Tapping sets hasCompletedOnboarding = true in UserSettings and dismisses

**Container (NewOnboardingView.swift — rewrite):**
- TabView with PageTabViewStyle for swipe navigation
- Page indicators: small dots at bottom, accent color
- No skip button — only 3 pages, quick to swipe
- "Get Started" only on page 3

**Views to Create/Modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — Complete rewrite
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingBreathePage.swift` — Page 1
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingSciencePage.swift` — Page 2
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingStartPage.swift` — Page 3

**Acceptance Criteria:**
- 3-page swipeable onboarding on first launch (hasCompletedOnboarding = false)
- Page 1 has animated mountain wave preview
- Page 2 lists the 2 Phase 1 techniques with accurate names and timings
- Page 3 "Get Started" button dismisses onboarding permanently
- Returning users go straight to Today dashboard
- Zero references to Socratic Journal, questions, voice, or friends
- Clean, minimal, calming aesthetic throughout
- Works in both light and dark mode (pages use their own backgrounds)

**Priority:** 6
**Dependencies:** 1, 2 (reuses MountainWaveView)

---

### 7. App Identity & Polish Pass

**User Story:** As a user, I want the app to feel cohesive and polished — consistent naming, smooth transitions, haptic feedback, and attention to detail throughout.

**Description:** Final polish pass tying everything together. Update app identity, refine transitions, add haptics, handle edge cases, clean up settings.

**Identity Updates:**
- Search entire codebase for remaining "Socratic Journal" or "socraticjournal" strings — replace with "Breathe" / "breathe" in all user-facing strings
- Update AboutView app name to "Breathe"
- Update UserDefaults key prefix from "com.socraticjournal" to "com.breathe" where applicable

**Navigation & Transitions:**
- Smooth NavigationStack push transitions within each tab
- Full-screen cover for the pacing view (focused experience, no back swipe during session)
- Sheet presentation for session complete (medium detent)
- Tab switching is instant, no custom animation needed

**Haptic Feedback (throughout the app):**
- Phase transitions during pacing: UIImpactFeedbackGenerator(.soft)
- Session start (after countdown): UIImpactFeedbackGenerator(.medium)
- Session complete: UINotificationFeedbackGenerator(.success)
- Technique card tap: UIImpactFeedbackGenerator(.light)
- Tab bar selection: UISelectionFeedbackGenerator

**Settings Polish:**
- SettingsView sections (ALL-CAPS editorial headers):
  - "PRACTICE" section: Daily goal picker (segmented: 3 / 5 / 10 / 15 min)
  - "REMINDERS" section: Daily reminder toggle + time picker (1 reminder slot for Phase 1)
  - "APPEARANCE" section: Theme selector (existing)
  - "ABOUT" section: App version, "Breathe" name
- Remove any remaining journal settings (friend activity, FOMO, subscription, etc.)
- Hairline dividers between sections

**Edge Cases & Robustness:**
- App backgrounding during session: automatically pause, resume on foreground (ScenePhase)
- Phase label typography: lowercase serif throughout sessions — *inhale*, *hold*, *exhale*
- No rating prompts during or after sessions — ever
- Dynamic Type: ensure stat numbers, technique cards, and learning bits scale reasonably
- VoiceOver: breath mountain wave announces phase changes at transitions ("Inhale", "Hold", "Exhale")

**Acceptance Criteria:**
- Zero references to "Socratic Journal" visible anywhere in UI or user-facing strings
- All navigation transitions feel smooth and intentional
- Haptic feedback present at all specified interaction points
- Settings view clean, minimal, and relevant to breath app only
- Daily goal configurable in settings (3/5/10/15 min)
- App handles backgrounding/foregrounding during sessions
- VoiceOver announces breath phases
- Overall experience feels like one cohesive, meditative app
- Phase labels are lowercase serif throughout

**Priority:** 7
**Dependencies:** 1, 2, 3, 4, 5, 6
