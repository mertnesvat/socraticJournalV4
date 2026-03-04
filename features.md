---
base_branch: feature/breath-pivot2-2
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breathe — Pacing & Learning App

> A complete pivot from Socratic Journal to a breath pacing app inspired by James Nestor's "Breath." Three tabs: **Today** (dashboard with streak, weekly calendar, practice checklist, reminders), **Breathe** (interactive breath pacer with mountain wave animation and 8 science-backed patterns), and **Learn** (editorial science articles). Warm editorial design language: cream backgrounds, hairline grid borders, serif typography (Georgia), teal (#2D5F5D) + terracotta (#C4502A) accents.

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
- `Presentation/Theme/` — Keep entire directory but UPDATE the color palette in AppColors.swift (see Color Palette section below).
- `Presentation/Settings/SettingsView.swift` — Strip journal-specific settings. Keep theme selector, notification time picker. Add daily goal picker.
- `Presentation/Settings/Components/ThemeSelectorView.swift` — Keep.
- `Presentation/Settings/Components/NotificationSettingsView.swift` — Keep, update copy for breath reminders.
- `Presentation/Settings/Components/AboutView.swift` — Keep, update app name.
- `Presentation/Settings/Components/SubscriptionSettingsView.swift` — Delete.
- `Presentation/Navigation/MainTabView.swift` — Rewrite with 3 tabs.
- `Domain/Entities/UserSettings.swift` — Strip subscription fields and journal booleans. Add: dailyGoalMinutes (Int, default 5), breathReminderEnabled (Bool), breathReminderTimes (array of hour/minute pairs), hapticFeedbackEnabled (Bool, default true).
- `Data/Repositories/UserDefaultsSettingsRepository.swift` — Keep, update key prefix to "com.breathe".

**NEW COLOR PALETTE (update AppColors.swift):**
This is critical — the entire visual identity changes. Update AppColors to match this warm editorial palette:
```swift
// Backgrounds
background = Color(hex: "#FAF7F2")        // warm cream white (was #FAF7F2 — same)
surface = Color(hex: "#F2EDE4")           // cream (card surfaces)
surfaceElevated = Color(hex: "#EDE7DB")   // paper (deeper cream)

// Text
textPrimary = Color(hex: "#1C1710")       // near-black warm
textSecondary = Color(hex: "#3D3328")     // brown (body text)
textTertiary = Color(hex: "#7A6E60")      // mid brown
textQuaternary = Color(hex: "#B0A898")    // dim (captions, timestamps)

// Accents
accent = Color(hex: "#2D5F5D")           // deep teal (primary accent)
accentLight = Color(hex: "#2D5F5D").opacity(0.09)  // teal wash for selected states
accent2 = Color(hex: "#C4502A")          // terracotta/burnt orange (secondary accent)

// Borders
border = Color(hex: "#D8D0C4")           // warm hairline border
borderStrong = Color(hex: "#C8C4BC")     // stronger border

// Semantic (keep existing)
success = Color(hex: "#34C759")
warning = Color(hex: "#FF9F0A")
error = Color(hex: "#C4502A")            // matches accent2

// Tag colors (for breath pattern tags)
tagPurple = Color(hex: "#6B4C8A")        // 4-7-8 / Sleep
tagGold = Color(hex: "#7A6030")          // Buteyko / CO2
tagGreen = Color(hex: "#5A6E3D")         // Alternate Nostril / Balance
tagMoss = Color(hex: "#5A8A6A")          // Hold phase indicator
```

Also update AppTypography to include Georgia serif as the display/headline font:
```swift
// Add a serif font family option
static let serifFamily = "Georgia"
// Display fonts should use Georgia
displayLarge → Georgia, 48pt bold
display → Georgia, 34pt bold
headline → Georgia, 28pt bold
headlineMedium → Georgia, 24pt semibold
// Body and caption keep system sans-serif (-apple-system)
```

**What to CREATE (new foundation):**

**New Domain Entities:**

`Sources/SocraticJournal/Domain/Entities/BreathPattern.swift`:
```swift
enum BreathPhaseType: String, Codable, Sendable {
    case inhale, hold, exhale
}

struct BreathPhase: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let duration: TimeInterval
    let phaseType: BreathPhaseType
}

struct BreathPattern: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let timing: String           // e.g. "5.5 · 5.5"
    let phases: [BreathPhase]
    let bpm: String              // e.g. "5.5 BPM"
    let tag: String              // e.g. "HRV · Default"
    let tagColorHex: String      // hex color for the tag
    let importance: String       // paragraph explaining the science
    let best: String             // best-for text

    var cycleDuration: TimeInterval { phases.reduce(0) { $0 + $1.duration } }
}
```

Define ALL 8 patterns as static constants on BreathPattern:

1. **Resonance** — id: "resonance", timing: "5.5 · 5.5", phases: [inhale 5.5, exhale 5.5], bpm: "5.5 BPM", tag: "HRV · Default", tagColor: accent teal, importance: "The headline finding from James Nestor. Breathing at exactly 5.5 breaths per minute synchronises your heart rate variability to its resonance frequency — the point at which the baroreflex and cardiac vagal tone are perfectly in phase. The effect on HRV, blood pressure, and anxiety is measurable within a single session.", best: "Morning practice · Daily baseline"

2. **Coherent** — id: "coherent", timing: "6 · 6", phases: [inhale 6, exhale 6], bpm: "5 BPM", tag: "Beginner · Calm", tagColor: accent teal, importance: "Developed by Stephen Elliott, coherent breathing produces the same resonance effect through a slightly longer, rounder cycle. Easier to learn than 5.5 because the count is whole numbers. Regular practice rebuilds the parasympathetic nervous system and lowers resting heart rate over weeks.", best: "First week of practice · Wind-down"

3. **Box** — id: "box", timing: "4 · 4 · 4 · 4", phases: [inhale 4, hold 4, exhale 4, hold 4], bpm: "3.75 BPM", tag: "Focus · Stress", tagColor: accent2 terracotta, importance: "Used by Navy SEALs under combat stress. The equal-phase structure forces the nervous system out of fight-or-flight by demanding total attentional control. The double hold phases build CO₂ tolerance gently over time, which is the key mechanism for reducing anxiety about breathing itself.", best: "Pre-work · Before a difficult conversation"

4. **4-7-8** — id: "478", timing: "4 · 7 · 8", phases: [inhale 4, hold 7, exhale 8], bpm: "3.2 BPM", tag: "Sleep · Parasympathetic", tagColor: tagPurple, importance: "Dr Andrew Weil's signature pattern. The extended 7-second hold pressurises oxygen into the bloodstream, and the 8-second exhale activates the vagus nerve more than any other phase ratio. Consistent evening use measurably shortens sleep onset time. Do not use while driving — it is genuinely sedating.", best: "Evening · Pre-sleep · Anxiety spike"

5. **Physiological Sigh** — id: "physiological", timing: "2+1 · · 8", phases: [inhale 3, hold 0.5, exhale 8], bpm: "~5 BPM", tag: "Fastest reset", tagColor: accent2 terracotta, importance: "Discovered by Stanford neuroscientist Andrew Huberman. A double inhale through the nose (first breath fully inflates alveoli, second sniff pops any collapsed ones) followed by a long exhale. This is the fastest known method to reduce physiological arousal — a single sigh can lower cortisol within 30 seconds. Your body does this spontaneously when you cry.", best: "Immediate stress relief · Single-breath rescue"

6. **Buteyko Reduced** — id: "buteyko", timing: "3 · 3 · 3", phases: [inhale 3, exhale 3, hold 3], bpm: "~6 BPM", tag: "CO₂ · Asthma", tagColor: tagGold, importance: "Konstantin Buteyko's insight was counter-intuitive: modern humans over-breathe, not under-breathe. Chronic hyperventilation depletes CO₂, which paradoxically causes oxygen to bind tighter to haemoglobin (Bohr Effect). Reduced breathing retrains your chemoreceptors to tolerate higher CO₂, which is the actual trigger for the urge to breathe. This pattern is foundational for asthma and anxiety.", best: "Chronic mouth-breathers · Building CO₂ tolerance"

7. **Tummo / Power** — id: "wim", timing: "30× + hold", phases: [inhale 2, exhale 1.5], bpm: "20+ BPM", tag: "Advanced · Energy", tagColor: accent2 terracotta, importance: "Based on Tibetan Tummo practice, popularised by Wim Hof. Rapid, forceful breathing for 30 cycles deliberately induces hypocapnia (CO₂ depletion), followed by a breath-hold. This creates an alkaline blood shift, floods the body with adrenaline, and temporarily suppresses the innate immune response. The scientific evidence is genuine but so are the risks — never in water, never while driving.", best: "Morning energy · Cold exposure · Advanced only"

8. **Alternate Nostril** — id: "nadi", timing: "4 · 4 · 4 per side", phases: [inhale 4, hold 4, exhale 4], bpm: "~5 BPM", tag: "Balance · Ancient", tagColor: tagGreen, importance: "Nadi Shodhana from the Hatha Yoga Pradipika, now validated neurologically. Alternating which nostril you breathe through directly modulates which brain hemisphere is dominant (right nostril activates left hemisphere and vice versa). The nasal cycle connection Nestor describes is real — this practice manually overrides it to achieve bilateral balance. Good for creative work and pre-meditation.", best: "Pre-meditation · Mental clarity · Balance"

`Sources/SocraticJournal/Domain/Entities/BreathSession.swift`:
```swift
struct BreathSession: Identifiable, Codable, Sendable {
    let id: String
    let patternId: String
    let startedAt: Date
    let completedAt: Date
    let totalDuration: TimeInterval
    let cyclesCompleted: Int
    var date: Date { Calendar.current.startOfDay(for: startedAt) }
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

**New Data Implementation:**

`Sources/SocraticJournal/Data/Repositories/UserDefaultsBreathSessionRepository.swift`:
- Implements BreathSessionRepositoryProtocol
- Persists sessions via UserDefaults with JSON encoding (key: "com.breathe.sessions")
- Streak calculation: iterate backwards from today counting consecutive days with sessions

**New Navigation (rewrite MainTabView.swift):**
- Three tabs:
  - **Today** (SF Symbol: `calendar`) → TodayDashboardView (placeholder)
  - **Breathe** (SF Symbol: `wind`) → BreatheView (placeholder)
  - **Learn** (SF Symbol: `book.fill`) → LearnFeedView (placeholder)
- Tab bar style: Minimal bottom bar — hairline top border (border color), cream background (#FAF7F2)
- Active tab: small 5pt filled circle dot above label + bold serif label in accent teal
- Inactive tab: no dot, regular weight in mid-brown
- Labels: ALL-CAPS, 11pt Georgia, letter-spacing 0.06em
- No SF Symbol icons — text-only tabs with dot indicator (matches React reference)

**Acceptance Criteria:**
- Project compiles with zero errors after all removals and additions
- All deleted directories/files are completely gone
- No references to questions, voice answers, friends, reveals, subscriptions, recording, paywall, or sharing remain anywhere in the codebase
- New AppColors palette reflects the warm teal+terracotta editorial theme
- AppTypography uses Georgia for display/headline fonts
- All 8 breath patterns defined as static constants
- BreathSession entity exists with proper Codable/Sendable/Identifiable
- Repository protocol and UserDefaults implementation work
- MainTabView shows 3 tabs (Today, Breathe, Learn) with text-only tab bar
- App launches successfully with placeholder tab content
- Theme system intact with updated colors
- Settings view works with breath-specific settings

**Priority:** 1
**Dependencies:** None

---

### 2. Breathe Tab — Breath Pacing Engine & Mountain Wave Animator

**User Story:** As a user, I want to select from 8 science-backed breathing patterns and follow a beautiful mountain-wave visual animation that guides me through each phase (inhale, hold, exhale) with precise timing, so I can practice breathwork eyes-open or eyes-closed with haptic cues.

**Description:** The Breathe tab is the core interactive experience. It has three sections stacked vertically: a horizontal pattern selector at top, the mountain wave animator in the center, and pattern info at the bottom. The entire experience lives on a single scrollable screen — no navigation pushes.

**Pattern Selector (top section):**
- Horizontal scrolling row of pill buttons, one per pattern
- Each pill shows pattern name in 12pt Georgia
- Selected pill: teal border + teal background wash (accent at 9% opacity) + bold weight
- Unselected pill: warm border (#D8D0C4) + transparent background + regular weight
- Selecting a pattern stops any running session and resets the animator
- Padding: 20px horizontal, 16px bottom, hairline border below

**Duration Selector (in page header):**
- When Breathe tab is active, the header shows duration picker buttons: "5 min", "10 min", "20 min"
- Each button: 11pt semibold, 4px 10px padding, 4pt border-radius
- Selected duration: teal border + teal wash, teal text
- Unselected: warm border, mid-brown text
- Default: 5 min

**Mountain Wave Animator (center section):**
This is the hero visual — an SVG-style mountain silhouette that draws as you breathe. Implement using SwiftUI Shape/Path:

- Canvas: approximately 280x120pt (scaled for device)
- Baseline: horizontal line at bottom of canvas (border color)
- Ghost mountain: full dotted-line mountain outline showing the complete breath cycle shape (border color, dash pattern 4-4)
- Live path: animated path that draws/progresses based on current phase and progress:
  - **Inhale**: Path rises from bottom-left baseline up the left slope of the mountain. Progress 0→1 draws from base to peak. Use quadratic curve for smooth slope.
  - **Hold**: Path holds at the peak with a subtle flat extension. Small filled dot at peak.
  - **Exhale**: Path descends down the right slope of the mountain from peak back to baseline. Uses quadratic curve mirroring the left slope.
- Path colors by phase:
  - Inhale: teal (#2D5F5D)
  - Hold: moss green (#5A8A6A)
  - Exhale: terracotta (#C4502A)
- Line width: 2.5pt, round line cap
- Smooth color transition on phase change (0.4s)

**Phase Label & Controls (below animator):**
- Phase name: 28pt Georgia, italic, regular weight, colored by current phase
- Below phase name: countdown in seconds ("3s") or pattern timing when paused ("5.5 · 5.5")
- Tabular-nums font variant for countdown (monospaced digits)
- 13pt size, dim color (#B0A898)

**Begin/Pause Button:**
- "BEGIN" when stopped: dark background (#1C1710), cream text, 12px 40px padding, 6pt border-radius
- "PAUSE" when running: transparent background, warm border, mid-brown text
- 12pt Georgia, bold, ALL-CAPS, 0.1em letter-spacing

**Pattern Info (bottom section):**
- Section header: "ABOUT THIS PATTERN" — 10pt bold, ALL-CAPS, 0.14em letter-spacing, dim color
- Description paragraph: 13pt, brown text (#3D3328), 1.75 line height
- "Best for · {best}" line: 11pt, teal, semibold

**Breath Pacing Engine (@Observable, @MainActor):**
```
Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift
```
- Properties:
  - pattern: BreathPattern (current selected pattern)
  - currentPhaseIndex: Int
  - currentPhase: BreathPhase (computed from pattern.phases[currentPhaseIndex])
  - phaseProgress: Double (0.0 → 1.0, updated at ~60Hz)
  - phaseTimeRemaining: TimeInterval (countdown)
  - isRunning: Bool
  - totalElapsedTime: TimeInterval
  - sessionDurationTarget: TimeInterval (from duration selector)
- Methods:
  - start() — begins pacing from phase 0
  - pause() / resume()
  - stop() → saves completed BreathSession to repository
  - reset() — resets to initial state
- Timer: Use DisplayLink or high-frequency Timer for smooth animation (~60fps)
- Phase cycling: when phaseProgress reaches 1.0, advance to next phase (wrapping)
- Haptic feedback at each phase transition: UIImpactFeedbackGenerator(.soft)
- Session auto-completes when totalElapsedTime >= sessionDurationTarget (finish current cycle)

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Breathe/BreatheView.swift` — Main breathe tab screen
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — State management
- `Sources/SocraticJournal/Presentation/Breathe/BreathPacingEngine.swift` — Timing engine
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternSelectorBar.swift` — Horizontal pill selector
- `Sources/SocraticJournal/Presentation/Breathe/Components/MountainWaveView.swift` — Mountain wave Shape/Path animator
- `Sources/SocraticJournal/Presentation/Breathe/Components/PhaseLabel.swift` — Phase name + countdown
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternInfoSection.swift` — About this pattern

**Acceptance Criteria:**
- All 8 patterns selectable from horizontal pill bar
- Mountain wave draws correctly for all phase types (inhale=ascending, hold=peak, exhale=descending)
- Ghost mountain outline visible as reference shape
- Live path animates smoothly at 60fps
- Phase colors transition smoothly (teal→moss→terracotta)
- Countdown timer accurate to 1-second resolution
- Begin/Pause button toggles correctly
- Haptic feedback fires at each phase transition
- Pattern info section updates when pattern selection changes
- Duration selector works (5/10/20 min)
- Pausing stops animation; resuming continues from where left off
- Selecting a new pattern while running stops and resets
- Session is saved to repository when completed

**Priority:** 2
**Dependencies:** 1

---

### 3. Today Tab — Daily Dashboard

**User Story:** As a user, I want to see my daily breath practice at a glance — what I've done, my streak, weekly progress, today's practice schedule, and reminders — so I stay motivated.

**Description:** The Today tab is a calm, structured wellness dashboard. Uses the editorial grid design from the reference images — hairline 1px borders between sections, structured layouts, serif typography.

**Screen Layout (top to bottom in ScrollView):**

**Date Header Section:**
- Top line: full date in ALL-CAPS, dim text, 0.12em letter-spacing, 11pt (e.g., "MONDAY, 3 MARCH")
- Main greeting: "Good morning." / "Good afternoon." / "Good evening." — 26pt Georgia bold, dark text
- Padding: 24px horizontal, 20px bottom
- Hairline border below

**Streak + Week Section (side-by-side grid):**
Two equal columns separated by a vertical hairline border, horizontal hairline below:

Left column — Streak:
- Label: "STREAK" — 11pt, dim, ALL-CAPS, 0.1em tracking
- Large number: 42pt Georgia bold, dark (e.g., "7")
- Unit: "days" — 11pt, mid-brown
- Padding: 20px

Right column — This Week:
- Label: "THIS WEEK" — 11pt, dim, ALL-CAPS, 0.1em tracking
- 7 small squares (26x26pt, 4pt border-radius) in a horizontal row, gap 6pt
- Completed days: teal fill with white checkmark (10pt)
- Future days: paper-colored fill with border
- Today: highlighted border
- Day initial below each square: 8pt, dim (S, M, T, W, T, F, S)
- Padding: 20px

**Today's Practice Section:**
- Section header: "TODAY'S PRACTICE" — 11pt, dim, ALL-CAPS, 0.1em tracking
- Checklist of suggested sessions (hardcoded suggestions based on time of day):
  - Morning: "5 min · Resonance 5.5" — subtitle "Morning · Default"
  - Evening: "10 min · Coherent Breathing" — subtitle "Evening · Optional"
- Each row: circular checkbox (22pt diameter) + label text
  - Completed: teal fill with white checkmark
  - Incomplete: border only (#D8D0C4)
  - Label: 13pt semibold, dark when incomplete, dim+strikethrough when complete
  - Subtitle: 11pt, dim
- Row gap: 14pt, hairline divider between items
- Padding: 20px, hairline border below

**Reminders Section:**
- Section header: "REMINDERS" — 11pt, dim, ALL-CAPS, 0.1em tracking
- Two reminder rows:
  - "07:30" — 20pt Georgia bold, dark + "Morning calm" — 11pt, mid-brown
  - "21:00" — 20pt Georgia bold, dark + "Evening wind-down" — 11pt, mid-brown
- Each row has a toggle switch on the right side:
  - Active: teal background, white thumb, 36x20pt
  - Inactive: border color background, white thumb
  - Thumb: 16pt diameter circle, smooth transition (0.2s)
- Hairline divider between rows
- Padding: 20px, hairline border below

**Haptic Note Banner (bottom):**
- Teal wash background (accent at ~9% opacity), subtle teal border at 12% opacity
- 8pt border-radius
- Vibration icon (SF Symbol: `iphone.radiowaves.left.and.right` or similar) + text
- Text: "Haptic rhythm is on — phase changes use a soft taptic cue so you can breathe eyes-closed."
- 12pt, teal color
- Gap: 10pt between icon and text
- Padding: 12px 14px internal, 16px 20px external

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardView.swift`
- `Sources/SocraticJournal/Presentation/Today/TodayDashboardViewModel.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/DateHeaderView.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/StreakWeekGridView.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/PracticeChecklistView.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/RemindersSection.swift`
- `Sources/SocraticJournal/Presentation/Today/Components/HapticNoteBanner.swift`

**Data Flow:**
- ViewModel loads sessions for today from BreathSessionRepository on appear
- Streak computed by repository
- Weekly completion: check each day of current week for sessions
- Reminders read from UserSettings (breathReminderTimes)
- Greeting changes based on current hour (morning < 12, afternoon < 17, evening)
- Practice suggestions are time-of-day aware

**Acceptance Criteria:**
- Dashboard displays correctly with zero sessions (empty state is welcoming)
- Streak shows correct consecutive day count
- Weekly calendar shows correct completion state for each day
- Today's practice checklist renders with proper checkbox states
- Reminders show with functional toggle switches
- Haptic note banner displays at bottom
- Greeting changes based on time of day
- All hairline borders and grid structure match editorial design
- Georgia serif used for streak number, greeting, and reminder times
- ScrollView performance is smooth
- Screen refreshes when returning from a completed breath session

**Priority:** 3
**Dependencies:** 1, 2

---

### 4. Learn Tab — Breathing Science Articles

**User Story:** As a user, I want to browse fascinating, science-backed articles about breathing so I understand why these techniques work and stay engaged with my practice.

**Description:** The Learn tab is an editorial magazine-style feed. A curated collection about breathing science — beautiful serif typography, expandable article cards, quick-fact strip. All content hardcoded. Tone: fascinating, accessible, inspired by James Nestor's storytelling.

**Screen Layout (top to bottom in ScrollView):**

**Header Section:**
- Title: "The Science" — 22pt Georgia bold, dark text
- Subtitle: "Why slow nasal breathing changes everything" — 12pt, mid-brown
- Padding: 24px 20px 16px
- Hairline border below

**Quick Fact Strip (horizontal scroll):**
- Horizontally scrolling row of fact cards, no gap between cards (separated by vertical hairline borders)
- Each card: 16px 18px padding, minimum width 90pt, right hairline border
- Fact value: 18pt Georgia bold, dark (e.g., "5.5", "25k", "90 min", "NO", "Bohr")
- Fact label: 9pt, dim, 1.4 line-height, max-width ~70pt (e.g., "optimal breaths per min")
- 5 facts:
  1. "5.5" — "optimal breaths per min"
  2. "25k" — "breaths per day"
  3. "90 min" — "nasal cycle"
  4. "NO" — "nitric oxide from nose"
  5. "Bohr" — "CO₂ releases O₂"
- Hairline border below the strip

**Article Cards (expandable):**
4 articles, each a tappable expandable card:

1. **"You breathe 25,000 times a day. Most of them wrong."**
   - Tag: "Start here" (terracotta badge)
   - Duration: "3 min"
   - Subtitle: "The core thesis — mouth vs nasal breathing"
   - Body: "Nasal breathing filters, humidifies, and pressurises air before it reaches the lungs. It also produces nitric oxide — a molecule that dilates blood vessels, improves oxygen transfer, and kills pathogens. Mouth breathing does none of this. The evidence from anthropology is stark: skull records show our ancestors had wide jaws, straight teeth, and open nasal passages. Modern skulls are narrower, more crowded — a direct result of the shift to mouth breathing over centuries."

2. **"The nasal cycle and your brain"**
   - Tag: "Awareness" (teal badge)
   - Duration: "4 min"
   - Subtitle: "Why your nostrils take turns — and what it means"
   - Body: "Every 90 minutes or so, your body shifts airflow from one nostril to the other — the nasal cycle. This isn't random. The right nostril activates the sympathetic nervous system (alertness, left-brain activity). The left nostril activates the parasympathetic (calm, creative, right-brain). You can test this right now: close your right nostril and breathe only through your left. Within minutes, your nervous system follows."

3. **"5.5 — why this number"**
   - Tag: "Science" (teal badge)
   - Duration: "5 min"
   - Subtitle: "HRV, resonance frequency, and the baroreflex"
   - Body: "The cardiovascular system has a natural resonance frequency — a rhythm at which the baroreflex (blood pressure regulator) and heart rate variability are perfectly synchronised. For most humans this is ~0.1 Hz, or about 5.5 breaths per minute. Breathing at this exact rate maximises HRV, lowers blood pressure, and creates a feedback loop between heart, lungs, and brain that has measurable effects on anxiety, sleep, and athletic performance."

4. **"The CO₂ problem"**
   - Tag: "Counter-intuitive" (gold badge)
   - Duration: "4 min"
   - Subtitle: "Why less breathing means more oxygen"
   - Body: "The Bohr Effect: oxygen clings more tightly to haemoglobin when CO₂ is high. If you over-breathe and deplete CO₂, paradoxically less oxygen is released to your tissues. Buteyko's entire system is built on this insight. The chronic 'air hunger' anxiety sufferers feel is usually not a lack of oxygen — it's a trained intolerance to CO₂. Slow, reduced breathing rebuilds this tolerance over weeks."

**Article Card Structure:**
- Each card: hairline border bottom, tappable to expand/collapse
- Collapsed state (18px 20px padding):
  - Top row: tag badge (left) + read time (right, 11pt dim)
  - Tag badge: 10pt bold, 0.08em tracking, colored text on colored background at 8%, 1px colored border at 19% opacity, 3pt border-radius, 2px 7px padding
  - Title: 15pt Georgia bold, dark, 1.4 line-height, supports newlines (whiteSpace pre-line equivalent)
  - Subtitle: 11pt, mid-brown
- Expanded state: adds body text below a hairline divider
  - Body: 13pt, brown (#3D3328), 1.75 line-height
  - 14pt padding-top above body

**Views to Create:**
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedView.swift`
- `Sources/SocraticJournal/Presentation/Learn/LearnFeedViewModel.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/QuickFactStrip.swift`
- `Sources/SocraticJournal/Presentation/Learn/Components/ArticleCard.swift`

**Acceptance Criteria:**
- All 4 articles display in a clean scrollable feed
- Articles expand/collapse on tap with smooth animation
- Quick fact strip scrolls horizontally with correct content
- Tag badges have correct colors per article
- Read times shown on each card
- Content is factually accurate
- Typography uses Georgia for titles, system font for body
- Hairline borders throughout match editorial design
- Scrolling performance is smooth

**Priority:** 4
**Dependencies:** 1

---

### 5. Onboarding Flow — Welcome to Breathe

**User Story:** As a new user, I want a brief, beautiful onboarding that introduces breath pacing and gets me excited to start my first session.

**Description:** A 3-page swipeable onboarding. Replace existing onboarding pages entirely. Calm, confident, inviting tone. Minimal text, strong Georgia serif typography, meditative visuals.

**Delete existing onboarding page files:**
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingWelcomePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingUnlockPage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingVoicePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingFriendsPage.swift`

**Page 1 — "Breathe Better":**
- Cream background (#FAF7F2)
- Large display text: "Breathe Better" (48pt Georgia bold)
- Subtitle: "The most powerful health tool you already have" (20pt system, mid-brown)
- Center: a gentle animated mountain wave in "demo" mode — breathing at resonant pace (5.5s in, 5.5s out)
  - Reuse MountainWaveView in demo mode
  - Teal color at ~50% opacity for subtlety
  - No phase labels or controls — just the visual breathing motion

**Page 2 — "Ancient Wisdom, Modern Science":**
- Cream background
- Title: "Ancient Wisdom, Modern Science" (34pt Georgia bold)
- 4 techniques listed vertically with teal left border accent (4pt wide):
  - "Resonance" — The perfect breath
  - "Box Breathing" — Navy SEAL focus
  - "4-7-8" — Natural tranquilizer
  - "Cyclic Sighing" — Stanford's stress reset
- Each: name in 17pt bold, subtitle in 13pt, teal left border
- Bottom subtitle: "Each backed by research. Guided by a simple visual." (17pt system)

**Page 3 — "Just 5 Minutes a Day":**
- Teal background (#2D5F5D) with cream text
- Title: "Just 5 Minutes a Day" (48pt Georgia bold, cream)
- Subtitle: "Track your practice. Learn the science. Breathe with intention." (20pt, cream at 80% opacity)
- "Get Started" button: cream filled pill with teal text, 12pt bold ALL-CAPS
- Tapping sets hasCompletedOnboarding = true in UserSettings and dismisses

**Container (rewrite NewOnboardingView.swift):**
- TabView with PageTabViewStyle for swipe navigation
- Page indicators: small dots at bottom, teal color
- No skip button — only 3 pages

**Views to Create/Modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — Complete rewrite
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingBreathePage.swift` — Page 1
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingSciencePage.swift` — Page 2
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingStartPage.swift` — Page 3

**Acceptance Criteria:**
- 3-page swipeable onboarding on first launch
- Page 1 has smoothly animating mountain wave
- Page 2 lists 4 key techniques with teal border accent
- Page 3 "Get Started" dismisses onboarding permanently
- Returning users skip straight to Today
- No references to Socratic Journal anywhere
- Clean, minimal, calming aesthetic
- Uses Georgia serif throughout

**Priority:** 5
**Dependencies:** 1, 2 (reuses MountainWaveView)

---

### 6. App Identity & Polish Pass

**User Story:** As a user, I want the app to feel cohesive and polished — consistent naming, smooth transitions, haptic feedback, and attention to detail throughout.

**Description:** Final polish pass tying everything together. Update identity, refine all transitions, validate haptics, handle edge cases.

**Identity Updates:**
- Update display name in Info.plist / project.yml to "Breathe"
- Search entire codebase for "Socratic Journal" or "socraticjournal" strings — replace with "Breathe" / "breathe"
- Update UserDefaults key prefix from "com.socraticjournal" to "com.breathe"
- Update AboutView app name

**Navigation & Transitions:**
- Tab switching is instant (no animation)
- Breathe tab: all interaction is inline (no pushes), smooth animation on pattern switch
- Settings: presented as NavigationStack push from a gear icon
- Full-screen cover for future session expansion if needed

**Haptic Feedback (throughout the app):**
- Phase transitions during pacing: UIImpactFeedbackGenerator(.soft) — controlled by hapticFeedbackEnabled setting
- Session start (after pressing Begin): UIImpactFeedbackGenerator(.medium)
- Session complete (when timer ends): UINotificationFeedbackGenerator(.success)
- Pattern selection tap: UISelectionFeedbackGenerator
- Toggle switch interaction: UISelectionFeedbackGenerator
- Article card expand/collapse: UIImpactFeedbackGenerator(.light)

**Edge Cases & Robustness:**
- App backgrounding during session: automatically pause, resume on foreground (ScenePhase)
- Dynamic Type: ensure stat numbers, pattern cards, and articles scale reasonably
- VoiceOver: mountain wave announces phase changes ("Inhale", "Hold", "Exhale") at transitions
- Haptic toggle in Settings controls whether phase-transition haptics fire
- Empty states: Today dashboard graceful with zero sessions/streak

**Acceptance Criteria:**
- Zero references to "Socratic Journal" visible anywhere
- App display name is "Breathe"
- Haptic feedback present at all specified interaction points
- Haptic toggle in settings works
- Settings view clean and relevant
- App handles backgrounding during sessions
- Overall experience feels like one cohesive editorial app
- VoiceOver announces breath phases
- All 3 tabs feel visually consistent (same typography, colors, border treatment)

**Priority:** 6
**Dependencies:** 1, 2, 3, 4, 5
