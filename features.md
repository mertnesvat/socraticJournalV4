---
base_branch: feature/breath-pivot-3
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breath Pacer — Full Pivot from Socratic Journal

> **Context:** This is a complete pivot. The existing Socratic Journal codebase is being transformed into a minimal, science-backed breathing companion app. All journal-related code (entities, services, views, view models) must be removed and replaced with breath-focused equivalents. The design system (Theme/, AppColors, AppTypography, AppSpacing, AppShapes) and infrastructure (Firebase Analytics, UserDefaults persistence, local notifications) are preserved and reused.

> **Design Language:** Calm, confident, non-spiritual. Deep navy/teal palette for sessions. Existing cream/coral palette for chrome. Lowercase serif for breath phase labels. SF Pro for UI. No emojis in UI copy. No uppercase during sessions. The breath animation is the centrepiece — it must be beautiful.

> **Architecture:** Clean Architecture — Domain (entities + protocols) → Data (implementations) → Presentation (SwiftUI views + @Observable view models). Protocol-driven DI. iOS 17+ with @Observable. No ObservableObject.

> **Tab Bar:** `Today | Breathe | Learn | Progress` — 4 tabs. The Breathe tab transitions to full-screen immersive mode during active sessions.

---

### 1. Clean Slate — Strip All Journal Code & Create Compilable Shell

**User Story:** As a developer, I need the entire journal codebase removed so that only the reusable infrastructure remains, and the app compiles as a blank shell ready for breath features.

**What to Remove (delete these files/directories entirely):**
- `Sources/SocraticJournal/Domain/Entities/` — Delete: DailyQuestion.swift, VoiceAnswer.swift, Subscription.swift, Friendship.swift, FriendGroup.swift, QuestionStreak.swift, AnswerReveal.swift, SpicyTakeAward.swift. Keep only `User.swift` and `UserSettings.swift`
- `Sources/SocraticJournal/Domain/Repositories/` — Delete: QuestionRepositoryProtocol.swift, UserRepositoryProtocol.swift, FriendshipRepositoryProtocol.swift, VoiceAnswerRepositoryProtocol.swift. Keep `SettingsRepositoryProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/` — Delete: QuestionFeedServiceProtocol.swift, VoiceRecordingServiceProtocol.swift, UserProfileServiceProtocol.swift, FriendServiceProtocol.swift, AnswerRevealServiceProtocol.swift, NotificationServiceProtocol.swift, SubscriptionServiceProtocol.swift. Keep `AnalyticsServiceProtocol.swift`
- `Sources/SocraticJournal/Data/Services/` — Delete: VoiceRecordingService.swift, StoreKitSubscriptionService.swift, OfflineSyncHandler.swift, OfflineSyncQueue.swift, BackendHealthService.swift, FirebaseFunctionsService.swift, AppsFlyerService.swift. Keep: FirebaseAnalyticsService.swift, LocalNotificationService.swift, NetworkMonitor.swift
- `Sources/SocraticJournal/Data/Mock/` — Delete entire directory if it exists
- `Sources/SocraticJournal/Presentation/QuestionFeed/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Recording/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Friends/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Reveals/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/History/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Sharing/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Paywall/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Components/Audio/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Profile/` — Delete entire directory
- `Sources/SocraticJournal/Presentation/Settings/Components/SubscriptionSettingsView.swift` — Delete
- `Tests/` — Delete: Subscription/ test directory, MockSubscriptionService.swift. Keep MockSettingsRepository.swift, MockAnalyticsService.swift

**What to Update After Deletion:**
- `SocraticJournalApp.swift` — Remove initialization of deleted services (Firebase Messaging delegate, AppsFlyer config, OfflineSyncQueue, BackendHealthService). Keep Firebase.configure(), ThemeManager, NetworkMonitor. The app should launch to a simple placeholder view
- `MainTabView.swift` — Replace current tab content with a single placeholder Text("Breath Pacer") so the app compiles
- `UserSettings.swift` — Remove `friendActivityEnabled`, `fomoAlertsEnabled`, subscription fields (`subscriptionExpiryDate`, `activeProductId`, `lastSubscriptionCheck`, `isPremium` computed property). Keep `themeMode`, `streakRemindersEnabled`, `dailyReminderEnabled`, `dailyReminderHour`, `dailyReminderMinute`, `hasCompletedOnboarding`, `hasDismissedSampleData`
- `SettingsView.swift` and `SettingsViewModel.swift` — Remove references to deleted services/entities. Strip friend settings, subscription settings. Keep theme selector, notification toggle, about section
- Fix all remaining compile errors from references to deleted files
- `User.swift` — Gut to minimal stub: just `id: String`, `displayName: String`, `createdAt: Date`

**Acceptance Criteria:**
- All journal-specific Swift files are deleted from the project
- The app compiles and launches successfully showing a placeholder screen
- Theme system (AppColors, AppTypography, AppSpacing, AppShapes, ThemeManager) is fully intact and unchanged
- Settings persistence (UserDefaultsSettingsRepository) works
- Firebase Analytics service is functional
- No references to deleted types remain in the codebase (no compile warnings about missing types)
- UserSettings contains only fields relevant to general app settings
- Zero journal-related strings visible in any remaining file

**Priority:** 1
**Dependencies:** None

---

### 2. Breath Domain Layer — Entities, Protocols & Data Implementations

**User Story:** As a developer, I need the complete domain and data layers for the breath pacer so that the pacing engine, views, and persistence all have a solid foundation to build on.

**New Domain Entities to Create:**

**`Domain/Entities/BreathPhase.swift`** — A single phase within a breathing pattern:
- `phaseType`: enum `BreathPhaseType` with cases `.inhale`, `.holdAfterInhale`, `.exhale`, `.holdAfterExhale`
- `duration`: TimeInterval (seconds, e.g. 5.5)
- `displayLabel`: String — lowercase word shown during this phase ("inhale", "hold", "exhale")
- Codable, Sendable, Identifiable (id can be derived from phaseType)

**`Domain/Entities/BreathTechnique.swift`** — A named breathing pattern composed of phases:
- `id`: String (unique identifier like "resonance", "coherent", "box", "478")
- `name`: String (e.g. "Resonance Breathing")
- `subtitle`: String (e.g. "5.5s in · 5.5s out")
- `description`: String (1-2 sentence explanation)
- `phases`: [BreathPhase] (ordered array of phases in one cycle)
- `cycleDuration`: TimeInterval (computed — sum of all phase durations)
- `scienceNote`: String (brief scientific backing, 1-2 sentences)
- Codable, Sendable, Identifiable
- Provide a static `allTechniques: [BreathTechnique]` with these 4 presets:
  1. **Resonance Breathing** (id: "resonance") — 5.5s inhale, 5.5s exhale. "The optimal rhythm for HRV coherence. ~5.5 breaths per minute synchronises heart rate and breathing — a frequency discovered independently by prayer traditions worldwide."
  2. **Coherent Breathing** (id: "coherent") — 6s inhale, 6s exhale. "A slightly slower variation that maximises parasympathetic activation. The equal ratio creates a calming symmetry ideal for beginners."
  3. **Box Breathing** (id: "box") — 4s inhale, 4s holdAfterInhale, 4s exhale, 4s holdAfterExhale. "Used by Navy SEALs for acute stress management. Four equal phases create a 'box' pattern that calms without sedating."
  4. **4-7-8 Relaxation** (id: "478") — 4s inhale, 7s holdAfterInhale, 8s exhale. "Dr Andrew Weil's sleep preparation technique. The extended exhale is twice the inhale length, maximally activating the vagus nerve."

**`Domain/Entities/BreathSession.swift`** — A completed breathing session:
- `id`: UUID
- `techniqueId`: String
- `techniqueName`: String
- `startedAt`: Date
- `completedAt`: Date? (nil if abandoned)
- `targetDuration`: TimeInterval (what the user chose: 180, 300, 600, 1200 seconds)
- `actualDuration`: TimeInterval (computed from startedAt to completedAt)
- `cyclesCompleted`: Int
- `isCompleted`: Bool (computed — completedAt != nil)
- Codable, Identifiable, Sendable

**`Domain/Entities/DailyLog.swift`** — Aggregation of sessions for a single day:
- `date`: Date (calendar date, no time component)
- `sessions`: [BreathSession]
- `totalMinutes`: Double (computed — sum of actualDuration / 60)
- `sessionsCount`: Int (computed)
- Identifiable (id = date)

**`Domain/Entities/LearningArticle.swift`** — Educational content piece:
- `id`: String
- `title`: String
- `summary`: String (1-2 sentences for card preview)
- `body`: String (full article text, 500-800 words)
- `category`: `LearningCategory` enum with cases `.science`, `.practice`, `.anatomy`
- `keyTakeaway`: String (single highlighted insight sentence)
- `sourceNote`: String (attribution — book/study reference)
- `readTimeMinutes`: Int
- Codable, Sendable, Identifiable

**New Domain Protocols:**

**`Domain/Repositories/BreathSessionRepositoryProtocol.swift`:**
- `func saveSession(_ session: BreathSession) async throws`
- `func getSessions(for date: Date) async throws -> [BreathSession]`
- `func getAllSessions() async throws -> [BreathSession]`
- `func getSessionsInRange(from: Date, to: Date) async throws -> [BreathSession]`
- `func getCurrentStreak() async throws -> Int`
- `func getTotalMinutesBreathed() async throws -> Double`
- `func getTotalSessions() async throws -> Int`
- Protocol must be Sendable

**`Domain/Services/LearningContentServiceProtocol.swift`:**
- `func getAllArticles() -> [LearningArticle]`
- `func getArticles(for category: LearningCategory) -> [LearningArticle]`
- `func getArticle(by id: String) -> LearningArticle?`
- Protocol must be Sendable

**New Data Layer Implementations:**

**`Data/Repositories/UserDefaultsBreathSessionRepository.swift`** — Implements `BreathSessionRepositoryProtocol`:
- Persists sessions as JSON array in UserDefaults under key `breath.sessions`
- Streak logic: count consecutive calendar days going backwards from today that have at least one completed session. Grace window: if yesterday has no session but the day before does, streak shows the count up to the gap with a "streak at risk" indicator (return -streak to signal at-risk, or add a separate method)
- All date comparisons use Calendar.current for day boundaries
- Thread-safe access

**`Data/Services/StaticLearningContentService.swift`** — Implements `LearningContentServiceProtocol`:
- Returns hardcoded array of 3 articles for Phase 1 MVP:

  1. **"Mouth vs nasal breathing"** (category: .science) — Full 500-800 word article covering: nitric oxide production (nasal breathing produces 6x more NO than mouth breathing), airway humidification and filtration, impact on sleep quality and snoring, posture connection, James Nestor's 10-day mouth breathing experiment and its dramatic results. Key takeaway: "Your nose is a pharmacy — it produces nitric oxide, humidifies air, and filters pathogens. Your mouth does none of this." Source: James Nestor, *Breath* (2020)

  2. **"The nasal cycle"** (category: .anatomy) — Full 500-800 word article covering: why nostrils alternate dominance every 75-200 minutes, the connection to ultradian rhythms, brain laterality (right nostril = sympathetic activation / alertness, left = parasympathetic / calming), how energy levels fluctuate with the cycle, practical awareness tips. Key takeaway: "Your body naturally alternates between nostrils every 90 minutes — this ancient rhythm governs your energy, creativity, and calm." Source: Shannahoff-Khalsa, *International Journal of Neuroscience* (1991)

  3. **"HRV and resonance frequency"** (category: .science) — Full 500-800 word article covering: what heart rate variability is and why it matters, the baroreflex loop, cardiac vagal tone, why breathing at ~0.1 Hz (5.5 BPM) creates resonance between heart rate oscillations and breathing rhythm, HRV as a biomarker of resilience and health, how to improve HRV through breathing practice. Key takeaway: "At 5.5 breaths per minute, your heart and lungs synchronise — creating a state of maximum heart rate variability and physiological coherence." Source: Lehrer & Gevirtz, *Applied Psychophysiology and Biofeedback* (2014)

  **IMPORTANT: Write genuine, substantive educational content — not placeholder text. The article bodies must be real, well-written 500-800 word articles based on the scientific sources described above. Content quality is a key differentiator for this app.**

**Acceptance Criteria:**
- All entities compile with correct Codable, Sendable, Identifiable conformance
- BreathTechnique.allTechniques returns exactly 4 techniques with correct phase timings
- Each technique's phases have the correct durations and phase types
- BreathSession repository can save sessions, retrieve by date, retrieve all, calculate streaks
- Streak calculation handles: 0 sessions ever, 1 day streak, multi-day streak, broken streak, grace window
- LearningContentService returns 3 articles with complete, well-written body text (not lorem ipsum or placeholder)
- Each article body is 500-800 words of genuine educational content
- Unit tests exist for streak calculation logic covering edge cases
- Unit tests exist for session persistence (save, retrieve by date, retrieve all)
- All protocols are defined in Domain/, all implementations in Data/

**Priority:** 2
**Dependencies:** 1

---

### 3. Breath Pacing Engine — Core Timing & Animation Logic

**User Story:** As a user, I want a precise, smooth breathing engine that drives the visual animation and haptic feedback so that I can follow the breathing rhythm effortlessly.

**The BreathPacingEngine** — An `@Observable @MainActor` class:

**File:** `Presentation/Session/BreathPacingEngine.swift`

**State Properties:**
- `technique`: BreathTechnique (the active technique)
- `currentPhase`: BreathPhase (which phase we're currently in)
- `currentPhaseIndex`: Int (index in technique.phases array)
- `phaseProgress`: Double (0.0 to 1.0 — how far through the current phase)
- `phaseTimeRemaining`: TimeInterval (seconds remaining in current phase)
- `sessionProgress`: Double (0.0 to 1.0 — how far through the entire session)
- `elapsedTime`: TimeInterval (total time since session start)
- `cyclesCompleted`: Int (number of full cycles completed)
- `isActive`: Bool (session is running — true from start until complete)
- `isPaused`: Bool (session is paused mid-breath)
- `isComplete`: Bool (session has finished)
- `targetDuration`: TimeInterval (total session length user selected)

**Computed / Derived:**
- `breathPosition`: Double (0.0 to 1.0) representing the vertical position of the breath for the mountain wave animation:
  - During `.inhale`: rises from 0.0 to 1.0 following `phaseProgress` with ease-in-out
  - During `.holdAfterInhale`: stays at 1.0
  - During `.exhale`: falls from 1.0 to 0.0 following `phaseProgress` with ease-in-out
  - During `.holdAfterExhale`: stays at 0.0

**Core Behavior:**
- Uses `CADisplayLink` (preferred) or high-frequency Timer at ~60fps for smooth animation
- On each frame: advance elapsed time, recalculate phase progress, check for phase transitions
- When a phase completes (phaseProgress >= 1.0): advance to next phase in cycle, reset phase timer
- When the last phase of a cycle completes: increment `cyclesCompleted`, loop back to first phase
- Haptic feedback: `UIImpactFeedbackGenerator(.light)` fires exactly once on each phase transition. No haptic during holds or mid-breath
- Medium haptic (`UIImpactFeedbackGenerator(.medium)`) on session complete
- Pause/resume: freezes the display link timer. Resume continues from exact pause point with no timing drift
- Session ends when `elapsedTime >= targetDuration` AND the current phase completes. Never cuts mid-phase — always finishes the current phase before ending. If in the middle of a cycle, complete the remaining phases of that cycle
- On completion, `isComplete` becomes true

**Methods:**
- `func startSession(technique: BreathTechnique, duration: TimeInterval)` — initialise state, start timer
- `func pause()` — freeze timer, set isPaused
- `func resume()` — restart timer, clear isPaused
- `func stop() -> BreathSession` — stop timer, return completed BreathSession entity with accurate data

**Acceptance Criteria:**
- Engine maintains precise timing — phase durations are accurate to within 16ms (one display frame)
- Phase transitions are smooth with no visible stutter or jump
- `breathPosition` provides correct 0→1→1→0 wave for techniques with holds (Box, 4-7-8)
- `breathPosition` provides correct 0→1→0 wave for techniques without holds (Resonance, Coherent)
- Haptics fire exactly once per phase transition, not during holds or mid-breath
- Pause genuinely freezes all state; resume continues from exact pause point with no drift
- Session completes at the natural end of a phase/cycle, never mid-breath
- `cyclesCompleted` counts correctly for all 4 techniques
- `stop()` returns a properly populated BreathSession entity with correct timestamps and cycle count
- Works correctly for all 4 techniques with different phase counts and durations
- No memory leaks — CADisplayLink/Timer properly invalidated on stop/deinit

**Priority:** 3
**Dependencies:** 2

---

### 4. Breathe Tab — Session Experience & Mountain Wave Animation

**User Story:** As a user, I want a calm, immersive breathing session with a beautiful mountain wave animation and clear phase labels so that I can follow the rhythm naturally and complete my daily practice.

**This is the centrepiece of the entire app. The animation quality must be exceptional.**

**Session Flow — 3 Screens:**

**Screen A: Session Setup** (`Presentation/Session/BreathSessionSetupView.swift`)
- Cream background (standard app chrome)
- Technique selector: horizontal scroll of technique cards. Each card shows:
  - Technique name (headline bold)
  - Timing subtitle (e.g. "5.5s in · 5.5s out") in secondary text
  - 1-line description in body text
  - Default selection: Resonance Breathing. Selected card has accent border (2pt coral)
  - Unselected cards have standard border
- Duration picker: 4 pill buttons in a horizontal row — **3 min**, **5 min** (default, highlighted), **10 min**, **20 min**
  - Selected pill: filled with accent colour, white text
  - Unselected pills: outlined with border, primary text
- Large "Begin" button at bottom (AccentPillButton from AppShapes)
- Tapping Begin starts a 3-2-1 countdown, then transitions to the active session

**Screen B: Active Session** (`Presentation/Session/BreathPacingView.swift`)
- **Full-screen immersive.** No tab bar. No status bar. No navigation bar. Pure focus
- **Background:** Deep navy `#0B1426` that subtly transitions to warm blue-teal `#0F2B3C` over the session duration. The shift should be imperceptible moment-to-moment — use a slow linear interpolation tied to `sessionProgress`

- **Mountain Wave Animation** — the centrepiece visual:
  - A continuous line drawn as a smooth bezier path across the horizontal centre of the screen
  - The animation represents one breath cycle as a mountain shape:
    - **Inhale phase:** the line rises from a baseline (bottom of the wave area) smoothly up to a peak, tracing the left slope of a mountain. Use smooth bezier curves — no sharp corners at vertices
    - **Hold after inhale:** the line holds flat at the peak. A subtle glow pulses gently at the peak point (opacity oscillates between 0.6 and 1.0 over 1s)
    - **Exhale phase:** the line descends from the peak back to the baseline, tracing the right slope of the mountain
    - **Hold after exhale:** the line stays flat at baseline
  - The line should feel like it's being drawn in real time — animate the stroke end point forward rather than just moving a shape up and down
  - Line colour: white at 80% opacity
  - Line width: 3pt with rounded line cap
  - Soft glow behind the line: white shadow with blur radius ~8pt at 30% opacity
  - Rounded vertices at peak and base — use bezier control points to create smooth curves
  - Implementation: use SwiftUI `Canvas` view or a custom `Shape` with `animatableData` for best performance. The shape's path should be driven by `breathPosition` from the pacing engine
  - As cycles complete, previous mountain shapes remain visible but fade to ~15% opacity, creating a mountain range effect. Keep only the last 3-4 mountains visible to avoid performance issues

- **Phase label** — centred below the wave area:
  - Text: lowercase "inhale" / "hold" / "exhale"
  - Font: Georgia or New York serif at ~28pt if available, otherwise system serif. Always lowercase
  - Colour: white at 90% opacity
  - Crossfade between labels with 0.3s animation on phase transition
  - No countdown number visible — just the word. The animation IS the guide

- **Progress arc** — very subtle thin arc at the top of the screen:
  - Shows session progress 0% to 100%
  - Hair-thin stroke (1pt), white at 20% opacity
  - Positioned as a horizontal line or slight arc near the top edge
  - Should not attract attention — it's there if you look for it

- **Interaction:**
  - Single tap anywhere pauses the session
  - Pause overlay: semi-transparent dark overlay with "paused" in lowercase serif, centred
  - Two buttons on pause: "resume" (accent pill) and "end session" (text button, secondary colour)
  - No other interactive elements during session. No buttons, no swipe gestures, no navigation

**Screen C: Session Complete** (`Presentation/Session/BreathSessionCompleteView.swift`)
- Presented as a bottom sheet or smooth transition on the navy background
- Stats displayed cleanly:
  - Duration: "5 minutes" (rounded to nearest minute, or "3:22" if under 5 min)
  - Breaths: cycle count displayed as "27 breaths" or "15 cycles"
  - Streak: "3 days" with a small indicator
- Affirming message: randomly selected from a curated pool of 8-10 calm messages:
  - "well done"
  - "your body thanks you"
  - "consistency is everything"
  - "another day of practice"
  - "slow is powerful"
  - "you showed up — that's what matters"
  - "breathe well, live well"
  - "5.5 breaths per minute. perfect."
- Single "Done" button returns to the Today tab
- The session is automatically saved to the BreathSessionRepository
- **Never** show: rating prompts, share prompts, upsells, ads

**Components to Create:**
- `Presentation/Session/BreathSessionSetupView.swift`
- `Presentation/Session/BreathPacingView.swift`
- `Presentation/Session/BreathSessionCompleteView.swift`
- `Presentation/Session/Components/MountainWaveView.swift` — the mountain wave animation
- `Presentation/Session/Components/PhaseLabel.swift` — lowercase serif phase label with crossfade
- `Presentation/Session/Components/CountdownOverlay.swift` — 3-2-1 pre-session countdown (large numbers, centre screen, fade transitions)
- `Presentation/Session/Components/DurationPicker.swift` — 4-option pill selector
- `Presentation/Session/Components/TechniqueSelector.swift` — horizontal scroll technique cards

**Acceptance Criteria:**
- Setup screen shows all 4 techniques with correct timings and descriptions
- Duration picker allows selection of 3, 5, 10, 20 minutes with clear selected state
- 3-2-1 countdown appears after tapping Begin, before session starts
- The mountain wave animation renders smoothly at 60fps with no stuttering
- The animation correctly visualises all 4 breathing patterns:
  - Resonance/Coherent: smooth mountain (inhale up, exhale down) — no flat sections
  - Box: mountain with flat peak (inhale up, hold at top, exhale down, hold at bottom)
  - 4-7-8: mountain with long flat peak (inhale up, long hold at top, slow exhale down)
- Phase labels crossfade smoothly using lowercase serif text ("inhale", "hold", "exhale")
- Background colour transitions subtly from navy to blue-teal over the session
- Previous mountains fade to create a mountain range effect
- Tap-to-pause works anywhere on screen; paused state shows resume/end options
- Session complete shows accurate duration, cycle count, and streak
- Affirming message is calm and non-cheesy, randomly selected
- Session is saved to repository before showing complete screen
- No tab bar, status bar, or navigation visible during active session
- Haptics fire on phase transitions (light) and session complete (medium)
- The entire flow works end-to-end: setup → countdown → breathing → complete → back to Today

**Priority:** 4
**Dependencies:** 3

---

### 5. Today Tab — Daily Dashboard & Streak Tracking

**User Story:** As a user, I want to see my daily breathing progress, streak, and a quick way to start a session so that I'm motivated to practice every day.

**Layout — Scrollable vertical stack on cream background:**

**Hero Section (top of screen):**
- Time-based greeting in lowercase, body font:
  - Before 12pm: "good morning"
  - 12pm-5pm: "good afternoon"
  - After 5pm: "good evening"
- Large streak number prominently displayed (AppTypography.stat — 56pt bold) in accent colour
- Label below: "day streak" in secondary text. If streak is 0: show "0" with "start your streak" message
- Circular progress ring (use GeometricRing from AppShapes or similar) showing today's minutes vs daily goal
  - Ring fills with accent colour proportionally
  - Inside or below: "2 of 5 min" in caption text
  - Default daily goal: 5 minutes (configurable in settings)

**Quick Start Section:**
- "START BREATHING" section header (SectionHeaderView — all-caps editorial)
- Prominent card showing the last-used technique (or Resonance Breathing as default):
  - Card with teal background (AppColors.cardTeal)
  - Technique name in headline bold
  - Timing subtitle in body
  - Play icon (SF Symbol: `play.fill`) at trailing edge
  - Tapping navigates to Breathe tab with this technique pre-selected

**Techniques Section:**
- "TECHNIQUES" section header
- 4 technique cards in a vertical stack (AppSpacing.cardGap between):
  - Each card shows: name, subtitle, timing, 1-line description
  - Cards have alternating background tints:
    1. Resonance: cardTeal background
    2. Coherent: surface (white) with border
    3. Box: cardYellow background
    4. 4-7-8: surfaceElevated (cream)
  - Tapping any card navigates to session setup with that technique pre-selected

**Today's Sessions (visible only if sessions exist today):**
- "TODAY'S SESSIONS" section header
- Compact rows for each completed session today (most recent first):
  - Technique name · duration ("5 min") · time ("9:15 am")
  - Hairline divider between rows
- If no sessions today: this section is hidden entirely

**Tip of the Day:**
- Subtle card at the bottom with a breathing science fact
- Rotates daily (use day-of-year modulo tip count to select)
- 15+ tips in a static array, examples:
  - "nasal breathing produces six times more nitric oxide than mouth breathing"
  - "5.5 breaths per minute is the resonance frequency for heart rate variability"
  - "your nostrils alternate dominance every 90 minutes as part of the nasal cycle"
  - "box breathing is used by Navy SEALs to manage acute stress in the field"
  - "extended exhales activate the parasympathetic nervous system — the body's rest mode"
  - "James Nestor found switching to nasal breathing improved sleep apnea by 50%"
  - "a 2023 Stanford study found 5 minutes of cyclic sighing beats meditation for mood"
  - "you breathe roughly 25,000 times a day — about 10,000 litres of air"
  - "the word 'spirit' comes from Latin 'spirare' — to breathe"
  - "controlled breathing can alter gene expression related to inflammation"
  - "Buddhist monks and Catholic rosary prayers both breathe at 5.5 breaths per minute"
  - "your body performs physiological sighs every 5 minutes to reinflate collapsed air sacs"
  - "studies show blood oxygen is ~10% higher during nasal vs mouth breathing"
  - "Dr Weil calls 4-7-8 breathing a natural tranquiliser for the nervous system"
  - "breath practices appear across every major spiritual tradition spanning 4,000 years"

**Views to Create:**
- `Presentation/Today/TodayDashboardView.swift`
- `Presentation/Today/TodayDashboardViewModel.swift` (@Observable)
- `Presentation/Today/Components/DailyProgressCard.swift` (streak + ring)
- `Presentation/Today/Components/TechniqueCard.swift` (reusable technique card)
- `Presentation/Today/Components/TechniqueListSection.swift`
- `Presentation/Today/Components/SessionHistoryRow.swift`
- `Presentation/Today/Components/StreakIndicator.swift`
- `Presentation/Today/Components/TipOfTheDayCard.swift`

**Data Flow:**
- ViewModel loads from BreathSessionRepository on appear and on return from session
- Technique definitions from BreathTechnique.allTechniques (static)
- Daily goal from UserSettings.dailyGoalMinutes
- Streak from repository

**Acceptance Criteria:**
- Dashboard displays correct greeting based on time of day
- Streak number shows accurately (0 shows "start your streak")
- Progress ring reflects today's breathing minutes vs daily goal
- All 4 technique cards display with correct names, subtitles, timings, colours
- Quick start card shows last-used technique or defaults to Resonance
- Tapping any technique card navigates to session setup with that technique pre-selected
- Today's sessions list shows all sessions completed today
- Tip of the day rotates daily
- Stats refresh automatically after completing a session
- Layout uses existing design system throughout
- Dark mode support via ThemeManager
- Empty state (no sessions ever) is welcoming and encouraging

**Priority:** 5
**Dependencies:** 4

---

### 6. Learn Tab — Science-Backed Education Content

**User Story:** As a user, I want to read well-written, science-backed articles about breathing so that I understand why these techniques work and stay engaged with the science.

**Layout:**

**Header:**
- "Learn" title at top (AppTypography.display or headline)
- Horizontal category filter pills below title:
  - "All" (default, selected state), "Science", "Practice", "Anatomy"
  - Selected pill: filled with accent colour, white text
  - Unselected pills: outlined with border, primary text colour
  - Haptic: UISelectionFeedbackGenerator on filter change

**Article Cards — Vertical scrolling list:**
- Each card shows:
  - Category tag: small pill label ("Science" / "Practice" / "Anatomy") at top-left of card
  - Article title: headlineMedium typography (24pt semibold)
  - Summary: body text, 2-3 lines max, truncated with ellipsis
  - Read time: "4 min read" in tertiary text colour
  - Key takeaway: highlighted in a subtly tinted strip at the bottom of the card, body text in slightly smaller size
- Card styling: rounded corners (16pt), card padding (AppSpacing.cardPadding), subtle shadow or border
- Cards alternate between surface (white) and surfaceElevated (cream) backgrounds
- Tapping a card pushes to article detail view

**Article Detail View:**
- Navigation title: article title
- Full article body rendered as styled text with comfortable line spacing (body typography)
- Category and read time below title in secondary text
- Body text with proper paragraph spacing
- **Key Takeaway** — visually distinguished callout:
  - Tinted background card (accent at ~10% opacity)
  - Accent-coloured left border (4pt)
  - Key takeaway text in bodyBold
- Source attribution at bottom: "Source: James Nestor, *Breath* (2020)" in secondary text, italic
- Back button returns to Learn feed

**Views to Create:**
- `Presentation/Learn/LearnFeedView.swift`
- `Presentation/Learn/LearnFeedViewModel.swift` (@Observable)
- `Presentation/Learn/LearnArticleDetailView.swift`
- `Presentation/Learn/Components/LearningArticleCard.swift`
- `Presentation/Learn/Components/CategoryFilterBar.swift`

**Acceptance Criteria:**
- All 3 articles display with correct titles, summaries, full body text
- Category filter works — "Science" shows 2 articles, "Anatomy" shows 1, "All" shows all 3
- Article detail view renders the complete article with proper typography and spacing
- Key takeaway is visually distinguished with tinted background and accent border
- Source attribution appears on every article
- Read time estimates are reasonable (calculated from word count / 200)
- Cards have consistent styling following design system
- Smooth push navigation to article detail and back
- Dark mode support
- Scrolling performance is smooth

**Priority:** 6
**Dependencies:** 2

---

### 7. Progress Tab — Stats, Streak Calendar & Session History

**User Story:** As a user, I want to see my breathing history, total stats, and a streak calendar so that I can track my consistency and feel accomplished about my practice.

**Layout — Scrollable vertical stack:**

**Header:**
- "Progress" title at top (AppTypography.display or headline)

**Stats Hero — Three stat cards in a horizontal row:**
- Use StatCard component from AppShapes or similar styling:
  1. **Total minutes** — large stat number (AppTypography.stat or statSmall), "minutes" label below. Background: cardTeal
  2. **Total sessions** — large stat number, "sessions" label. Background: cardYellow
  3. **Current streak** — large stat number, "day streak" label. Background: surfaceElevated
- Cards have consistent sizing (equal width, flex layout)

**Streak Calendar:**
- "THIS MONTH" section header (SectionHeaderView)
- Grid calendar showing the current month:
  - Day-of-week headers: M T W T F S S (caption text)
  - LazyVGrid with 7 columns
  - Each day cell:
    - No session: light grey or empty circle
    - Has session(s): accent-tinted circle (darker tint = more minutes)
    - Today: subtle border ring highlighting today's cell
    - Future dates: dimmed or hidden
  - Current month name and year above the grid
- Simple implementation — a LazyVGrid, not a full calendar library

**Session History:**
- "HISTORY" section header
- All completed sessions, most recent first
- Grouped by day with date headers:
  - "Today", "Yesterday", then "Mon 3 Mar" format
- Each row: technique name, duration ("5 min"), time ("2:30 pm")
- Hairline dividers between rows within a day group
- Empty state: "complete your first session to see your history here" in secondary text

**Views to Create:**
- `Presentation/Progress/ProgressView.swift`
- `Presentation/Progress/ProgressViewModel.swift` (@Observable)
- `Presentation/Progress/Components/StatsHeroSection.swift`
- `Presentation/Progress/Components/StreakCalendarView.swift`
- `Presentation/Progress/Components/SessionHistorySection.swift`

**Acceptance Criteria:**
- Stat cards show correct totals (minutes rounded to 1 decimal, session count, streak)
- Calendar heatmap accurately shows which days had sessions with intensity
- Today is visually highlighted on the calendar
- Session history shows all sessions in reverse chronological order grouped by day
- Date grouping uses "Today", "Yesterday", then formatted dates
- Empty states show appropriate messages
- Stats update after completing a new session
- Calendar correctly handles months with different day counts
- Layout uses existing design system
- Dark mode support

**Priority:** 7
**Dependencies:** 5

---

### 8. App Shell — Four-Tab Navigation & Integration

**User Story:** As a user, I want a clean four-tab navigation connecting all parts of the app so I can move between my daily dashboard, breathing sessions, education, and progress tracking seamlessly.

**Tab Bar Configuration:**
- 4 tabs with SF Symbols:
  1. **Today** — `wind` icon → TodayDashboardView
  2. **Breathe** — `lungs.fill` icon → BreathSessionSetupView
  3. **Learn** — `book.fill` icon → LearnFeedView
  4. **Progress** — `chart.bar.fill` icon → ProgressView (rename to avoid conflict with SwiftUI's ProgressView — use BreathProgressView or StatsView)
- Active tab: filled icon + accent colour
- Inactive tab: outline icon + secondary colour
- Tab bar styling: matches existing MainTabView aesthetic (hairline divider at top, clean background)
- **The Breathe tab opens the session setup directly. When a session starts (after countdown), the tab bar hides and the pacing view goes full-screen immersive**
- After session complete + "Done", automatically switch to Today tab (tab index 0) so user sees updated progress

**App Entry Point Updates to `SocraticJournalApp.swift`:**
- Initialise: Firebase.configure(), ThemeManager, NetworkMonitor
- Create BreathSessionRepository and LearningContentService
- Pass them to MainTabView (or inject via @Environment)
- Onboarding gate: if `!settings.hasCompletedOnboarding`, show onboarding. Otherwise show tab view
- Remove all journal-specific service init (already done in Feature 1, verify nothing crept back)

**Settings Access:**
- Settings gear icon in the Today tab's navigation bar (top-right)
- Tapping opens Settings as a pushed view or sheet

**Navigation Coordination:**
- Tapping a technique card on Today should navigate to Breathe tab with that technique pre-selected (or present session setup modally from Today)
- After session complete, switch active tab to Today
- Use @State or @Environment for tab selection to enable programmatic tab switching

**Acceptance Criteria:**
- Four tabs display with correct icons and labels
- Each tab navigates to the correct view
- Active/inactive tab styling matches design system
- Tab bar hides during active breathing session (full-screen immersive)
- Tab bar reappears after session complete + Done
- App launches correctly with only breath-related services
- Onboarding gate works: shows onboarding on first launch, main app on subsequent launches
- Settings accessible from Today tab
- Technique card taps from Today navigate to session setup correctly
- After session complete, Today tab shows updated stats
- Navigation is smooth with no state loss when switching tabs
- No naming conflicts with SwiftUI built-in types

**Priority:** 8
**Dependencies:** 5, 6, 7

---

### 9. Onboarding — Three Breath-Focused Pages

**User Story:** As a new user, I want a brief, compelling onboarding that explains why breathing matters and gets me started in under 30 seconds.

**Delete existing onboarding page files and create new ones.**

**Three Pages (reuse existing NewOnboardingView TabView structure):**

**Page 1 — The Hook:**
- Background: deep navy (#0B1426)
- Large text, centred: "you breathe 25,000 times a day." (displayMedium, white, lowercase)
- Below, slight pause: "most of them wrong." (headline, white at 70% opacity)
- Subtle animated mountain wave in the background — a gentle, slow version of the session animation at resonance rhythm, very faded (15% opacity). Sets the mood without being distracting
- "Next" text button at bottom in white, or swipe to continue

**Page 2 — The Science:**
- Background: slightly warmer navy (#0F1E2E)
- Small animated mountain wave preview at top (compact version, ~100pt tall, showing the 5.5/5.5 rhythm)
- Below the wave: "5.5 breaths per minute" (stat typography, large, white)
- Subtitle: "the rhythm that synchronises your heart and lungs" (body, white at 80%)
- Below: brief list of the 4 techniques as simple text items:
  - "resonance breathing — the perfect breath"
  - "coherent breathing — gentle & calming"
  - "box breathing — Navy SEAL focus"
  - "4-7-8 relaxation — natural tranquiliser"
  - Each in body font, white at 70%, with subtle left-border accent marks
- Swipe or next to continue

**Page 3 — The Commitment:**
- Background: accent coral (AppColors.accent)
- Large text: "five minutes a day" (displayLarge, white, lowercase)
- Subtitle: "that's all it takes to build the habit" (bodyLarge, white at 80%)
- Optional: daily reminder toggle with time picker
  - "remind me daily" toggle (white styled)
  - Time picker wheel below (if toggle is on)
  - If enabled, schedule local notification at the chosen time
- "get started" button: white filled pill with accent text (inverted from usual accent pill)
- Tapping "get started" → sets `hasCompletedOnboarding = true` → dismisses onboarding → lands on Today tab

**No account creation. No sign-up. No email. No permissions besides optional notifications.**

**Views to Modify/Create:**
- `Presentation/Onboarding/NewOnboardingView.swift` — Rewrite as 3-page TabView with PageTabViewStyle
- `Presentation/Onboarding/Pages/OnboardingHookPage.swift` — Page 1
- `Presentation/Onboarding/Pages/OnboardingSciencePage.swift` — Page 2
- `Presentation/Onboarding/Pages/OnboardingCommitPage.swift` — Page 3
- Delete all existing onboarding page files (OnboardingWelcomePage, OnboardingUnlockPage, OnboardingVoicePage, OnboardingFriendsPage)

**Acceptance Criteria:**
- Onboarding shows on first launch only (hasCompletedOnboarding = false)
- Three pages display in correct order with correct content
- Swiping between pages works smoothly
- Page indicators (dots) visible at bottom
- Page 1 has subtle background wave animation
- Page 2 shows the 4 techniques with correct names
- Page 3 "get started" saves hasCompletedOnboarding and navigates to Today
- Optional reminder toggle schedules a local notification if enabled
- Returning users skip onboarding entirely — go straight to Today
- No references to Socratic Journal, questions, voice, friends, or journaling
- Dark backgrounds on pages 1-2, coral on page 3
- Typography is lowercase, confident, non-aggressive
- The onboarding feels calm and sets the right tone for the app

**Priority:** 9
**Dependencies:** 8

---

### 10. Settings, Reminders & Identity Polish

**User Story:** As a user, I want to configure my daily goal, breathing reminder, and app preferences. As a developer, I want all references to "Socratic Journal" replaced with the breath app identity.

**Settings Screen** (build on existing SettingsView structure):

**Sections with editorial ALL-CAPS headers:**

**"DAILY PRACTICE" section:**
- Daily goal picker: segmented control or inline picker — 3 / 5 / 10 / 15 / 20 minutes
- Default: 5 minutes
- This value drives the progress ring on the Today tab

**"REMINDERS" section:**
- "Daily reminder" toggle (existing pattern from NotificationSettingsView)
- When on: show time picker (hour/minute wheels)
- Default time: 9:00 AM
- Notification message: "time for your breathing practice" (lowercase, calm)
- When toggled on: request notification permission if needed, schedule daily notification
- When toggled off: cancel all scheduled breath reminder notifications

**"APPEARANCE" section:**
- Theme selector (existing ThemeSelectorView — system/light/dark)

**"ABOUT" section:**
- App version (Marketing version from Info.plist)
- "Breath Pacer by Studio Next"
- Science acknowledgement: "inspired by the research of James Nestor, Patrick McKeown, and Stephen Elliott"
- Hairline divider, then small text link or note about *Breath* by James Nestor

**UserSettings Updates:**
- Add `dailyGoalMinutes: Int` (default: 5)
- Add `defaultTechniqueId: String` (default: "resonance")
- Add `lastUsedTechniqueId: String?` (tracks the most recently used technique for quick start)
- Keep: themeMode, dailyReminderEnabled, dailyReminderHour, dailyReminderMinute, hasCompletedOnboarding
- Remove any remaining journal-specific fields if they survived Feature 1

**Identity Updates:**
- Update display name in Info.plist to "Breathe" (CFBundleDisplayName)
- Search entire codebase for remaining "Socratic Journal", "socraticjournal", "Socratic" strings — replace with "Breathe" / "breathe" where user-facing
- Update AboutView with new app name
- Update UserDefaults key prefixes if still using "socraticjournal" prefix

**Edge Cases:**
- App backgrounding during session: auto-pause on `scenePhase` change to `.background` or `.inactive`, auto-resume not automatic (user must tap resume)
- If notification permission denied: show a subtle note in Reminders section that notifications are disabled in system settings

**Acceptance Criteria:**
- Daily goal picker works and persists across launches
- Changing daily goal updates the Today tab progress ring
- Reminder toggle schedules/cancels notifications correctly
- Time picker appears/disappears based on toggle state
- Notification permission requested when enabling reminders
- Theme selector works (system/light/dark)
- About section shows "Breath Pacer by Studio Next" with science acknowledgement
- Zero remaining references to "Socratic Journal" in any user-facing string
- App display name is "Breathe" in simulator/device
- Settings accessible from Today tab via gear icon
- All settings persist via UserDefaults
- Backgrounding auto-pauses active session

**Priority:** 10
**Dependencies:** 8

---

## Implementation Notes for Night Agent

**Design System:** The existing Theme/ files are production-quality. Use AppColors, AppTypography, AppSpacing, AppShapes extensively. Do not create new design tokens — use the existing palette. The cream/coral palette is for app chrome; deep navy/teal is for the session experience only.

**Architecture Pattern:** Follow the exact Clean Architecture visible in the codebase:
- `Domain/Entities/` for value types (struct, enum)
- `Domain/Repositories/` for repository protocols
- `Domain/Services/` for service protocols
- `Data/Repositories/` for repository implementations
- `Data/Services/` for service implementations
- `Presentation/{Feature}/` for views and @Observable view models

**@Observable, not ObservableObject:** iOS 17+ @Observable macro everywhere. No @Published, no ObservableObject, no Combine.

**Mountain Wave Animation Quality:** This is the centrepiece. Use SwiftUI `Canvas` or custom `Shape` with `animatableData`. The line should feel drawn in real time. Smooth bezier curves at vertices. Soft glow via shadow. Previous mountains fading to create a range. Test on device for smoothness.

**Session Colours:**
- Background start: `#0B1426` (deep navy)
- Background end: `#0F2B3C` (warm blue-teal)
- Line/text: white at 80-90% opacity
- Phase label: white at 90%, serif font, lowercase

**Content Quality:** Learn tab articles must be real educational content — not filler. 500-800 words of substantive, accurate writing based on the scientific sources described. This is a differentiator.

**Naming:** Avoid SwiftUI naming conflicts. Don't name a view `ProgressView` — use `BreathProgressView` or `StatsView`. Don't name anything `Text` or `Color` etc.
