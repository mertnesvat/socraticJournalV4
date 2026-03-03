---
base_branch: master
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breath — Pacing & Learning App

> A complete pivot from Socratic Journal to a breath pacing app inspired by James Nestor's "Breath." Two tabs: **Today** (daily breath exercise tracking & sessions) and **Learn** (bite-sized educational content about breathing science). Clean, meditative design language built on the existing editorial theme system.

---

### 1. Strip Socratic Journal & Scaffold Breath App Foundation

**User Story:** As a developer, I need to remove all Socratic Journal domain logic, data services, and presentation code so the codebase is clean and ready for the new Breath app — while preserving the infrastructure (theme system, Firebase config, settings persistence, app shell).

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
- `Presentation/Navigation/MainTabView.swift` — Rewrite with 2 tabs.
- `Domain/Entities/UserSettings.swift` — Strip subscription fields and journal booleans. Add: dailyGoalMinutes (Int, default 5), breathReminderEnabled (Bool), breathReminderHour/Minute.
- `Data/Repositories/UserDefaultsSettingsRepository.swift` — Keep, update key prefix.

**What to CREATE (new foundation):**

**New Domain Entities:**

`Sources/SocraticJournal/Domain/Entities/BreathTechnique.swift`:
```swift
// Defines available breath techniques with their phases and metadata
enum BreathPhaseType: String, Codable, Sendable {
    case inhale, hold, exhale, inhaleTopUp
}

struct BreathPhase: Codable, Sendable, Identifiable {
    let id: String // e.g. "inhale", "hold1", "exhale", "hold2"
    let name: String // Display name: "Inhale", "Hold", "Exhale"
    let duration: TimeInterval
    let phaseType: BreathPhaseType
}

enum BreathDifficulty: String, Codable, Sendable {
    case beginner, intermediate, advanced
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

    static let resonant = BreathTechnique(
        id: "resonant",
        name: "Resonant Breathing",
        subtitle: "The Perfect Breath",
        description: "Inhale and exhale at 5.5 seconds each — the rate that synchronizes heart, lungs, and circulation for peak efficiency. Discovered independently by prayer traditions worldwide.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 5.5, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Daily wellness, heart rate variability, calm focus"
    )

    static let boxBreathing = BreathTechnique(
        id: "box",
        name: "Box Breathing",
        subtitle: "Navy SEAL Focus",
        description: "Four equal phases — inhale, hold, exhale, hold — creating a 'box' pattern. Calms without sedating and focuses without winding you up. Used by elite military operators.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold1", name: "Hold", duration: 4.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4.0, phaseType: .exhale),
            BreathPhase(id: "hold2", name: "Hold", duration: 4.0, phaseType: .hold)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Acute stress, pre-performance focus, concentration"
    )

    static let fourSevenEight = BreathTechnique(
        id: "478",
        name: "4-7-8 Breathing",
        subtitle: "Natural Tranquilizer",
        description: "Dr. Andrew Weil's technique rooted in ancient pranayama. The exhale is twice the inhale length, maximally activating the vagus nerve. A natural tranquilizer for the nervous system.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 7.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 3,
        difficulty: .intermediate,
        bestFor: "Sleep preparation, anxiety relief, winding down"
    )

    static let cyclicSighing = BreathTechnique(
        id: "cyclic_sigh",
        name: "Cyclic Sighing",
        subtitle: "Stanford Stress Reset",
        description: "Based on the physiological sigh your body performs naturally. A double inhale fully inflates the lungs, then a long exhale offloads CO₂. Stanford proved 5 minutes beats meditation for mood.",
        phases: [
            BreathPhase(id: "inhale1", name: "Inhale", duration: 2.0, phaseType: .inhale),
            BreathPhase(id: "inhale2", name: "Top Up", duration: 2.0, phaseType: .inhaleTopUp),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Quick stress relief, mood improvement, calm"
    )

    static let allTechniques: [BreathTechnique] = [.resonant, .boxBreathing, .fourSevenEight, .cyclicSighing]
}
```

`Sources/SocraticJournal/Domain/Entities/BreathSession.swift`:
```swift
struct BreathSession: Identifiable, Codable, Sendable {
    let id: String // UUID string
    let techniqueId: String
    let startedAt: Date
    let completedAt: Date
    let totalDuration: TimeInterval
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
    case techniques = "Techniques"
    case facts = "Surprising Facts"
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
- Returns hardcoded array of 15+ LearningBit items (content provided in Feature 4)

**New Navigation (update MainTabView.swift):**
- Two tabs:
  - **Today** (SF Symbol: `wind`) → TodayDashboardView (placeholder for now)
  - **Learn** (SF Symbol: `book.fill`) → LearnFeedView (placeholder for now)
- Keep the existing minimal bottom bar aesthetic (hairline divider, cream background)
- Active tab: accent coral icon. Inactive: gray icon.

**Acceptance Criteria:**
- Project compiles with zero errors after all removals and additions
- All deleted directories/files are completely gone
- No references to questions, voice answers, friends, reveals, subscriptions, recording, paywall, or sharing remain anywhere in the codebase
- New entity files exist with proper Codable, Sendable, Identifiable conformance
- BreathTechnique.allTechniques returns 4 properly configured techniques
- New protocols exist with async/await signatures
- UserDefaultsBreathSessionRepository can save and retrieve sessions
- BreathContentService returns learning bits
- MainTabView shows two tabs (Today, Learn) with placeholder views
- App launches and shows the two-tab interface
- Theme system (colors, typography, spacing, shapes) is fully intact and unchanged
- Settings view works with breath-specific settings (daily goal, reminders, theme)
- SocraticJournalApp.swift compiles with stripped init code

**Priority:** 1
**Dependencies:** None

---

### 2. Breath Pacing Engine & Session View

**User Story:** As a user, I want to start a breath exercise and see a beautiful, meditative visual animation that guides me through each phase (inhale, hold, exhale) with clear timing so I can follow along effortlessly.

**Description:** This is the core interactive experience — the breath pacing screen. It should feel calm, precise, and visually stunning. A single expanding/contracting circle that breathes with you.

**The Pacing Circle (core visual):**
- A large circle centered on screen that animates with the breath phases
- **Inhale:** Circle smoothly expands from ~40% to 100% size with ease-in-out
- **Hold:** Circle holds at current size with a very subtle pulse (±2% scale oscillation)
- **Exhale:** Circle smoothly contracts from 100% back to ~40%
- **Inhale Top-Up (cyclic sighing):** Circle expands from ~70% to 100% (second inhale)
- Circle color: Use AppColors.accent (coral) or AppColors.cardTeal — warm and alive
- Faint radial glow/shadow behind the circle for depth
- Background: Near-black (AppColors.backgroundDark) for meditative focus
- Phase label ("Inhale", "Hold", "Exhale", "Top Up") centered inside circle — large, calm font (AppTypography.headline)
- Small countdown for current phase below the label (e.g., "3.2s") in monospaced timer font
- Total elapsed time and cycles completed shown subtly at top in caption style

**BreathPacingEngine (@Observable, @MainActor):**
```
Sources/SocraticJournal/Presentation/Session/BreathPacingEngine.swift
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
  - circleScale: Double (computed from phase type + progress)
- Methods:
  - start() — begins pacing
  - pause() / resume()
  - stop() → BreathSession (returns completed session data)
- Timer: Use CADisplayLink or high-frequency Timer (~60Hz) for smooth animation
- circleScale computation:
  - .inhale: lerp(minScale, maxScale, easeInOut(progress)) where minScale=0.4, maxScale=1.0
  - .inhaleTopUp: lerp(0.7, 1.0, easeInOut(progress))
  - .exhale: lerp(maxScale, minScale, easeInOut(progress))
  - .hold: currentScale + sin(time * 4) * 0.02 (subtle oscillation)
- Haptic feedback at each phase transition (UIImpactFeedbackGenerator, .soft style)
- Session completes when totalElapsedTime >= sessionDurationTarget (finish the current cycle first)

**Session Flow:**
1. User taps technique card on Today → BreathSessionSetupView
2. Setup screen shows: technique name, subtitle, description, phase timing diagram, duration picker (1, 3, 5, 10 min), "Begin" button
3. Tap Begin → 3-2-1 countdown overlay (large numbers, fading)
4. Pacing screen runs with animated circle until duration reached
5. Session complete → summary screen: duration, cycles, "Well done" + save button
6. Return to Today dashboard with updated stats

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Session/BreathSessionSetupView.swift` — Technique info + duration picker + begin
- `Sources/SocraticJournal/Presentation/Session/BreathPacingView.swift` — Main pacing screen with circle
- `Sources/SocraticJournal/Presentation/Session/BreathSessionCompleteView.swift` — Completion summary
- `Sources/SocraticJournal/Presentation/Session/Components/BreathCircleView.swift` — Animated circle component
- `Sources/SocraticJournal/Presentation/Session/Components/PhaseLabel.swift` — Phase name + countdown
- `Sources/SocraticJournal/Presentation/Session/Components/CountdownOverlay.swift` — 3-2-1 pre-session countdown
- `Sources/SocraticJournal/Presentation/Session/Components/DurationPicker.swift` — Segmented duration selector
- `Sources/SocraticJournal/Presentation/Session/BreathPacingEngine.swift` — The engine

**Visual Design Details:**
- BreathCircleView: Circle with gradient fill (accent → slightly darker accent), subtle shadow/glow
- Use `.animation(.easeInOut(duration: phaseDuration))` for circle scale transitions
- Phase transitions should be seamless — SwiftUI animation handles the interpolation
- The pacing view is always dark themed regardless of system theme setting
- Setup and complete views use the standard cream theme

**Acceptance Criteria:**
- Engine correctly cycles through all phases of all 4 techniques
- Resonant: 2 phases (inhale 5.5s, exhale 5.5s)
- Box: 4 phases (inhale 4s, hold 4s, exhale 4s, hold 4s)
- 4-7-8: 3 phases (inhale 4s, hold 7s, exhale 8s)
- Cyclic Sighing: 3 phases (inhale 2s, top-up 2s, exhale 8s)
- Circle animation is smooth at 60fps
- Phase labels update in sync with animation
- Countdown timer accurate to 0.1s resolution
- Haptic feedback fires at each phase transition
- 3-2-1 countdown appears before session starts
- Session complete screen shows accurate stats (duration, cycles)
- Completed session is saved to BreathSessionRepository
- Pause/resume works without losing timing state
- Duration picker allows 1, 3, 5, 10 minute selections
- Dark background on pacing view with high-contrast elements
- Setup and complete views use cream theme

**Priority:** 2
**Dependencies:** 1

---

### 3. Today Dashboard — Daily Breath Tracking

**User Story:** As a user, I want to see my daily breath practice at a glance — what I've done today, quick-start cards for each technique, and my streak — so I stay motivated and can easily begin a session.

**Description:** The Today tab is the home screen. A calm, organized wellness dashboard using the existing editorial design language.

**Screen Layout (top to bottom in ScrollView):**

**Header:**
- "Today" in AppTypography.display2 (40pt bold), left-aligned
- Current date below in AppTypography.caption (e.g., "Monday, March 3")
- Generous top padding (AppSpacing.heroTopPadding)

**Daily Progress Card:**
- Full-width card with subtle border (AppColors.border)
- Total minutes practiced: large stat number (AppTypography.statLarge, 56pt) in accent color
- "minutes today" label below in caption
- Horizontal progress bar showing progress toward daily goal (filled portion in accent, background in AppColors.surfaceElevated)
- Sessions count: "3 sessions" in small text
- If no sessions: show "0" with encouraging message "Start your first session"

**Technique Cards Section:**
- Section header: "TECHNIQUES" in ALL-CAPS editorial style (AppShapes.SectionHeaderView)
- 4 technique cards in a vertical stack with AppSpacing.cardGap between them:

  1. **Resonant Breathing** card:
     - Background: AppColors.cardTeal
     - Title: "Resonant Breathing" (headline bold)
     - Subtitle: "The Perfect Breath" (body)
     - Timing: "5.5s in · 5.5s out" (caption)
     - Difficulty badge: "Beginner" (small pill)
     - Play icon (SF Symbol: play.fill) at trailing edge

  2. **Box Breathing** card:
     - Background: AppColors.surface (white) with border
     - Title: "Box Breathing"
     - Subtitle: "Navy SEAL Focus"
     - Timing: "4s · 4s · 4s · 4s"
     - Difficulty: "Beginner"

  3. **4-7-8 Breathing** card:
     - Background: AppColors.cardYellow
     - Title: "4-7-8 Breathing"
     - Subtitle: "Natural Tranquilizer"
     - Timing: "4s · 7s · 8s"
     - Difficulty: "Intermediate"

  4. **Cyclic Sighing** card:
     - Background: AppColors.surfaceElevated
     - Title: "Cyclic Sighing"
     - Subtitle: "Stanford Stress Reset"
     - Timing: "2s · 2s · 8s"
     - Difficulty: "Beginner"

- Each card: rounded corners (16pt), left-aligned text, tapping navigates to BreathSessionSetupView

**Today's Sessions Section (shown only if sessions exist):**
- Section header: "TODAY'S SESSIONS"
- List of completed sessions, most recent first
- Each row: technique name · duration · time (e.g., "Box Breathing · 5 min · 9:30 AM")
- Hairline dividers between rows (AppShapes.HairlineDivider)

**Streak Indicator:**
- Below sessions or below techniques if no sessions
- Simple text: flame icon (🔥 or SF Symbol) + "3 day streak" in bodyBold
- If no streak: "Start your streak today"

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardView.swift`
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardViewModel.swift` — loads daily data from BreathSessionRepository
- `Sources/SocraticJournal/Presentation/Today/Components/DailyProgressCard.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/TechniqueCard.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/TechniqueListSection.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/SessionHistoryRow.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/StreakIndicator.swift`

**Data Flow:**
- ViewModel loads sessions for today from BreathSessionRepository on appear
- Technique definitions from BreathTechnique.allTechniques (static)
- Daily goal from UserSettings.dailyGoalMinutes
- Streak computed by repository
- ViewModel refreshes when returning from a completed session

**Acceptance Criteria:**
- Dashboard displays correctly with zero sessions (empty state is welcoming)
- All 4 technique cards shown with correct names, subtitles, timings, colors
- Tapping a technique card navigates to session setup (Feature 2)
- After completing a session, returning to Today shows updated stats immediately
- Daily progress card shows accurate minutes and session count
- Progress bar fills proportionally to daily goal
- Session history lists today's completed sessions with correct times
- Streak shows correct consecutive day count
- ScrollView performance is smooth
- Uses existing theme system throughout
- Responsive to Dynamic Type for key text elements

**Priority:** 3
**Dependencies:** 1, 2

---

### 4. Learn Tab — Breathing Science & Education

**User Story:** As a user, I want to browse interesting, bite-sized facts about breathing science so I understand why these techniques work and stay engaged with my practice.

**Description:** The Learn tab is an editorial-style feed of educational content cards. A curated magazine about breathing — beautiful typography, clean cards, organized by topic. Content is hardcoded. Tone: fascinating and accessible, inspired by James Nestor's storytelling.

**Content (15 hardcoded LearningBit items):**

1. **"The Perfect Breath is 5.5 Seconds"** (Science)
   "Researchers found that breathing at 5.5 breaths per minute creates 'coherence' — when heart, lungs, and circulation synchronize for peak efficiency. James Nestor calls this the perfect breath."

2. **"Prayers From Opposite Sides of the World"** (Ancient Wisdom)
   "Buddhist monks chanting Om Mani Padme Hum and Catholics reciting the rosary in Latin both breathe at exactly 5.5 breaths per minute. These traditions developed independently, yet converged on the same optimal rhythm."

3. **"Your Nose Makes Medicine"** (Nasal Breathing)
   "Your nasal sinuses produce nitric oxide — a gas that opens blood vessels, kills bacteria, and helps your lungs absorb oxygen. Mouth breathing bypasses this entirely. Humming increases nasal nitric oxide by 15x."

4. **"We Are the Worst Breathers on Earth"** (Surprising Facts)
   "No other species suffers from chronic snoring, sleep apnea, or breathing dysfunction at the rates humans do. The shift to soft processed foods shrank our jaws and narrowed our airways over millennia."

5. **"10 Days of Mouth Breathing"** (Nasal Breathing)
   "When James Nestor plugged his nose for 10 days, his blood pressure hit 142 (stage 2 hypertension), snoring increased 4,800%, and he averaged 25 sleep apnea events per night. Switching back to nasal breathing reversed it all."

6. **"The Navy SEAL Reset"** (Techniques)
   "Box breathing has a 'neutral energetic effect' — it calms without sedating and focuses without winding you up. That's precisely why Navy SEALs chose it: in combat, you need to be calm AND sharp."

7. **"Your Body Already Knows"** (Science)
   "You perform 'physiological sighs' — double inhales — roughly every 5 minutes. Your body does this automatically to reinflate collapsed air sacs in your lungs. Stanford researchers turned this reflex into the cyclic sighing technique."

8. **"Breath Changes Your Genes"** (Science)
   "Controlled breathing can alter gene expression — activating genes for energy and insulin regulation while suppressing those linked to inflammation and stress."

9. **"A Natural Tranquilizer"** (Techniques)
   "Dr. Andrew Weil calls the 4-7-8 technique 'a natural tranquilizer for the nervous system.' The key: the exhale is twice the length of the inhale, maximally activating the vagus nerve."

10. **"25,000 Breaths a Day"** (Surprising Facts)
    "You breathe roughly 25,000 times daily — about 10,000 liters of air. Even small improvements to each breath compound into dramatic health changes over time."

11. **"Spirit, Prana, Pneuma"** (Ancient Wisdom)
    "The word 'spirit' comes from Latin 'spirare' — to breathe. In Sanskrit, 'prana' means both breath and life force. In Greek, 'pneuma' means both breath and soul. Every ancient culture saw breath as life itself."

12. **"5 Minutes Beats Meditation"** (Science)
    "A 2023 Stanford study found that 5 minutes of daily cyclic sighing produced greater mood improvements and anxiety reduction than 5 minutes of mindfulness meditation."

13. **"The Nasal Cycle"** (Nasal Breathing)
    "Your nostrils alternate dominance every 2-4 hours — one opens while the other partially closes. This natural cycle is controlled by your autonomic nervous system and helps optimize air conditioning and immune defense."

14. **"4,000 Years of Breathwork"** (Ancient Wisdom)
    "Breath practices appear across Taoism, Buddhism, Hinduism, Christianity, Yoga, Qigong, Shamanism, Sufism, and Native American traditions — spanning four millennia and every inhabited continent."

15. **"The Oxygen Advantage"** (Nasal Breathing)
    "Studies show blood oxygen levels are about 10% higher during nasal breathing compared to mouth breathing. Your nose warms, humidifies, and filters air — your mouth does none of these."

**Screen Layout:**
- "Learn" in AppTypography.display2, left-aligned at top
- Category filter chips in a horizontal scroll below the title:
  - "All" (default, selected state = filled accent pill)
  - "Science", "Nasal", "Ancient", "Techniques", "Facts"
  - Unselected state: outlined pill with border
- Vertical stack of LearningCard components below filters
- Each card:
  - Rounded corners (16pt), padding (AppSpacing.cardPadding)
  - Category tag at top: small colored badge (accent pill with category name)
  - Title: AppTypography.headline (bold)
  - Body: AppTypography.bodyLarge (20pt), readable line spacing
  - Card backgrounds alternate between: AppColors.surface (white), AppColors.surfaceElevated (cream)
  - Cards separated by AppSpacing.cardGap

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedView.swift`
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedViewModel.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/LearningCard.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/CategoryFilterBar.swift`

**Acceptance Criteria:**
- All 15 learning bits display in a clean scrollable feed
- Category filtering works: "All" shows everything, selecting a category filters to that category
- Filter chips highlight the active selection
- Cards have clear typography hierarchy (category badge → title → body)
- Content is factually accurate
- Scrolling performance is smooth
- Design feels editorial and meditative
- Content is engaging and concise — no walls of text per card

**Priority:** 4
**Dependencies:** 1

---

### 5. Onboarding Flow — Welcome to Breath

**User Story:** As a new user, I want a brief, beautiful onboarding that introduces breath pacing and gets me excited to start my first session.

**Description:** A 3-page swipeable onboarding. Replace existing NewOnboardingView and all onboarding pages. Calm, confident, inviting tone. Minimal text, strong typography, meditative visuals.

**Delete existing onboarding files:**
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingWelcomePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingUnlockPage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingVoicePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingFriendsPage.swift`

**Page 1 — "Breathe Better":**
- Cream background (AppColors.background)
- Large display text: "Breathe Better" (AppTypography.displayLarge, 48pt)
- Subtitle: "The most powerful health tool you already have" (AppTypography.bodyLarge)
- Center of screen: a gentle animated circle that slowly expands and contracts
  - Reuse BreathCircleView in a "demo" mode — breathing at resonant pace (5.5s in, 5.5s out)
  - Teal color (AppColors.cardTeal) at ~50% opacity for subtlety
  - No phase labels — just the visual breathing motion
- Sets the tone: simple, focused, beautiful

**Page 2 — "Ancient Wisdom, Modern Science":**
- Cream background
- Display text: "Ancient Wisdom, Modern Science" (AppTypography.display, 34pt)
- Below: the 4 techniques listed vertically with subtle left border accents:
  - Resonant Breathing — The perfect breath
  - Box Breathing — Navy SEAL focus
  - 4-7-8 Breathing — Natural tranquilizer
  - Cyclic Sighing — Stanford's stress reset
- Each item: technique name in bodyBold, subtitle in caption, accent color left border (4pt)
- Subtitle at bottom: "Each backed by research. Guided by a simple visual." (AppTypography.body)

**Page 3 — "Just 5 Minutes a Day":**
- Accent coral background (AppColors.accent) with white text
- Display text: "Just 5 Minutes a Day" (AppTypography.displayLarge, white)
- Subtitle: "Track your practice. Learn the science. Breathe with intention." (bodyLarge, white at 80% opacity)
- "Get Started" button: white filled pill with accent text
- Tapping sets hasCompletedOnboarding = true in UserSettings and dismisses onboarding

**Container (NewOnboardingView.swift — rewrite):**
- TabView with PageTabViewStyle for swipe navigation
- Page indicators: small dots at bottom, accent color
- No skip button — only 3 pages, quick to swipe through
- "Get Started" only appears on page 3

**Views to Create/Modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — Complete rewrite
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingBreathePage.swift` — Page 1
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingSciencePage.swift` — Page 2
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingStartPage.swift` — Page 3

**Acceptance Criteria:**
- 3-page swipeable onboarding displays on first launch (hasCompletedOnboarding = false)
- Page 1 has smoothly animating breath circle
- Page 2 lists all 4 techniques with accurate names and subtitles
- Page 3 "Get Started" button dismisses onboarding permanently
- Returning users go straight to Today dashboard
- No references to Socratic Journal, questions, voice, or friends
- Clean, minimal, calming aesthetic
- Uses existing theme system
- Works in both light and dark mode (pages use their own backgrounds)

**Priority:** 5
**Dependencies:** 1, 2 (reuses BreathCircleView)

---

### 6. App Identity & Polish Pass

**User Story:** As a user, I want the app to feel cohesive and polished — consistent naming, smooth transitions, haptic feedback, and attention to detail throughout.

**Description:** Final polish pass tying everything together. Update identity from Socratic Journal to "Breathe", refine transitions, add haptics, handle edge cases.

**Identity Updates:**
- Update display name in Info.plist / project.yml to "Breathe"
- Search entire codebase for any remaining "Socratic Journal" or "socraticjournal" strings — replace with "Breathe" / "breathe"
- Update UserDefaults key prefix from "com.socraticjournal" to "com.breathe" in UserDefaultsSettingsRepository and UserDefaultsBreathSessionRepository
- Update AboutView app name

**Navigation & Transitions:**
- Smooth NavigationStack push transitions: Today → Setup → Pacing → Complete
- Full-screen cover for the pacing view (it's a focused experience, no back swipe)
- Sheet presentation for session complete (medium detent, non-dismissable until saved)
- Tab switching is instant (no custom animation needed)

**Haptic Feedback (throughout the app):**
- Phase transitions during pacing: UIImpactFeedbackGenerator(.soft)
- Session start (after countdown): UIImpactFeedbackGenerator(.medium)
- Session complete: UINotificationFeedbackGenerator(.success)
- Technique card tap: UIImpactFeedbackGenerator(.light)
- Category filter tap: UISelectionFeedbackGenerator

**Settings Polish:**
- SettingsView sections:
  - "PRACTICE" section: Daily goal picker (segmented: 1, 3, 5, 10, 15 min)
  - "REMINDERS" section: Daily reminder toggle + time picker
  - "APPEARANCE" section: Theme selector (existing)
  - "ABOUT" section: App version, "Breathe" name
- Remove any remaining journal settings (friend activity, FOMO, subscription)
- ALL-CAPS section headers with tracking (existing editorial style)
- Hairline dividers between sections

**Edge Cases & Robustness:**
- App backgrounding during session: automatically pause, resume on foreground (ScenePhase)
- Session view locked to portrait (preferredInterfaceOrientations)
- Dynamic Type: ensure stat numbers, technique cards, and learning bits scale
- VoiceOver: breath circle announces phase changes ("Inhale", "Hold", "Exhale") at transitions

**Acceptance Criteria:**
- Zero references to "Socratic Journal" visible anywhere in UI or user-facing strings
- App display name is "Breathe"
- All navigation transitions feel smooth
- Haptic feedback present at all specified interaction points
- Settings view clean and relevant to breath app
- Daily goal configurable in settings
- App handles backgrounding/foregrounding during sessions
- Overall experience feels like one cohesive app
- VoiceOver announces breath phases

**Priority:** 6
**Dependencies:** 1, 2, 3, 4, 5
