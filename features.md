---
base_branch: feature/breath-pivot2-1
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breath — Pacing, Science & Daily Practice

> A complete pivot from Socratic Journal to a breath pacing app. Three tabs: **Today** (daily practice dashboard with streak, weekly grid, reminders), **Breathe** (8 scientifically-backed patterns with mountain-wave animation and haptic rhythm), and **Learn** (editorial science articles). Design language: warm cream editorial with teal accent, serif headings, hairline grids — inspired by James Nestor's "Breath" and conservation-archive aesthetics.

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
- `App/SocraticJournalApp.swift` — Strip journal-specific init code. Remove Firebase Messaging delegate, OfflineSyncQueue, BackendHealthService. Keep Firebase.configure(), ThemeManager, basic app structure with onboarding check.
- `App/Environment.swift` — Keep as-is.
- `Presentation/Theme/` — Keep entire directory. Update AppColors.swift with new breath-focused palette (see below).
- `Presentation/Settings/SettingsView.swift` — Strip journal-specific settings (friend activity, FOMO alerts, streak reminders, subscription settings). Keep theme selector, notification time picker. Add daily goal picker.
- `Presentation/Settings/Components/ThemeSelectorView.swift` — Keep.
- `Presentation/Settings/Components/NotificationSettingsView.swift` — Keep, update copy for breath reminders.
- `Presentation/Settings/Components/AboutView.swift` — Keep, update app name.
- `Presentation/Settings/Components/SubscriptionSettingsView.swift` — Delete.
- `Presentation/Navigation/MainTabView.swift` — Rewrite with 3 tabs: Today, Breathe, Learn.
- `Domain/Entities/UserSettings.swift` — Strip subscription fields and journal booleans. Add: dailyGoalMinutes (Int, default 5), breathReminderEnabled (Bool), breathReminderHour/Minute.
- `Data/Repositories/UserDefaultsSettingsRepository.swift` — Keep, update key prefix.

**Color Palette Update (AppColors.swift):**
Update the accent and semantic colors to a calmer, breath-focused palette inspired by the design prototype:
- Primary accent: Teal `#2D5F5D` (calm, respiratory, trust — replaces coral as primary)
- Secondary accent: Deep Coral `#C4502A` (energy, focus, alerts — used for stress/advanced patterns)
- Background: Warm Cream `#FAF7F2` (keep existing)
- Surface: Paper White `#F2EDE4` (warmer than pure white)
- Text Primary: Deep Brown `#1C1710` (warmer than black)
- Text Secondary: Mid Brown `#7A6E60` (replaces gray)
- Text Tertiary / Dim: Warm Gray `#B0A898`
- Border: Warm Border `#D8D0C4`
- Card Teal: soft teal `#2D5F5D18` (accent at ~10% opacity for selected state backgrounds)
- Keep the existing semantic colors (success, warning, error) and utility colors.
- Add tag-specific colors: Sleep Purple `#6B4C8A`, CO2 Brown `#7A6030`, Nature Green `#5A6E3D`, Hold Green `#5A8A6A`

**New Domain Entities — 8 Breathing Patterns:**

`Sources/SocraticJournal/Domain/Entities/BreathPattern.swift`:
Define a BreathPattern struct (not "Technique" — the word "pattern" is used throughout the app's UI):

```
BreathPhaseType: inhale, hold, exhale, inhaleTopUp
BreathPhase: id, name, duration (TimeInterval), phaseType
BreathDifficulty: beginner, intermediate, advanced
```

BreathPattern struct with fields:
- id: String
- name: String (display name)
- timing: String (e.g., "5.5 · 5.5" — displayed as subtitle)
- phases: [BreathPhase]
- bpm: String (e.g., "5.5 BPM")
- tag: String (e.g., "HRV · Default")
- tagColorHex: String (hex color for the tag)
- importance: String (scientific description paragraph — the "why" for this pattern)
- bestFor: String (e.g., "Morning practice · Daily baseline")
- difficulty: BreathDifficulty

The 8 hardcoded patterns (as static properties):

1. **Resonance** — 5.5s inhale, 5.5s exhale (5.5 BPM, tag: "HRV · Default", teal tag, beginner)
   "The headline finding from James Nestor. Breathing at exactly 5.5 breaths per minute synchronises your heart rate variability to its resonance frequency — the point at which the baroreflex and cardiac vagal tone are perfectly in phase. The effect on HRV, blood pressure, and anxiety is measurable within a single session."
   Best for: "Morning practice · Daily baseline"

2. **Coherent** — 6s inhale, 6s exhale (5 BPM, tag: "Beginner · Calm", teal tag, beginner)
   "Developed by Stephen Elliott, coherent breathing produces the same resonance effect through a slightly longer, rounder cycle. Easier to learn than 5.5 because the count is whole numbers. Regular practice rebuilds the parasympathetic nervous system and lowers resting heart rate over weeks."
   Best for: "First week of practice · Wind-down"

3. **Box** — 4s inhale, 4s hold, 4s exhale, 4s hold (3.75 BPM, tag: "Focus · Stress", coral tag, beginner)
   "Used by Navy SEALs under combat stress. The equal-phase structure forces the nervous system out of fight-or-flight by demanding total attentional control. The double hold phases build CO₂ tolerance gently over time, which is the key mechanism for reducing anxiety about breathing itself."
   Best for: "Pre-work · Before a difficult conversation"

4. **4-7-8** — 4s inhale, 7s hold, 8s exhale (3.2 BPM, tag: "Sleep · Parasympathetic", purple `#6B4C8A` tag, intermediate)
   "Dr Andrew Weil's signature pattern. The extended 7-second hold pressurises oxygen into the bloodstream, and the 8-second exhale activates the vagus nerve more than any other phase ratio. Consistent evening use measurably shortens sleep onset time. Do not use while driving — it is genuinely sedating."
   Best for: "Evening · Pre-sleep · Anxiety spike"

5. **Physiological Sigh** — 3s inhale (double inhale: 2+1), 0.5s hold, 8s exhale (~5 BPM, tag: "Fastest reset", coral tag, beginner)
   "Discovered by Stanford neuroscientist Andrew Huberman. A double inhale through the nose (first breath fully inflates alveoli, second sniff pops any collapsed ones) followed by a long exhale. This is the fastest known method to reduce physiological arousal — a single sigh can lower cortisol within 30 seconds. Your body does this spontaneously when you cry."
   Best for: "Immediate stress relief · Single-breath rescue"

6. **Buteyko Reduced** — 3s inhale, 3s exhale, 3s hold (~6 BPM, tag: "CO₂ · Asthma", brown `#7A6030` tag, intermediate)
   "Konstantin Buteyko's insight was counter-intuitive: modern humans over-breathe, not under-breathe. Chronic hyperventilation depletes CO₂, which paradoxically causes oxygen to bind tighter to haemoglobin (Bohr Effect). Reduced breathing retrains your chemoreceptors to tolerate higher CO₂, which is the actual trigger for the urge to breathe. This pattern is foundational for asthma and anxiety."
   Best for: "Chronic mouth-breathers · Building CO₂ tolerance"

7. **Tummo / Power** — 2s inhale, 1.5s exhale (20+ BPM rapid cycles, tag: "Advanced · Energy", coral tag, advanced)
   "Based on Tibetan Tummo practice, popularised by Wim Hof. Rapid, forceful breathing for 30 cycles deliberately induces hypocapnia (CO₂ depletion), followed by a breath-hold. This creates an alkaline blood shift, floods the body with adrenaline, and temporarily suppresses the innate immune response. The scientific evidence is genuine but so are the risks — never in water, never while driving."
   Best for: "Morning energy · Cold exposure · Advanced only"

8. **Alternate Nostril** — 4s inhale, 4s hold, 4s exhale per side (~5 BPM, tag: "Balance · Ancient", green `#5A6E3D` tag, intermediate)
   "Nadi Shodhana from the Hatha Yoga Pradipika, now validated neurologically. Alternating which nostril you breathe through directly modulates which brain hemisphere is dominant (right nostril activates left hemisphere and vice versa). The nasal cycle connection Nestor describes is real — this practice manually overrides it to achieve bilateral balance. Good for creative work and pre-meditation."
   Best for: "Pre-meditation · Mental clarity · Balance"

Add `static let allPatterns: [BreathPattern]` returning all 8 in the order above.

`Sources/SocraticJournal/Domain/Entities/BreathSession.swift`:
```swift
struct BreathSession: Identifiable, Codable, Sendable {
    let id: String // UUID string
    let patternId: String
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

**New Domain Protocols:**

`Sources/SocraticJournal/Domain/Repositories/BreathSessionRepositoryProtocol.swift`:
```swift
protocol BreathSessionRepositoryProtocol: Sendable {
    func saveSession(_ session: BreathSession) async throws
    func getSessionsForDate(_ date: Date) async throws -> [BreathSession]
    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession]
    func getTotalMinutesToday() async throws -> Double
    func getStreak() async throws -> Int
}
```

**New Data Implementations:**

`Sources/SocraticJournal/Data/Repositories/UserDefaultsBreathSessionRepository.swift`:
- Implements BreathSessionRepositoryProtocol
- Persists via UserDefaults JSON (key: "com.breathe.sessions")
- Streak: iterate backwards from today counting consecutive days with >=1 session

**New Navigation (update MainTabView.swift):**
- Three tabs: Today (SF Symbol: `circle.grid.2x1`), Breathe (SF Symbol: `wind`), Learn (SF Symbol: `book`)
- Tab bar: cream background, hairline top border, dot indicator above active label
- Tab labels: 11pt uppercase tracked serif font (Georgia)
- Active: teal accent color. Inactive: mid brown.
- Placeholder views for each tab (real content in Features 2-4)

**Acceptance Criteria:**
- Project compiles with zero errors after all removals and additions
- All deleted files/directories are completely gone
- No references to questions, voice answers, friends, reveals, subscriptions, recording, paywall, or sharing remain
- BreathPattern.allPatterns returns 8 properly configured patterns with all fields populated
- Color palette updated to teal-primary, coral-secondary scheme
- MainTabView shows three tabs (Today, Breathe, Learn) with placeholder views
- App launches and shows the three-tab interface
- Theme system fully intact with updated colors
- Settings view works with breath-specific settings

**Priority:** 1
**Dependencies:** None

---

### 2. Breathe Tab — Pattern Selector, Mountain Wave Animation & Pacing Engine

**User Story:** As a user, I want to browse 8 breathing patterns, select one, and follow a beautiful animated guide that shows my breath as a mountain-wave shape with clear phase labels and countdown timing, so I can practice eyes-open or eyes-closed (with haptic cues).

**Description:** The Breathe tab is the core interactive experience. It combines a horizontal pattern selector, a mountain-wave SVG-style breath animator, phase labeling, countdown timer, and a start/pause button. The design is editorial and calm — not gamified.

**Screen Layout (top to bottom):**

**Header:**
- "BREATHE" in 11pt uppercase tracked teal text, left-aligned
- Duration selector chips at trailing edge: "5 min", "10 min", "20 min"
- Selected chip: teal accent border + light teal background. Unselected: border only.
- Hairline border below

**Pattern Selector (horizontal scroll):**
- Horizontally scrollable row of pill-shaped chips for each of the 8 patterns
- Each chip: pattern name in 12pt serif font (Georgia or New York)
- Selected: teal accent border, light teal background (#2D5F5D18), teal text, bold
- Unselected: warm border, mid-brown text, normal weight
- Tapping a pattern selects it and resets the animation to idle
- Hairline border below

**Mountain Wave Animator (center of screen):**
This is the signature visual — a mountain peak that draws itself as you breathe:
- Canvas/Shape area approximately 280pt wide × 120pt tall, centered
- A faint dashed "ghost" mountain shape shows the full breath cycle outline at all times
- A solid colored path draws the actual breath progress:
  - **Inhale:** Line rises from baseline (bottom-left) up the left slope toward the peak, following progress 0→1
  - **Hold:** Line holds at the peak with a subtle dot indicator
  - **Exhale:** Line descends from peak down the right slope back to baseline
  - **Hold (bottom):** Line holds at baseline
- Phase colors: Inhale = teal (#2D5F5D), Hold = muted green (#5A8A6A), Exhale = deep coral (#C4502A)
- Baseline: hairline at bottom of the wave area
- The path uses quadratic bezier curves for smooth mountain shape
- Transition between phase colors should be smooth (0.4s)

**Phase Label (below wave):**
- Current phase name: "inhale" / "hold" / "exhale" in 28pt serif italic, colored to match the active phase
- Below it: countdown in seconds (e.g., "4s") during active session, or the pattern timing (e.g., "5.5 · 5.5") when idle
- Tabular/monospaced nums for the countdown

**Begin/Pause Button:**
- "BEGIN" when idle: dark filled button (#1C1710 bg, cream text), 12pt uppercase tracked serif
- "PAUSE" when running: outlined button (border only, mid text)
- Centered below the phase label

**Pattern Info Section (below button, scrollable):**
- "ABOUT THIS PATTERN" in 10pt uppercase tracked dim text
- Pattern importance paragraph in 13pt body text, warm brown color, generous line height (1.75)
- "Best for · [best for text]" in 11pt teal bold

**BreathPacingEngine (@Observable, @MainActor):**
`Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift`

Properties:
- pattern: BreathPattern (current selected pattern)
- currentPhaseIndex: Int
- currentPhase: BreathPhase (computed from index)
- phaseProgress: Double (0.0→1.0, updated at ~60fps)
- phaseTimeRemaining: TimeInterval
- cyclesCompleted: Int
- totalElapsedTime: TimeInterval
- isRunning: Bool
- sessionDurationTarget: TimeInterval (from duration picker: 5/10/20 min)

Methods:
- start() — begins pacing from first phase
- pause() / resume()
- stop() → BreathSession (creates completed session data)
- reset() — returns to idle state

Timer: Use CADisplayLink wrapped in a Swift class, or a high-frequency Timer (~60Hz)
- Each tick: advance phaseProgress based on elapsed time / current phase duration
- When phaseProgress >= 1.0: advance to next phase, reset progress, fire haptic
- When totalElapsedTime >= sessionDurationTarget: finish current cycle, then stop and produce BreathSession

Haptic Feedback:
- Phase transition: UIImpactFeedbackGenerator(.soft) — this is the "haptic rhythm" feature
- Session start: UIImpactFeedbackGenerator(.medium)
- Session complete: UINotificationFeedbackGenerator(.success)

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Breathe/BreatheView.swift` — Full Breathe tab screen
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — Pattern selection, duration, engine lifecycle
- `Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift` — Core timing engine
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternSelectorBar.swift` — Horizontal chip scroll
- `Sources/SocraticJournal/Presentation/Breathe/Components/BreathWaveView.swift` — Mountain wave Shape/Canvas
- `Sources/SocraticJournal/Presentation/Breathe/Components/PhaseLabelView.swift` — Phase name + countdown
- `Sources/SocraticJournal/Presentation/Breathe/Components/DurationChipBar.swift` — 5/10/20 min selector
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternInfoSection.swift` — About this pattern

**Acceptance Criteria:**
- All 8 patterns selectable via horizontal scroll chips
- Selecting a pattern updates the wave ghost shape, info section, and timing display
- Mountain wave animation draws smoothly at 60fps following the breath phase
- Phase colors transition smoothly (teal for inhale, green for hold, coral for exhale)
- Countdown timer accurate to 1s resolution during active session
- Begin button starts the session; Pause pauses; resume continues
- Haptic feedback fires at every phase transition (soft tap)
- Duration picker (5/10/20 min) controls session length
- Session completes after target duration (finishes current cycle)
- Completed session saved to BreathSessionRepository
- Pattern info shows the scientific importance text and best-for line
- Ghost mountain outline always visible as reference shape
- Idle state shows pattern timing (e.g., "5.5 · 5.5") instead of countdown

**Priority:** 2
**Dependencies:** 1

---

### 3. Today Dashboard — Daily Practice, Streak & Reminders

**User Story:** As a user, I want to see my daily breath practice at a glance — a greeting, my streak, this week's grid, today's planned sessions, and my reminders — so I stay motivated and can quickly start or track my practice.

**Description:** The Today tab is a calm, editorial wellness dashboard. It feels like opening a beautifully typeset daily planner. Uses the warm cream palette with hairline borders between sections, generous whitespace, and a mix of large stat numbers with small uppercase labels.

**Screen Layout (top to bottom in ScrollView):**

**Date Header:**
- Day and date in 11pt uppercase tracked dim text (e.g., "MONDAY, 3 MARCH")
- "Good morning." in 26pt serif bold dark text (greeting varies: morning/afternoon/evening based on time)
- Hairline border below
- Generous padding (24px horizontal, 24px top)

**Streak + Week Grid (two-column layout):**
- Left column: "STREAK" label (11pt uppercase dim), large stat number (42pt serif bold dark), "days" label below
- Right column: "THIS WEEK" label, then a row of 7 small square day indicators:
  - Each: 26×26pt rounded rectangle (4pt radius)
  - Completed days (before today): teal filled with white checkmark
  - Today/future days: paper background with border
  - Day initial below each square (8pt dim text: S, M, T, W, T, F, S)
- Hairline border between columns (vertical) and below section (horizontal)

**Today's Practice (checklist):**
- "TODAY'S PRACTICE" section header (11pt uppercase dim)
- List of practice items as a checklist:
  - Each item: circular checkbox (22pt) + label + subtitle
  - Completed: teal filled circle with checkmark, label has strikethrough and dim color
  - Pending: empty circle with border
  - Label: "5 min · Resonance 5.5" in 13pt semibold
  - Subtitle: "Morning · Default" in 11pt dim
- Hairline dividers between items
- Items are derived from the user's daily goal + preferred patterns (for now, hardcode 2 suggested sessions: morning resonance + evening coherent)
- Tapping a pending item navigates to Breathe tab with that pattern pre-selected

**Reminders Section:**
- "REMINDERS" section header
- Each reminder row: large time (20pt serif bold dark, e.g., "07:30") + label ("Morning calm" in 11pt mid text)
- Toggle switch at trailing edge: teal when active, border when inactive
  - Toggle thumb: white circle, 16pt diameter, animated left/right
  - Track: 36×20pt rounded capsule
- Hairline dividers between reminders
- Default reminders: 07:30 "Morning calm" (Resonance 5.5), 21:00 "Evening wind-down" (4-7-8)
- Reminders connect to LocalNotificationService for scheduling

**Haptic Rhythm Note (bottom info card):**
- Light teal background card (#2D5F5D at ~10% opacity)
- Teal border at ~12% opacity, 8pt corner radius
- Icon + text: "Haptic rhythm is on — phase changes use a soft taptic cue so you can breathe eyes-closed."
- 12pt teal text
- This card is informational and always visible

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardView.swift`
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardViewModel.swift` — loads daily data, streak, reminders from repositories and settings
- `Sources/SocraticJournal/Presentation/Today/Components/DateHeaderView.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/StreakWeekSection.swift` — two-column streak + week grid
- `Sources/SocraticJournal/Presentation/Today/Components/PracticeChecklistSection.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/PracticeItemRow.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/ReminderSection.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/ReminderRow.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/HapticInfoCard.swift`

**Data Flow:**
- ViewModel loads sessions for today from BreathSessionRepository
- Streak from BreathSessionRepository.getStreak()
- Week completion: check which days of current week have sessions
- Daily goal from UserSettings.dailyGoalMinutes
- Reminders from UserSettings (breath reminder hour/minute + enabled flag)
- Greeting based on current hour (morning < 12, afternoon < 17, evening >= 17)
- Refresh on appear and when returning from Breathe tab

**Acceptance Criteria:**
- Dashboard displays correctly with zero sessions (welcoming empty state)
- Greeting varies by time of day ("Good morning." / "Good afternoon." / "Good evening.")
- Streak shows correct consecutive day count (0 if no sessions)
- Week grid shows completed days with teal fill and checkmarks
- Practice checklist shows suggested sessions with correct completion state
- Tapping a pending practice item navigates to Breathe tab
- Reminders display with toggle switches that persist state
- Haptic info card always visible at bottom
- Hairline borders between all major sections
- All text uses the theme system (serif for headings, system for body)
- ScrollView performance is smooth

**Priority:** 3
**Dependencies:** 1, 2

---

### 4. Learn Tab — Breathing Science Editorial Feed

**User Story:** As a user, I want to browse engaging, beautifully typeset articles about breathing science — the nasal cycle, the CO₂ paradox, the 5.5 BPM resonance — so I understand why these patterns work and stay motivated to practice.

**Description:** The Learn tab is an editorial science magazine about breathing. It has a header, a horizontally scrolling quick-fact strip, and a stack of expandable article cards. Design: clean serif typography, hairline borders, expandable disclosure pattern. Tone: fascinating and accessible, inspired by James Nestor's storytelling.

**Screen Layout (top to bottom in ScrollView):**

**Header:**
- "The Science" in 22pt serif bold dark
- "Why slow nasal breathing changes everything" in 12pt mid text below
- Hairline border below
- Padding: 24px horizontal, 24px top

**Quick Fact Strip (horizontal scroll):**
- A horizontally scrollable row of stat cards, hairline-bordered between each
- Each card: ~90pt wide, 16px padding
  - Large value: 18pt serif bold dark (e.g., "5.5", "25k", "90 min", "NO", "Bohr")
  - Small label: 9pt dim text, max 70pt wide (e.g., "optimal breaths per min")
- Cards have right border (hairline) as visual separators
- Hairline border below the strip
- Facts: "5.5" / optimal breaths per min, "25k" / breaths per day, "90 min" / nasal cycle, "NO" / nitric oxide from nose, "Bohr" / CO₂ releases O₂

**Article Cards (expandable):**
Each card is a disclosure-style row that expands when tapped:

**Collapsed state:**
- Tag badge at top-left: colored pill with category text (10pt bold tracked, colored background at 8%, colored border at 20%)
- Read time at top-right: "3 min" in 11pt dim
- Title: 15pt serif bold dark, multi-line allowed (whiteSpace pre-line for \n)
- Subtitle: 11pt mid text
- Hairline border below card

**Expanded state (tapped):**
- Same header as collapsed
- Below header: hairline separator, then body paragraph
- Body: 13pt warm brown text, line height 1.75, generous padding
- Tapping again collapses

**The 4 Articles:**

1. **"You breathe 25,000 times a day. Most of them wrong."**
   - Tag: "Start here" (coral `#C4502A`)
   - Subtitle: "The core thesis — mouth vs nasal breathing"
   - Read time: 3 min
   - Body: "Nasal breathing filters, humidifies, and pressurises air before it reaches the lungs. It also produces nitric oxide — a molecule that dilates blood vessels, improves oxygen transfer, and kills pathogens. Mouth breathing does none of this. The evidence from anthropology is stark: skull records show our ancestors had wide jaws, straight teeth, and open nasal passages. Modern skulls are narrower, more crowded — a direct result of the shift to mouth breathing over centuries."

2. **"The nasal cycle and your brain"**
   - Tag: "Awareness" (teal `#2D5F5D`)
   - Subtitle: "Why your nostrils take turns — and what it means"
   - Read time: 4 min
   - Body: "Every 90 minutes or so, your body shifts airflow from one nostril to the other — the nasal cycle. This isn't random. The right nostril activates the sympathetic nervous system (alertness, left-brain activity). The left nostril activates the parasympathetic (calm, creative, right-brain). You can test this right now: close your right nostril and breathe only through your left. Within minutes, your nervous system follows."

3. **"5.5 — why this number"**
   - Tag: "Science" (teal `#2D5F5D`)
   - Subtitle: "HRV, resonance frequency, and the baroreflex"
   - Read time: 5 min
   - Body: "The cardiovascular system has a natural resonance frequency — a rhythm at which the baroreflex (blood pressure regulator) and heart rate variability are perfectly synchronised. For most humans this is ~0.1 Hz, or about 5.5 breaths per minute. Breathing at this exact rate maximises HRV, lowers blood pressure, and creates a feedback loop between heart, lungs, and brain that has measurable effects on anxiety, sleep, and athletic performance."

4. **"The CO₂ problem"**
   - Tag: "Counter-intuitive" (brown `#7A6030`)
   - Subtitle: "Why less breathing means more oxygen"
   - Read time: 4 min
   - Body: "The Bohr Effect: oxygen clings more tightly to haemoglobin when CO₂ is high. If you over-breathe and deplete CO₂, paradoxically less oxygen is released to your tissues. Buteyko's entire system is built on this insight. The chronic 'air hunger' anxiety sufferers feel is usually not a lack of oxygen — it's a trained intolerance to CO₂. Slow, reduced breathing rebuilds this tolerance over weeks."

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedView.swift`
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedViewModel.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/QuickFactStrip.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/ArticleCard.swift`

**Data:**
- Articles are hardcoded in the ViewModel (static content array)
- Quick facts are hardcoded
- No filtering needed (unlike the old features.md with categories) — this is a curated, ordered editorial feed
- Expansion state managed locally in the view

**Acceptance Criteria:**
- Header displays "The Science" with subtitle
- Quick fact strip scrolls horizontally with all 5 facts
- All 4 articles display with correct tags, titles, subtitles, read times
- Tapping an article expands to show body text
- Tapping again collapses
- Only one article expanded at a time (tapping another closes the current)
- Tags have correct colors matching their category
- Body text uses warm brown color with generous line spacing
- Hairline borders between all elements
- Smooth scroll performance
- Editorial typography throughout (serif for headings and titles)

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
- Cream background
- Large display: "Breathe Better" (48pt serif bold)
- Subtitle: "The most powerful health tool you already have" (20pt body)
- Center: a gentle animated circle or wave that slowly expands and contracts at resonant pace (5.5s in, 5.5s out) in teal at ~50% opacity
- No phase labels — just visual breathing motion
- Sets the tone: simple, focused, beautiful

**Page 2 — "Ancient Wisdom, Modern Science":**
- Cream background
- Display: "Ancient Wisdom, Modern Science" (34pt serif bold)
- Below: 4 key patterns listed vertically with teal left-border accents (4pt):
  - Resonance — The perfect breath
  - Box Breathing — Navy SEAL focus
  - 4-7-8 — Natural tranquilizer
  - Physiological Sigh — Stanford's fastest reset
- Each: pattern name in body bold, subtitle in caption
- Bottom subtitle: "Each backed by research. Guided by a simple visual."

**Page 3 — "Just 5 Minutes a Day":**
- Teal background (#2D5F5D) with cream/white text
- Display: "Just 5 Minutes a Day" (48pt serif bold, white)
- Subtitle: "Track your practice. Learn the science. Breathe with intention." (body, white at 80% opacity)
- "Get Started" button: white filled pill with teal text
- Tapping sets hasCompletedOnboarding = true and dismisses

**Container (NewOnboardingView.swift rewrite):**
- TabView with PageTabViewStyle
- Teal page indicator dots
- No skip button (only 3 pages)
- "Get Started" only on page 3

**Views to Create/Modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — Complete rewrite
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingBreathePage.swift` — Page 1
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingSciencePage.swift` — Page 2
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingStartPage.swift` — Page 3

**Acceptance Criteria:**
- 3-page swipeable onboarding on first launch
- Page 1 has smoothly animating breath visual
- Page 2 lists 4 patterns with correct names and subtitles
- Page 3 "Get Started" dismisses onboarding permanently
- Returning users go straight to Today tab
- No references to Socratic Journal anywhere
- Clean, minimal, calming aesthetic
- Works in both light and dark mode

**Priority:** 5
**Dependencies:** 1

---

### 6. App Identity, Polish & Haptic Rhythm

**User Story:** As a user, I want the app to feel cohesive and polished — consistent naming ("Breathe"), smooth transitions, haptic rhythm for eyes-closed practice, and attention to detail throughout.

**Description:** Final polish pass tying everything together. Update identity from Socratic Journal to "Breathe", refine transitions, ensure haptic feedback is consistent, handle edge cases.

**Identity Updates:**
- Update display name in Info.plist / project.yml to "Breathe"
- Search entire codebase for remaining "Socratic Journal" or "socraticjournal" strings — replace
- Update UserDefaults key prefix from "com.socraticjournal" to "com.breathe"
- Update AboutView app name
- Update CLAUDE.md project description

**Navigation & Transitions:**
- Smooth tab switching (instant, no custom animation)
- Breathe tab state persists when switching tabs (selected pattern, running session)
- If a session is running and user switches tabs, auto-pause with a subtle toast
- NavigationStack for any detail flows
- Tab bar uses the custom dot-above-label style from the React prototype

**Haptic Rhythm System:**
- Phase transitions during pacing: UIImpactFeedbackGenerator(.soft) — "haptic rhythm"
- This is the headline UX feature: users can breathe eyes-closed guided only by haptic taps
- Session start: UIImpactFeedbackGenerator(.medium)
- Session complete: UINotificationFeedbackGenerator(.success)
- Pattern chip tap: UIImpactFeedbackGenerator(.light)
- Category filter / toggle tap: UISelectionFeedbackGenerator
- Haptic rhythm toggle in settings (default: on)

**Settings Polish:**
- Sections with ALL-CAPS tracked headers:
  - "PRACTICE" — Daily goal picker (segmented: 3, 5, 10, 15 min)
  - "HAPTICS" — Haptic rhythm toggle (on/off)
  - "REMINDERS" — Daily reminder toggle + time picker
  - "APPEARANCE" — Theme selector (existing)
  - "ABOUT" — App version, "Breathe" name
- Hairline dividers between sections
- Remove any remaining journal settings

**Edge Cases & Robustness:**
- App backgrounding during session: auto-pause, resume on foreground (ScenePhase)
- Dynamic Type: ensure stat numbers, technique cards, and articles scale
- VoiceOver: breath wave announces phase changes at transitions
- Portrait lock during active session

**Acceptance Criteria:**
- Zero references to "Socratic Journal" in UI or user-facing strings
- App display name is "Breathe"
- Haptic rhythm fires at every phase transition during active session
- Haptic toggle in settings works (disables all session haptics when off)
- All navigation transitions feel smooth
- Settings view clean and relevant
- App handles backgrounding during sessions gracefully
- VoiceOver announces breath phases
- Overall experience feels like one cohesive, editorial breath app

**Priority:** 6
**Dependencies:** 1, 2, 3, 4, 5
