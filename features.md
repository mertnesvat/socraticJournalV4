---
base_branch: feature/next-phase-2
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: Breathe — Phase 2: Deep Breathing Science & Complete Experience

> Phase 2 builds on the existing breath pacer app (3 tabs: Today, Breathe, Learn) with deeper breathing science, session history, guided programs, personalized recommendations, and a polished completion experience — all inspired by James Nestor's "Breath." Every feature must maintain the existing warm cream editorial design language (teal `#2D5F5D` primary, coral `#C4502A` secondary, Georgia/serif headings, hairline grids, `#FAF7F2` cream backgrounds) and follow the established Clean Architecture patterns (@Observable, @MainActor, repository protocols, UserDefaults JSON persistence). No new targets or complex infrastructure (no widgets, no HealthKit, no audio) — focus on UI, content, and core user experience.

---

### 1. Session History & Progress Analytics — Lifetime Stats & Weekly Chart

**User Story:** As a user, I want to see my lifetime breathing stats and a weekly bar chart — so I can track how much I've practiced and stay motivated by seeing progress over time.

**Description:** Add a progress view accessible from the Today tab. This first part covers the header stats and weekly visualization. The view is pushed via NavigationStack from a "See Progress" link on the Today tab.

**Screen Layout (ScrollView, top to bottom):**

**Navigation:**
- Add a "See Progress" text button (teal, 11pt uppercase tracked) in the Today tab, positioned after the daily goal progress section
- Tapping pushes a `ProgressView` via NavigationStack
- Back button returns to Today tab

**Header Section:**
- "Your Journey" in 22pt serif bold dark text
- Subtitle: "Every breath counts" in 12pt mid-brown text
- Hairline border below

**Lifetime Stats Row (horizontal, three stat columns):**
- Three columns separated by vertical hairline dividers
- Column 1: Total minutes practiced — large 42pt serif bold number + "minutes" label in 11pt dim below
- Column 2: Total sessions completed — same format + "sessions" label
- Column 3: Longest streak — same format + "days" label
- Use the existing `StatCard` style from AppShapes.swift or similar editorial layout
- Paper background (`#F2EDE4`) for the row
- Hairline border below

**Weekly Bar Chart Section:**
- "THIS WEEK" section header (11pt uppercase tracked dim, with top hairline border)
- 7 vertical bars representing each day of the current week (Monday through Sunday)
- Bar specifications:
  - Width: 28pt per bar with 8pt gap between
  - Height: proportional to minutes practiced that day, max bar height 120pt
  - Fill color: teal (`#2D5F5D`) with 8pt top corner radius
  - Empty days: show a 2pt-height stub in warm gray (`#B0A898`)
  - Today's bar: slightly brighter teal or a subtle dotted top border to distinguish
- Day labels below bars: 11pt dim text showing day initials (M, T, W, T, F, S, S)
- Y-axis: no explicit axis — just the bars. Auto-scale so the tallest bar fills the height
- Below the chart: "X min this week" summary in 13pt mid text, centered
- Hairline border below
- Use SwiftUI `Canvas` or simple `RoundedRectangle` views for the bars

**Empty State (no sessions ever):**
- Show the same header but with "0" for all stats
- Chart shows all empty stubs
- Encouraging message: "Start your first session to begin tracking your journey" in 13pt mid text, centered

**Repository Updates Needed:**
- Add to `BreathSessionRepositoryProtocol`:
  - `func getAllSessions() async throws -> [BreathSession]`
  - `func getTotalMinutes() async throws -> Double`
  - `func getTotalSessions() async throws -> Int`
  - `func getLongestStreak() async throws -> Int`
- Implement in `UserDefaultsBreathSessionRepository`
- `getLongestStreak()`: iterate through all sessions, group by calendar day, find the longest consecutive run of days with at least 1 session

**New Files to Create:**
- `Sources/SocraticJournal/Presentation/Progress/ProgressView.swift` — Main progress screen (ScrollView container)
- `Sources/SocraticJournal/Presentation/Progress/ProgressViewModel.swift` — Data loading, stats computation
- `Sources/SocraticJournal/Presentation/Progress/Components/WeeklyBarChart.swift` — Bar chart component

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Today/TodayView.swift` — Add "See Progress" navigation link, wrap in NavigationStack if not already
- `Sources/SocraticJournal/Domain/Repositories/BreathSessionRepositoryProtocol.swift` — Add new methods
- `Sources/SocraticJournal/Data/Repositories/UserDefaultsBreathSessionRepository.swift` — Implement new methods

**Acceptance Criteria:**
- "See Progress" link visible on Today tab, navigates to ProgressView
- Lifetime stats show accurate totals (minutes, sessions, longest streak)
- All three stat columns display with correct formatting and dividers
- Weekly bar chart renders 7 bars with correct proportional heights
- Today's bar visually distinguished from other days
- Empty days show subtle stub bar
- "X min this week" summary accurate
- Empty state shows zeros and encouraging message
- Back navigation to Today tab works
- Data refreshes when returning from a completed session
- Design follows editorial aesthetic (hairline borders, serif headings, cream background)
- Scroll performance smooth

**Priority:** 1
**Dependencies:** None

---

### 2. Session History & Progress Analytics — Monthly Heatmap & Pattern Breakdown

**User Story:** As a user, I want to see a monthly calendar heatmap of my practice and a breakdown of which patterns I use most — so I can visualize my consistency and understand my practice habits.

**Description:** Continue building the ProgressView from Feature 1 by adding the monthly heatmap and pattern usage sections below the weekly chart.

**Monthly Calendar Heatmap Section (added below weekly chart):**
- "THIS MONTH" section header (11pt uppercase tracked dim, with top hairline border)
- Month/year header row: left chevron + "March 2026" in 15pt serif bold + right chevron
  - Chevrons: SF Symbol `chevron.left` / `chevron.right`, teal color, tappable
  - Tapping navigates to previous/next month (with animation)
- Day-of-week header row: S, M, T, W, T, F, S in 9pt dim text
- Calendar grid: 7 columns, up to 6 rows
- Each day cell: 32×32pt rounded rectangle (4pt corner radius)
  - No practice that day: warm cream background with warm border (`#D8D0C4`)
  - Light practice (1-5 min): teal at 20% opacity fill
  - Moderate practice (5-15 min): teal at 50% opacity fill
  - Deep practice (15+ min): full teal (`#2D5F5D`) fill
  - Days outside current month: invisible (clear)
- Day numbers inside cells in 10pt (dark text for practiced days, dim text for empty days, white text for deep practice days)
- Today's cell: subtle teal border ring (2pt) regardless of fill level
- Hairline border below the entire section

**Pattern Breakdown Section (below heatmap):**
- "PATTERNS PRACTICED" section header (11pt uppercase tracked dim, with top hairline border)
- Vertical list of patterns the user has used, sorted by total minutes (most-used first)
- Only show patterns the user has actually used (not all 8)
- Each row layout:
  - Left: colored dot (8pt circle, using pattern's `tagColorHex`) + pattern name in 13pt serif bold
  - Right: total minutes in 13pt mid text + session count in 11pt dim text (e.g., "45 min · 12 sessions")
  - Below the text: horizontal progress bar showing relative usage
    - Bar track: warm gray at 10% opacity, full width, 4pt height, rounded
    - Bar fill: uses pattern's `tagColorHex`, width proportional (widest bar = most used = 100% width)
  - Hairline divider between rows
- If only 1 pattern used, bar fills 100%
- Empty state: "Complete a session to see your pattern usage" in 13pt mid text

**Repository Updates Needed:**
- Add to `BreathSessionRepositoryProtocol`:
  - `func getSessionsForMonth(year: Int, month: Int) async throws -> [BreathSession]`
  - `func getSessionsByPattern() async throws -> [String: [BreathSession]]`
- Implement in `UserDefaultsBreathSessionRepository`
- `getSessionsForMonth`: filter sessions where `Calendar.current.component(.year, from: session.startedAt) == year` and same for month
- `getSessionsByPattern`: group all sessions by `patternId` into a dictionary

**New Files to Create:**
- `Sources/SocraticJournal/Presentation/Progress/Components/MonthlyHeatmap.swift` — Calendar heatmap view
- `Sources/SocraticJournal/Presentation/Progress/Components/PatternBreakdownRow.swift` — Single pattern usage row

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Progress/ProgressView.swift` — Add heatmap and breakdown sections
- `Sources/SocraticJournal/Presentation/Progress/ProgressViewModel.swift` — Add month navigation state, pattern grouping logic
- `Sources/SocraticJournal/Domain/Repositories/BreathSessionRepositoryProtocol.swift` — Add new methods
- `Sources/SocraticJournal/Data/Repositories/UserDefaultsBreathSessionRepository.swift` — Implement new methods

**Acceptance Criteria:**
- Monthly heatmap displays correct grid for the current month
- Day cells show correct intensity based on practice minutes
- Month navigation (prev/next) works with smooth transition
- Today's cell has a visible teal border ring
- Days outside the month are not visible
- Pattern breakdown lists patterns sorted by usage
- Progress bars proportionally sized (most-used = full width)
- Pattern dots use correct tag colors from BreathPattern
- Empty states handled gracefully for both sections
- Performance smooth when navigating between months
- Design follows editorial aesthetic (hairline borders, section headers, cream backgrounds)

**Priority:** 2
**Dependencies:** 1

---

### 3. Session History & Progress Analytics — Milestones & Achievements

**User Story:** As a user, I want to earn milestones as I progress in my practice — like "First Breath," "Pattern Explorer," and "Monthly Master" — so I feel a sense of accomplishment and have goals to work toward.

**Description:** Add a milestones section at the bottom of the ProgressView. Milestones are achievements that unlock based on practice data. They provide gamification-lite motivation without being pushy.

**Milestone Definitions (10 milestones):**

```
1. "First Breath" — Complete 1 session. Icon: SF Symbol `wind`. Teal color.
2. "Week One" — Practice 7 consecutive days. Icon: `calendar`. Teal color.
3. "Century" — Accumulate 100 total minutes. Icon: `clock`. Teal color.
4. "Pattern Explorer" — Complete at least 1 session with each of all 8 patterns. Icon: `square.grid.3x3`. Coral color.
5. "Dawn Breather" — Complete a session before 7:00 AM. Icon: `sunrise`. Coral color.
6. "Night Owl" — Complete a session after 10:00 PM. Icon: `moon.stars`. Purple (#6B4C8A) color.
7. "Marathon" — Complete a 20-minute session. Icon: `timer`. Coral color.
8. "Monthly Master" — Practice every day for 30 consecutive days. Icon: `crown`. Teal color.
9. "Thousand Minutes" — Accumulate 1000 total minutes. Icon: `star`. Teal color.
10. "Breath Master" — Unlock all other 9 milestones. Icon: `trophy`. Teal color.
```

**Milestone Data Model:**

```swift
struct Milestone: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String       // e.g., "Complete your first breathing session"
    let iconName: String          // SF Symbol name
    let colorHex: String          // Milestone accent color
    var isUnlocked: Bool
    var unlockedAt: Date?
}
```

- Milestone unlock state persisted in UserDefaults (key: `"com.breathe.milestones"`)
- Milestone checking runs in ProgressViewModel when view appears and after each session

**Milestones Section (at bottom of ProgressView):**
- "MILESTONES" section header (11pt uppercase tracked dim, with top hairline border)
- 2-column grid layout (LazyVGrid with 2 flexible columns, 12pt spacing)
- Each milestone card: ~(screenWidth/2 - 30pt) wide, minimum 100pt tall
  - Unlocked state:
    - Teal (or milestone-specific color) border (1.5pt), 8pt corner radius
    - SF Symbol icon in milestone color, 24pt
    - Title in 12pt serif bold, dark text
    - Description in 10pt dim text
    - Unlock date: "Mar 3" in 9pt dim text at bottom
  - Locked state:
    - Warm gray border (`#D8D0C4`), 8pt corner radius
    - SF Symbol icon in warm gray, 24pt
    - Title in 12pt serif bold, warm gray text
    - "?" instead of description in 12pt dim text
    - No date
- Cards have paper background (`#F2EDE4`)
- Unlocked cards appear first, then locked cards

**Milestone Check Logic (in ProgressViewModel):**
```
For each milestone, check condition against session repository data:
1. "First Breath": getAllSessions().count >= 1
2. "Week One": getStreak() >= 7
3. "Century": getTotalMinutes() >= 100
4. "Pattern Explorer": getSessionsByPattern().keys.count >= 8
5. "Dawn Breather": any session where Calendar hour of startedAt < 7
6. "Night Owl": any session where Calendar hour of startedAt >= 22
7. "Marathon": any session where totalDuration >= 1200 (20 min in seconds)
8. "Monthly Master": getLongestStreak() >= 30
9. "Thousand Minutes": getTotalMinutes() >= 1000
10. "Breath Master": all other 9 milestones unlocked
```
- When a milestone newly unlocks, save the unlock date
- Do NOT show a modal or toast for new unlocks — the user discovers them by visiting Progress

**New Files to Create:**
- `Sources/SocraticJournal/Domain/Entities/Milestone.swift` — Milestone model + static definitions of all 10
- `Sources/SocraticJournal/Presentation/Progress/Components/MilestoneCard.swift` — Single milestone card view
- `Sources/SocraticJournal/Presentation/Progress/Components/MilestoneGridSection.swift` — 2-column grid container

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Progress/ProgressView.swift` — Add milestones section at bottom
- `Sources/SocraticJournal/Presentation/Progress/ProgressViewModel.swift` — Add milestone checking logic, persistence

**Acceptance Criteria:**
- All 10 milestones defined with correct icons, colors, and descriptions
- 2-column grid displays all milestones (unlocked first, then locked)
- Unlocked milestones show colored border, icon, title, description, and date
- Locked milestones show gray styling with "?" text
- Milestone conditions checked correctly against real session data
- Unlock state persists across app launches
- "Breath Master" only unlocks when all other 9 are unlocked
- Empty state (no milestones unlocked): all cards show locked state
- Grid layout works correctly on different screen widths
- Design follows editorial aesthetic (paper backgrounds, serif titles, hairline sections)

**Priority:** 3
**Dependencies:** 2

---

### 4. Expanded Learn Tab — Category Filtering & 5 More Quick Facts

**User Story:** As a user, I want to filter the Learn tab articles by category and see more fascinating quick facts — so I can find topics that interest me and absorb more breathing science at a glance.

**Description:** Add a category filter bar to the Learn tab and expand the quick facts from 5 to 10. The existing 4 articles remain unchanged. This feature adds filtering infrastructure that Feature 5 will use when adding more articles.

**Category Filter Bar (new, between Quick Fact Strip and articles):**
- Horizontal ScrollView of pill-shaped category chips
- Same chip style as the pattern selector on the Breathe tab:
  - 12pt serif font text
  - Selected: teal background (`#2D5F5D`), white text, bold
  - Unselected: warm border (`#D8D0C4`), mid-brown text, normal weight
  - Pill shape: 20pt height, 12pt horizontal padding, capsule shape
- Categories:
  - "All" (default, shows all articles)
  - "Fundamentals" (teal tag color)
  - "Patterns" (coral tag color)
  - "History" (brown `#7A6030` tag color)
  - "Advanced" (purple `#6B4C8A` tag color)
- Tapping a category filters the article list below
- Filtering uses a smooth opacity animation (0.3s): non-matching articles fade out and matching ones fade in
- Hairline border below the filter bar

**Assign Categories to Existing Articles:**
- Article 1 "You breathe 25,000 times a day..." → Category: "Fundamentals"
- Article 2 "The nasal cycle and your brain" → Category: "Fundamentals"
- Article 3 "5.5 — why this number" → Category: "Fundamentals"
- Article 4 "The CO₂ problem" → Category: "Fundamentals"

**New Quick Facts (add 5 more to the existing 5, total 10):**
- Keep existing: "5.5" / optimal breaths per min, "25k" / breaths per day, "90 min" / nasal cycle, "NO" / nitric oxide from nose, "Bohr" / CO₂ releases O₂
- Add:
  6. "40%" / "of people are chronic mouth breathers"
  7. "pH 7.4" / "blood alkalinity from breathing"
  8. "2x" / "nitric oxide from humming"
  9. "1500 L" / "of air through your nose daily"
  10. "10s" / "one breath at resonance pace"

**Data Model Update:**
- Add a `category` field to the article data structure (currently hardcoded in LearnView or a content enum)
- Category is a string matching one of: "Fundamentals", "Patterns", "History", "Advanced"

**New Files to Create:**
- `Sources/SocraticJournal/Presentation/Learn/Components/CategoryFilterBar.swift` — Horizontal category chip selector

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Learn/LearnView.swift` — Add category filter bar, add 5 new quick facts, add category field to article data, implement filtering logic, add @State for selectedCategory

**Acceptance Criteria:**
- Category filter bar appears between Quick Fact Strip and article cards
- "All" selected by default, showing all articles
- Tapping a category filters articles smoothly (opacity animation)
- Tapping "All" shows all articles again
- All 10 quick facts display in the horizontal scroll strip
- New quick facts have correct values and labels
- Existing 4 articles tagged with "Fundamentals" category
- Category chips match Breathe tab pattern selector style (visual consistency)
- Expand/collapse article behavior still works correctly with filtering
- Only one article expanded at a time (existing behavior preserved)
- Scroll performance smooth with filter transitions

**Priority:** 4
**Dependencies:** None

---

### 5. Expanded Learn Tab — 8 New Science Articles

**User Story:** As a user, I want to read more articles about breathing science — covering the evolution of the human airway, the vagus nerve, pattern-specific deep dives, and advanced topics like Wim Hof and Buteyko — so I can deeply understand why I'm practicing.

**Description:** Add 8 new articles to the Learn tab, bringing the total from 4 to 12. Each article has a category (using the filter from Feature 4), tag, read time, title, subtitle, and body text. All content inspired by James Nestor's "Breath" research.

**New Articles to Add (articles 5-12):**

**Article 5: "The evolution of the crooked jaw"** (Category: History, brown `#7A6030` tag, 6 min)
- Subtitle: "How modern life changed the shape of our skulls"
- Body: "For 2 million years, our ancestors had wide jaws, straight teeth, and spacious nasal passages. Then, about 300 years ago, something changed. The industrial revolution brought processed food — softer, requiring less chewing. Within generations, human jaws narrowed, teeth crowded, and airways shrank. George Catlin documented this in 1870 among Indigenous peoples who had adopted Western diets. The skulls tell the story: pre-industrial humans rarely had crooked teeth. The modern epidemic of sleep apnea, snoring, and mouth breathing is, in part, an architectural problem — our airways are literally too small for the air we need. James Nestor's experiment with Stanford showed that just 10 days of forced mouth breathing raised blood pressure, reduced blood oxygen, and increased snoring by 4,800%."

**Article 6: "Nitric oxide — the miracle molecule"** (Category: Fundamentals, teal `#2D5F5D` tag, 4 min)
- Subtitle: "Why your nose makes its own medicine"
- Body: "In 1998, three scientists won the Nobel Prize for discovering nitric oxide's role in the body. Your paranasal sinuses produce it continuously — but only when you breathe through your nose. NO dilates blood vessels (lowering blood pressure), improves oxygen transfer in the lungs, and has direct antimicrobial properties. Humming increases NO production by 15x. This is why many breathing traditions involve nasal breathing with vocalization. When you breathe through your mouth, you bypass this entire pharmacy. The military has studied nasal NO for its ability to prevent respiratory infections in close quarters. It's one of the strongest arguments for nose-over-mouth breathing."

**Article 7: "Box Breathing — the Navy SEAL secret"** (Category: Patterns, coral `#C4502A` tag, 5 min)
- Subtitle: "How equal-phase breathing controls the stress response"
- Body: "Mark Divine, a retired Navy SEAL commander, introduced Box Breathing to the special operations community in the early 2000s. The pattern — 4 seconds inhale, 4 hold, 4 exhale, 4 hold — works because of the holds. During a hold, CO₂ rises slightly, which triggers a mild stress response. But the structured pattern teaches the nervous system that this stress is manageable. Over weeks of practice, your CO₂ tolerance increases, and your baseline anxiety decreases. The hold phases also demand attentional control — you cannot hold your breath and ruminate simultaneously. This is why Box Breathing is prescribed before combat operations, high-stakes negotiations, and surgical procedures. The 4-4-4-4 ratio isn't magic — it's the equality of phases that matters."

**Article 8: "The Wim Hof protocol — science vs spectacle"** (Category: Advanced, purple `#6B4C8A` tag, 7 min)
- Subtitle: "What the ice man actually proved"
- Body: "Wim Hof's fame rests on spectacle — swimming under ice, climbing Everest in shorts. But the science beneath is real and peer-reviewed. A 2014 study at Radboud University showed that Hof-trained subjects could voluntarily suppress their innate immune response — something previously thought impossible. The mechanism: 30 rounds of rapid breathing (Tummo-style) depletes CO₂, creating respiratory alkalosis. This alkaline blood shift triggers adrenaline release, which suppresses inflammatory cytokines. The breath hold that follows creates a rebound — CO₂ floods back, vasodilation occurs, and the body enters a heightened state. The risks are real: loss of consciousness is possible during holds (never in water), and the hyperventilation can trigger panic in susceptible individuals. The practice builds resilience, not relaxation — it's the opposite of slow breathing."

**Article 9: "Buteyko — the doctor who said we breathe too much"** (Category: History, brown `#7A6030` tag, 6 min)
- Subtitle: "A Ukrainian physician's counter-intuitive revolution"
- Body: "In 1952, Konstantin Buteyko was monitoring critically ill patients in a Moscow hospital when he noticed something strange: the sickest patients breathed the most. Not less — more. He spent the next 40 years developing a theory: modern humans chronically over-breathe, depleting CO₂ and paradoxically reducing oxygen delivery to tissues (via the Bohr Effect). His Reduced Breathing technique — deliberately taking smaller, lighter breaths — was dismissed by Western medicine for decades. Then the evidence accumulated. A 2008 Cochrane review found Buteyko breathing reduced asthma medication use by 50-90% in clinical trials. The key metric he invented — the Control Pause (comfortable breath-hold time after a normal exhale) — remains the best proxy for CO₂ tolerance. A healthy CP is 25-40 seconds. Most chronic mouth breathers score under 15."

**Article 10: "The vagus nerve — your body's brake pedal"** (Category: Fundamentals, teal `#2D5F5D` tag, 5 min)
- Subtitle: "How exhaling activates your longest cranial nerve"
- Body: "The vagus nerve is the longest cranial nerve in the body, running from the brainstem to the gut. It controls heart rate, digestion, immune response, and mood. Exhaling stimulates it directly — which is why every calming breath pattern emphasises the exhale. The mechanism is mechanical: your diaphragm descends during inhalation (compressing abdominal organs, increasing heart rate) and rises during exhalation (releasing pressure, decreasing heart rate). This is called respiratory sinus arrhythmia, and it's the basis of HRV. When you breathe at 5.5 BPM, the vagal stimulation from each exhale is maximised. People with high vagal tone — measured by HRV — recover faster from stress, sleep better, digest more efficiently, and report higher emotional wellbeing. You can train vagal tone. The tool is your breath."

**Article 11: "Alternate nostril breathing — ancient practice, modern neuroscience"** (Category: Patterns, coral `#C4502A` tag, 5 min)
- Subtitle: "Why yogis have been right for 3,000 years"
- Body: "Nadi Shodhana (alternate nostril breathing) appears in the Hatha Yoga Pradipika from the 15th century. Modern neuroscience has validated its core claim: each nostril preferentially activates the opposite brain hemisphere. Right nostril breathing increases left-hemisphere activity (logic, language, analytical thinking) and sympathetic arousal. Left nostril breathing increases right-hemisphere activity (creativity, spatial awareness, intuition) and parasympathetic activation. The nasal cycle — your body's natural alternation between nostrils every 90-120 minutes — reflects this hemispheric oscillation. Alternate nostril breathing manually overrides the cycle, creating bilateral balance. Studies show it reduces blood pressure, improves cognitive performance, and decreases perceived stress more effectively than simple slow breathing alone."

**Article 12: "The future of breathing — what's next"** (Category: Advanced, purple `#6B4C8A` tag, 4 min)
- Subtitle: "From ancient wisdom to biometric feedback"
- Body: "Breathing science is entering a new era. Wearable devices now measure respiratory rate, HRV, and blood oxygen in real-time — giving us feedback loops our ancestors never had. Researchers at Stanford are studying how specific breathing patterns can modulate gene expression through epigenetic mechanisms. The military is investing in respiratory training for cognitive performance under extreme conditions. And the simplest intervention remains the most powerful: breathe through your nose, breathe slowly, breathe less. James Nestor's central insight isn't about any single technique — it's that the quality of your breathing determines the quality of your health. Every breath is a choice."

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Learn/LearnView.swift` — Add 8 new articles to the content array with their categories, tags, titles, subtitles, read times, and body text

**Acceptance Criteria:**
- All 12 articles display correctly (4 existing + 8 new)
- Each article has correct category, tag color, read time, title, subtitle, and body
- Category filtering from Feature 4 works with all 12 articles
- "Fundamentals" shows articles 1-4, 6, 10 (6 articles)
- "Patterns" shows articles 7, 11 (2 articles)
- "History" shows articles 5, 9 (2 articles)
- "Advanced" shows articles 8, 12 (2 articles)
- "All" shows all 12
- Expand/collapse still works correctly (one at a time)
- Article body text uses warm brown color with generous line spacing (1.75 line height)
- Tags have correct colors matching their categories
- Scroll performance smooth with 12 articles
- No visual regression to existing 4 articles

**Priority:** 5
**Dependencies:** 4

---

### 6. Session Completion Experience — Summary & Daily Progress

**User Story:** As a user, when I complete a breathing session I want a beautiful completion screen that celebrates my practice, shows what I achieved, and displays my daily progress — so each session ends with a sense of accomplishment.

**Description:** Replace the current session-end behavior (which simply stops and resets) with a dedicated completion screen. This is the first part — session summary and daily goal progress. Feature 7 adds the breath insights.

**Completion Screen (presented as a full-screen overlay on the Breathe tab):**

**Trigger:** When the pacing engine's session completes (totalElapsed >= targetDuration and current cycle finishes), automatically present the completion overlay.

**Animation Entry:**
- Screen fades in from transparent over 0.4s
- Background: cream at 98% opacity (blurs the Breathe tab behind)

**Animated Checkmark (top center):**
- Teal circle (60pt diameter) that draws its stroke animation over 0.6s (use `trim(from:to:)` with animation)
- White checkmark SF Symbol (`checkmark`) fades in inside the circle at 0.4s delay
- Success haptic fires on appear: `UINotificationFeedbackGenerator(.success)`

**"Session Complete" Title:**
- "Session Complete" in 22pt serif bold, dark text
- Fades in 0.2s after the checkmark animation finishes
- Centered below the checkmark

**Session Summary Section:**
- "SESSION" section header (11pt uppercase tracked dim), appears below title
- Three inline stat columns separated by vertical hairline dividers:
  - Column 1: duration formatted as "MM:SS" in 28pt serif bold + "minutes" in 11pt dim below
  - Column 2: cycles count in 28pt serif bold + "cycles" in 11pt dim below
  - Column 3: pattern name in 13pt serif bold + timing string (e.g., "5.5 · 5.5") in 11pt dim below
- Hairline border below

**Daily Progress Section:**
- "TODAY" section header (11pt uppercase tracked dim)
- GeometricRing donut (same component used in TodayView) showing daily goal progress
  - Size: 80pt diameter
  - Track: warm gray (`#D8D0C4`), ring: teal
  - Progress: (totalMinutesToday / dailyGoalMinutes) clamped to 1.0
- Text below ring:
  - "X.X / Y min" in 13pt mid text (e.g., "7.5 / 10 min")
  - If goal reached: "Daily goal reached" in 13pt teal bold with checkmark icon (`checkmark.circle.fill`)
  - If not reached: "X.X min remaining" in 13pt mid text
- The progress should include the just-completed session (save session before showing this screen)

**Action Buttons (bottom of overlay, 24pt bottom padding):**
- "Done" button (teal filled pill, 12pt uppercase tracked serif) — dismisses overlay, returns to Breathe tab idle state
- "Go to Today" text button below (teal, 12pt) — dismisses overlay and switches to Today tab

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Breathe/BreatheView.swift` — Add overlay presentation when session completes, add `@State var showSessionComplete = false`
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — Trigger completion (save session first, then set flag), provide session data to completion view

**New Files to Create:**
- `Sources/SocraticJournal/Presentation/Breathe/SessionCompleteView.swift` — Full completion overlay
- `Sources/SocraticJournal/Presentation/Breathe/Components/SessionSummarySection.swift` — Three-column stat section

**Acceptance Criteria:**
- Completion screen appears automatically when session timer reaches target duration
- Animated checkmark draws smoothly over 0.6s
- Success haptic fires on appear
- "Session Complete" text fades in after checkmark
- Session stats (duration, cycles, pattern) display accurately
- Duration formatted as MM:SS
- Daily progress ring shows correct updated progress (including just-completed session)
- "Daily goal reached" appears when applicable with checkmark icon
- "Done" returns to Breathe tab idle state (engine reset, no session active)
- "Go to Today" switches to Today tab
- Overlay has cream background at ~98% opacity
- Design matches editorial aesthetic (serif headings, hairline sections)
- Smooth animation in and out
- Works in both light and dark mode

**Priority:** 6
**Dependencies:** None

---

### 7. Session Completion Experience — Rotating Breath Insights

**User Story:** As a user, I want to see a fascinating breathing science fact after each session — tailored to the pattern I just practiced — so I learn something new every time and stay curious about the science behind my practice.

**Description:** Add a "Did You Know?" insight section to the session completion screen from Feature 6. Each completion shows a random insight, weighted toward the pattern the user just practiced.

**Breath Insights Data (30 insights):**

Each insight has: id, text, and an array of relatedPatternIds (which patterns this fact is relevant to).

```
1. "Breathing at 5.5 BPM synchronises your heart rate variability to its peak coherence — the same rhythm as Buddhist mantras and Catholic rosary prayers." — [resonance, coherent]
2. "Your nose produces nitric oxide, a molecule that won three scientists the Nobel Prize. Mouth breathing bypasses it entirely." — [all patterns]
3. "Navy SEALs practice Box Breathing before operations. The equal-phase structure forces the nervous system out of fight-or-flight." — [box]
4. "A single physiological sigh can lower cortisol within 30 seconds — faster than any pharmaceutical." — [physiologicalSigh]
5. "The Bohr Effect: paradoxically, breathing less delivers more oxygen to your tissues. CO₂ is the key that unlocks haemoglobin." — [buteykoReduced]
6. "James Nestor's 10-day mouth-breathing experiment increased his snoring by 4,800% and raised his blood pressure into stage 1 hypertension." — [all patterns]
7. "Your diaphragm is the most efficient breathing muscle — yet most adults have forgotten how to use it, relying instead on shallow chest breathing." — [all patterns]
8. "Ancient Sanskrit texts describe 'prana' — breath as life force. Modern science calls it the autonomic nervous system. They're describing the same thing." — [alternateNostril]
9. "HRV (heart rate variability) is the single best biomarker of overall health. You can train it directly through slow breathing." — [resonance, coherent]
10. "The nasal cycle alternates your breathing between nostrils every 90 minutes, matching your brain's ultradian rhythm of alertness and rest." — [alternateNostril]
11. "Humming increases nitric oxide production by 15 times. This is why 'Om' chanting has measurable physiological effects." — [all patterns]
12. "CO₂ is not waste — it's a vasodilator, a bronchodilator, and the molecule that releases oxygen from haemoglobin." — [buteykoReduced, box]
13. "Your breathing rate at rest predicts your lifespan better than cholesterol, blood pressure, or BMI." — [all patterns]
14. "Wim Hof's followers demonstrated voluntary control of the innate immune system — previously thought impossible — through breathing alone." — [tummo]
15. "Dr. Andrew Weil calls 4-7-8 breathing a 'natural tranquiliser.' He recommends not doing it while driving because it's genuinely sedating." — [fourSevenEight]
16. "Pre-industrial human skulls had wider jaws and larger airways. The modern epidemic of breathing problems is partly architectural." — [all patterns]
17. "Slow breathing activates the vagus nerve — your body's longest cranial nerve and the master switch for rest-and-digest." — [resonance, coherent, fourSevenEight]
18. "The 'air hunger' anxiety sufferers feel is usually not a lack of oxygen — it's a trained intolerance to carbon dioxide." — [buteykoReduced]
19. "Breathing through your left nostril preferentially activates your parasympathetic nervous system. Through your right, sympathetic." — [alternateNostril]
20. "Stanford neuroscientist Andrew Huberman identified the physiological sigh as the fastest known method to reduce physiological arousal." — [physiologicalSigh]
21. "The 4-7-8 pattern creates a 19-second breath cycle. At this pace, your blood pressure measurably drops within minutes." — [fourSevenEight]
22. "Box Breathing's holds build CO₂ tolerance — the real key to comfortable, anxiety-free breathing." — [box]
23. "Coherent breathing at 5 BPM produces the same resonance effect as 5.5 BPM but with easier whole-number counting." — [coherent]
24. "During a physiological sigh, the double inhale pops open collapsed alveoli in your lungs, maximising gas exchange surface area." — [physiologicalSigh]
25. "Buteyko's Control Pause test — comfortable breath hold time after a normal exhale — is the best proxy for overall breathing health." — [buteykoReduced]
26. "Alternate nostril breathing was validated by modern EEG studies: it produces measurable bilateral brain hemisphere synchronisation." — [alternateNostril]
27. "Tummo practitioners can raise their skin temperature by 8°C through breathing alone — measured under laboratory conditions in the Himalayas." — [tummo]
28. "A 2023 Stanford study found that 5 minutes of daily cyclic sighing was more effective at reducing stress than 5 minutes of meditation." — [physiologicalSigh]
29. "The vagus nerve carries 80% of its signals from body to brain — meaning your breathing literally talks to your brain." — [resonance, coherent, fourSevenEight]
30. "Every prayer tradition in the world — rosary, mantras, dhikr, psalms — converges on roughly the same breathing rate: 5-6 breaths per minute." — [resonance, coherent]
```

**Selection Logic:**
- 70% chance: select a random insight from those matching the current session's patternId
- 30% chance: select any random insight
- Never show the same insight twice in a row (track last shown insight ID in memory)

**UI — "Did You Know?" Section (added to SessionCompleteView below daily progress):**
- "DID YOU KNOW?" section header (11pt uppercase tracked, teal color — slightly different from other dim headers to draw attention)
- Insight text: 13pt body text, warm brown color, line height 1.75
- Subtle teal left border (3pt width) on the insight text container
- Padding: 16pt all sides inside the container
- Light teal background at 5% opacity for the container

**New Files to Create:**
- `Sources/SocraticJournal/Domain/Entities/BreathInsight.swift` — Insight model with id, text, relatedPatternIds array, plus static array of all 30 insights
- `Sources/SocraticJournal/Presentation/Breathe/Components/BreathInsightCard.swift` — Insight display card with teal left border

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Breathe/SessionCompleteView.swift` — Add insight section below daily progress

**Acceptance Criteria:**
- All 30 insights defined with correct text and pattern associations
- Random insight shown on each session completion
- Insight selection weighted toward current pattern (70/30 split)
- Never shows same insight twice in a row
- "DID YOU KNOW?" header in teal (not dim)
- Insight card has subtle teal left border and light teal background
- Text uses warm brown color with generous line spacing
- Integrates seamlessly with the session completion screen from Feature 6
- No performance issues with insight selection

**Priority:** 7
**Dependencies:** 6

---

### 8. Smart Pattern Recommendations — Time-of-Day Suggestions

**User Story:** As a user, I want the app to suggest the most appropriate breathing pattern based on the time of day — so I don't have to think about which pattern to use and can just start breathing.

**Description:** Add a recommendation system that suggests patterns based on the current time. Recommendations appear as a suggested card on the Today tab and as a subtle badge on the Breathe tab's pattern selector.

**Recommendation Logic (pure function, no external dependencies):**

```
Time-Based Pattern Selection:
- 05:00 - 08:59 (Early Morning): Resonance
  Reason: "Morning baseline — synchronise your HRV for the day"
- 09:00 - 11:59 (Morning): Box Breathing
  Reason: "Focus and clarity for deep work"
- 12:00 - 13:59 (Midday): Physiological Sigh
  Reason: "Quick reset after the morning push"
- 14:00 - 16:59 (Afternoon): Resonance
  Reason: "Sustained calm focus for the afternoon"
- 17:00 - 19:59 (Evening): Coherent
  Reason: "Wind-down — ease out of work mode"
- 20:00 - 22:59 (Night): 4-7-8
  Reason: "Prepare your nervous system for sleep"
- 23:00 - 04:59 (Late Night): 4-7-8
  Reason: "Calm your mind for rest"
```

**Duration Suggestion:**
- Before 12:00: suggest 5 min ("Quick morning session")
- 12:00-17:00: suggest 5 min ("Midday reset")
- After 17:00: suggest 10 min ("Evening wind-down")

**Today Tab — Suggested Pattern Card (new section):**
- Add as the FIRST section after the greeting, before streak/week grid
- "SUGGESTED FOR YOU" section header (11pt uppercase tracked dim)
- Card with light teal background (teal at 8% opacity), teal border at 12% opacity, 8pt corner radius
- Inside card:
  - "Right now" in 10pt uppercase tracked teal text
  - Pattern name in 18pt serif bold, teal color
  - Reason text in 12pt mid text (from the logic above)
  - Duration: "5 min" in 11pt teal bold, right-aligned
- Tapping the card: switches to Breathe tab with the suggested pattern and duration pre-selected
- Card has 16pt padding all around

**Breathe Tab — "Suggested" Badge:**
- On the PatternSelectorBar, the recommended pattern gets a small "Suggested" badge
- Badge: tiny teal pill (9pt bold white text on teal background), positioned above the pattern chip
- Badge disappears once the user manually selects a different pattern (reset on each tab visit)

**Pre-selection:**
- When opening the Breathe tab fresh (no active session), default-select the recommended pattern
- If user has previously selected a pattern in this session, keep their choice

**New Files to Create:**
- `Sources/SocraticJournal/Domain/Services/PatternRecommendationService.swift` — Pure function/struct that returns (patternId, reason, suggestedDuration) based on current hour
- `Sources/SocraticJournal/Presentation/Today/Components/SuggestedPatternCard.swift` — The teal suggestion card

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Today/TodayView.swift` — Add SUGGESTED section at top of ScrollView
- `Sources/SocraticJournal/Presentation/Today/TodayViewModel.swift` — Call recommendation service, provide data
- `Sources/SocraticJournal/Presentation/Breathe/Components/PatternSelectorBar.swift` — Add optional "Suggested" badge overlay on recommended chip
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — Default to recommended pattern on fresh load
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` — Support programmatic tab switching when tapping suggestion card (pass binding or use environment)

**Acceptance Criteria:**
- Correct pattern recommended for each time window
- Reason text matches the time-of-day context
- Duration suggestion follows morning/afternoon/evening logic
- Today tab shows suggestion card as first content section
- Tapping suggestion card navigates to Breathe tab with correct pattern + duration
- "Suggested" badge visible on the recommended pattern in Breathe tab selector
- Badge disappears after user manually selects a different pattern
- Pre-selection works: Breathe tab opens with recommended pattern on first visit
- User's manual selection is preserved (recommendation doesn't override)
- Recommendation updates when time changes (e.g., user opens app at 8 AM, then again at 2 PM)
- Design: teal-tinted suggestion card matches editorial aesthetic

**Priority:** 8
**Dependencies:** None

---

### 9. Guided Breathing Programs — Data Model & Program Browser

**User Story:** As a user, I want to browse a catalog of structured multi-day breathing programs — so I can find a guided path that matches my goals and start a program to build my practice systematically.

**Description:** This is the first part of the Programs feature — the data model, repository, and program browser UI. It defines all 4 programs with their day-by-day content and creates the browsing experience. Feature 10 handles program progress tracking and active program integration.

**Program Data Model:**

```swift
struct BreathProgram: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let durationDays: Int
    let difficulty: BreathDifficulty
    let tagColorHex: String
    let iconName: String  // SF Symbol
    let days: [ProgramDay]
}

struct ProgramDay: Identifiable, Codable, Sendable {
    let id: String
    let dayNumber: Int
    let title: String
    let lesson: String
    let patternId: String
    let durationMinutes: Int
    let focusNote: String
}
```

**The 4 Programs (hardcoded as static properties on BreathProgram):**

**Program 1: "7-Day Nasal Breathing Reset"** (Beginner, teal, `nose`, 7 days)
- Subtitle: "Retrain your default breath"
- Description: "Your nose is a miraculous organ — it filters, humidifies, pressurises air and produces nitric oxide. Yet most of us breathe through our mouths. This 7-day reset retrains your default breathing pathway. By the end, nasal breathing will feel natural again."
- Day 1: "The Nose Knows" — coherent, 5 min. Lesson: "Your nose produces nitric oxide, a molecule that dilates blood vessels, fights pathogens, and improves oxygen transfer. Mouth breathing bypasses all of this. Today, simply notice: are you a nose breather or a mouth breather?" Focus: "Breathe only through your nose for the entire session"
- Day 2: "Slow Down" — resonance, 5 min. Lesson: "The average person takes 12-20 breaths per minute. Optimal is closer to 5.5. Today we slow down to resonance pace — the rate that synchronises your heart and lungs." Focus: "Count each breath cycle. Don't rush."
- Day 3: "The Exhale is Everything" — coherent, 10 min. Lesson: "The exhale activates the parasympathetic nervous system — your body's brake pedal. A longer exhale relative to inhale is the fastest way to calm down." Focus: "Make your exhale feel effortless, like a slow deflation"
- Day 4: "Finding Your Rhythm" — resonance, 10 min. Lesson: "By day 4, the 5.5 rhythm should start to feel natural. Your body has a resonance frequency — a pace at which your cardiovascular system operates most efficiently. This is it." Focus: "Close your eyes. Let the haptic taps guide you."
- Day 5: "Hold Your Ground" — box, 5 min. Lesson: "Holds build CO₂ tolerance — the real key to comfortable breathing. When you hold, CO₂ rises, and your body learns that this is safe." Focus: "During holds, relax your throat and jaw completely"
- Day 6: "The Evening Reset" — fourSevenEight, 10 min. Lesson: "Dr. Andrew Weil calls this pattern a 'natural tranquiliser for the nervous system.' The extended hold and exhale are genuinely sedating." Focus: "Practice this lying down if possible"
- Day 7: "Your New Default" — resonance, 10 min. Lesson: "One week of conscious nasal breathing rewires your default. Notice how different your breathing feels compared to day 1." Focus: "This is your daily practice going forward. Come back anytime."

**Program 2: "Stress Resilience — 10 Days"** (Intermediate, coral `#C4502A`, `bolt.heart`, 10 days)
- Subtitle: "Build your stress response toolkit"
- Description: "Stress isn't the problem — your response to it is. This program uses patterns clinically proven to interrupt the stress cycle: Box Breathing for acute stress, Physiological Sighs for panic, and Resonance for long-term resilience."
- Day 1: "The Stress Response" — box, 5 min. Lesson: "When stress hits, your sympathetic nervous system fires: heart rate up, breathing shallow, muscles tense. Box Breathing interrupts this cascade with structured attention." Focus: "Notice your heartbeat during the holds"
- Day 2: "The 30-Second Reset" — physiologicalSigh, 5 min. Lesson: "The physiological sigh is the fastest stress reset known to science. A double inhale pops open collapsed alveoli; the long exhale activates your vagus nerve." Focus: "Double inhale through the nose, long exhale through the mouth"
- Day 3: "Building the Baseline" — resonance, 10 min. Lesson: "Resonance breathing builds long-term resilience. The daily practice raises your baseline HRV, which means your nervous system starts from a calmer place." Focus: "This isn't about today's stress. This is about next month's resilience."
- Day 4: "CO₂ Tolerance" — box, 10 min. Lesson: "The holds in Box Breathing gently raise CO₂. Your chemoreceptors learn to tolerate it. Higher CO₂ tolerance = less anxiety about breathing itself." Focus: "If the hold feels uncomfortable, that's the training working"
- Day 5: "The Emergency Tool" — physiologicalSigh, 5 min. Lesson: "Practice this until it's automatic. When panic strikes at 3 AM or before a presentation, you won't need to think — your body will know what to do." Focus: "Speed matters less than the double-inhale-long-exhale shape"
- Day 6: "Sustained Calm" — resonance, 10 min. Lesson: "At 5.5 BPM for 10 minutes, your HRV enters a sustained coherent state. Brain imaging shows reduced amygdala activity — the fear centre quiets." Focus: "If thoughts arise, label them 'thinking' and return to the breath"
- Day 7: "Under Pressure" — box, 10 min. Lesson: "This is what Navy SEALs do before operations. The demand for attentional control during holds makes it impossible to ruminate." Focus: "Imagine you're about to do something that requires total focus"
- Day 8: "The Quick Draw" — physiologicalSigh, 5 min. Lesson: "By day 8, the sigh should feel like second nature. Test it: think of something stressful, then sigh. Notice how fast the arousal drops." Focus: "Practice the transition from stress to sigh"
- Day 9: "Deep Resilience" — resonance, 15 min. Lesson: "15 minutes at resonance pace. This is the dose that produces measurable changes in HRV over weeks. You're building something lasting." Focus: "This is your longest session yet. Stay with it."
- Day 10: "Your Toolkit" — box, 10 min. Lesson: "You now have three tools: Box for acute focus, Sighs for emergency reset, Resonance for daily maintenance. Use them all." Focus: "Choose which tool fits each situation in your life"

**Program 3: "21-Day Breath Mastery"** (Advanced, coral `#C4502A`, `star.circle`, 21 days)
- Subtitle: "The complete breathing journey"
- Description: "A comprehensive journey through every breathing pattern in the app. From basic nasal breathing to advanced Tummo practice. By day 21, you'll understand your respiratory system deeply and have the practice to prove it."
- Day 1: "Foundation" — coherent, 5 min. Lesson: "We begin with the simplest pattern. Coherent breathing — 6 seconds in, 6 seconds out. Whole numbers, easy counting, powerful effect." Focus: "Just breathe. No expectations."
- Day 2: "The Resonance Point" — resonance, 5 min. Lesson: "5.5 BPM is your cardiovascular resonance frequency. Today we find it." Focus: "Notice how your chest and belly move together"
- Day 3: "Extending" — coherent, 10 min. Lesson: "Doubling the duration. Your body is already adapting to slower breathing." Focus: "If your mind wanders, gently return"
- Day 4: "The Structure of Stress Control" — box, 5 min. Lesson: "Introducing holds. The 4-4-4-4 pattern adds a new dimension — CO₂ tolerance." Focus: "Holds should feel firm but not forced"
- Day 5: "Deepening the Hold" — box, 10 min. Lesson: "10 minutes of Box Breathing builds real CO₂ tolerance." Focus: "Relax your face and jaw during holds"
- Day 6: "The Box at Length" — box, 10 min. Lesson: "Repetition is the mechanism. Your chemoreceptors are recalibrating." Focus: "Find ease within the structure"
- Day 7: "The Sedating Breath" — fourSevenEight, 5 min. Lesson: "The longest exhale in our repertoire. Genuinely sedating." Focus: "Practice in the evening for best effect"
- Day 8: "Going Deeper" — fourSevenEight, 10 min. Lesson: "The 7-second hold pressurises oxygen into your bloodstream." Focus: "If you feel drowsy, that's the pattern working"
- Day 9: "Parasympathetic Flooding" — fourSevenEight, 10 min. Lesson: "Three days of 4-7-8 rewires your evening nervous system." Focus: "Let gravity hold your body"
- Day 10: "The Emergency Sigh" — physiologicalSigh, 5 min. Lesson: "The fastest arousal reset — one pattern, 30 seconds." Focus: "Double inhale, long exhale. Simple and powerful."
- Day 11: "Sighs on Demand" — physiologicalSigh, 5 min. Lesson: "Practice until it's reflexive. Your body should sigh before your mind decides to." Focus: "Speed of deployment matters"
- Day 12: "Combining Tools" — resonance, 10 min. Lesson: "Return to resonance after learning sighs. Notice how much easier it feels now." Focus: "Your baseline has shifted"
- Day 13: "The Buteyko Insight" — buteykoReduced, 5 min. Lesson: "Less is more. Buteyko's radical idea: you breathe too much." Focus: "Take the smallest breaths you can while staying comfortable"
- Day 14: "Reduced Breathing" — buteykoReduced, 10 min. Lesson: "Your CO₂ tolerance is now high enough for this. Embrace the air hunger gently." Focus: "The urge to breathe more is just a signal, not a command"
- Day 15: "The Patience of Less" — buteykoReduced, 10 min. Lesson: "Three days of reduced breathing resets your chemoreceptor set point." Focus: "Breathe as if through a thin straw"
- Day 16: "Nostril Awareness" — alternateNostril, 5 min. Lesson: "Which nostril is dominant right now? You're about to take manual control." Focus: "Use your right thumb and ring finger"
- Day 17: "Bilateral Balance" — alternateNostril, 10 min. Lesson: "Left nostril: calm. Right nostril: alert. Alternating: balanced." Focus: "Feel the shift in hemispheric activation"
- Day 18: "The Ancient Practice" — alternateNostril, 10 min. Lesson: "Nadi Shodhana has been practiced for 3,000 years. The neuroscience now confirms what yogis always knew." Focus: "Let each nostril have its full cycle"
- Day 19: "Power Breathing" — tummo, 5 min. Lesson: "Advanced territory. Rapid breathing depletes CO₂ and triggers adrenaline. Never in water. Never while driving." Focus: "30 rapid breaths, then hold. Feel the rush."
- Day 20: "The Wim Hof Round" — tummo, 10 min. Lesson: "Multiple rounds of power breathing. The alkaline blood shift, the adrenaline, the rebound. This is real." Focus: "Listen to your body. Stop if dizzy."
- Day 21: "Your Practice" — resonance, 20 min. Lesson: "The final day. 20 minutes of resonance — your foundation pattern. You now know all 8 patterns and when to use each one." Focus: "This is who you are now. A breather."

**Program 4: "Evening Wind-Down — 7 Days"** (Beginner, purple `#6B4C8A`, `moon.stars`, 7 days)
- Subtitle: "Calm your nervous system before sleep"
- Description: "Poor sleep often starts with an overactive nervous system. This 7-day program uses evening breathing patterns to activate your parasympathetic system, lower your heart rate, and prepare your body for rest."
- Day 1: "The Evening Breath" — fourSevenEight, 5 min. Lesson: "Tonight, we begin the wind-down. The 4-7-8 pattern is designed to be sedating." Focus: "Practice 30 minutes before your intended sleep time"
- Day 2: "Slow and Steady" — coherent, 5 min. Lesson: "Coherent breathing lowers resting heart rate over time. Lower heart rate = easier sleep onset." Focus: "Focus on making each breath exactly the same length"
- Day 3: "The Long Exhale" — fourSevenEight, 10 min. Lesson: "The 8-second exhale activates your vagus nerve more than any other phase ratio." Focus: "If you fall asleep during the session, that's success"
- Day 4: "Relief" — physiologicalSigh, 5 min. Lesson: "When anxious thoughts spike before bed, sighs break the cycle in 30 seconds." Focus: "Double inhale through the nose, long exhale through the mouth"
- Day 5: "Coherent Calm" — coherent, 10 min. Lesson: "Stephen Elliott's research shows coherent breathing measurably lowers resting heart rate." Focus: "Make each breath a mirror image of the last"
- Day 6: "The Ritual" — fourSevenEight, 10 min. Lesson: "Rituals signal transitions. Your brain is learning: this breathing pattern → sleep follows." Focus: "Same time, same place, same pattern"
- Day 7: "Your Evening Practice" — fourSevenEight, 10 min. Lesson: "Seven days of evening practice. You now have a drug-free, side-effect-free tool for better sleep." Focus: "This is yours forever. No subscription required."

**Program Browser View:**
- Presented as a sheet (`.sheet`) from the Today tab
- Header: "Programs" in 22pt serif bold
- Subtitle: "Structured paths to better breathing" in 12pt mid text
- Hairline border below header
- Vertical list of 4 program cards:
  - Each card:
    - Tag badge: colored pill using program's difficulty (Beginner/Intermediate/Advanced) and program's tagColorHex
    - Title in 15pt serif bold, dark text
    - Subtitle in 12pt mid text
    - Bottom row: duration in 11pt dim (e.g., "7 days") + difficulty in 11pt dim (e.g., "Beginner")
    - Hairline border below card
    - Right chevron indicator (SF Symbol `chevron.right`, dim)
  - Tapping a card navigates to ProgramDetailView (pushed in NavigationStack inside the sheet)

**Program Detail View (NavigationStack push inside sheet):**
- Back button in navigation bar
- Header: program title in 22pt serif bold
- Tag + duration + difficulty row below title
- Description paragraph in 13pt body, warm brown, line-height 1.75
- Hairline border below description
- "BEGIN PROGRAM" button (teal filled pill, 12pt uppercase tracked serif) — only visible if program not yet started
- Below: "DAILY SCHEDULE" section header
- Day-by-day list (ScrollView):
  - Each day row:
    - Left: circle indicator (24pt)
      - Future/not started: warm gray border, no fill
    - Day number + title: "Day 1: The Nose Knows" in 13pt serif bold
    - Pattern + duration: "Coherent · 5 min" in 11pt mid text
    - Hairline divider between rows
  - Rows are informational only at this stage (progress tracking in Feature 10)

**Navigation from Today Tab:**
- Add a "Browse Programs" text button (teal, 11pt uppercase tracked) in Today tab
- Position: after the daily goal progress section (and after "See Progress" link from Feature 1)
- Tapping presents the program browser as a sheet

**New Files to Create:**
- `Sources/SocraticJournal/Domain/Entities/BreathProgram.swift` — BreathProgram and ProgramDay models with static `allPrograms` array containing all 4 programs
- `Sources/SocraticJournal/Presentation/Programs/ProgramBrowserView.swift` — Sheet with program list
- `Sources/SocraticJournal/Presentation/Programs/ProgramBrowserViewModel.swift` — Simple VM loading static programs
- `Sources/SocraticJournal/Presentation/Programs/ProgramDetailView.swift` — Program detail with day list
- `Sources/SocraticJournal/Presentation/Programs/Components/ProgramCard.swift` — Single program card in browser

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Today/TodayView.swift` — Add "Browse Programs" link, add `.sheet` for ProgramBrowserView

**Acceptance Criteria:**
- All 4 programs defined with complete day-by-day content (7+10+21+7 = 45 total days of content)
- BreathProgram.allPrograms returns all 4 programs
- "Browse Programs" link visible on Today tab
- Tapping opens program browser sheet
- Browser shows all 4 programs with correct tags, titles, subtitles, durations, difficulties
- Tapping a program navigates to detail view
- Detail view shows program description and all days listed
- "BEGIN PROGRAM" button visible (functionality in Feature 10)
- Day list shows day numbers, titles, pattern names, and durations
- Back navigation works within the sheet
- Design follows editorial aesthetic (serif headings, hairline borders)
- Sheet dismissal works correctly (swipe down)

**Priority:** 9
**Dependencies:** None

---

### 10. Guided Breathing Programs — Progress Tracking & Active Program

**User Story:** As a user, I want to start a program, track my daily progress through it, and see my active program on the Today dashboard — so I have a structured path that guides my practice day by day.

**Description:** This feature adds progress tracking to the programs from Feature 9. Users can start a program, complete days by doing sessions, see their progress in the program detail, and see their active program on the Today tab.

**Progress Data Model:**

```swift
struct ProgramProgress: Identifiable, Codable, Sendable {
    let id: String              // UUID
    let programId: String       // References BreathProgram.id
    let startedAt: Date
    var completedDays: Set<Int> // Day numbers that have been completed (1-indexed)
    var lastCompletedAt: Date?
    let totalDays: Int
    var isCompleted: Bool { completedDays.count >= totalDays }
    var currentDay: Int {       // Next uncompleted day
        for day in 1...totalDays {
            if !completedDays.contains(day) { return day }
        }
        return totalDays
    }
}
```

**Repository:**
```swift
protocol ProgramRepositoryProtocol: Sendable {
    func getActiveProgram() async throws -> ProgramProgress?
    func startProgram(_ programId: String, totalDays: Int) async throws -> ProgramProgress
    func completeDay(_ dayNumber: Int, for programId: String) async throws
    func getProgress(for programId: String) async throws -> ProgramProgress?
    func getAllCompletedPrograms() async throws -> [ProgramProgress]
}
```
- Implement with UserDefaults (key: `"com.breathe.programProgress"`)
- Only ONE active program at a time

**"BEGIN PROGRAM" Flow:**
- Tapping "BEGIN PROGRAM" in ProgramDetailView:
  - If no active program: create ProgramProgress, dismiss sheet, show confirmation toast
  - If different program is active: show alert "You have an active program ([name]). Starting a new one will replace it. Continue?" with "Replace" (destructive) and "Cancel" buttons
  - After starting: Today tab shows active program section

**Day Completion Logic:**
- A day is marked complete when the user finishes a session matching the day's prescribed pattern
- Check happens in BreatheViewModel after saving a session:
  1. Get active program progress
  2. Get the current day's prescribed pattern
  3. If just-completed session's patternId matches the current day's patternId → mark day complete
  4. Duration doesn't need to match exactly (any session with the right pattern counts)
- Day completion is automatic — no explicit "mark as done" button

**Program Detail View Updates (modify from Feature 9):**
- Day circle indicators update based on progress:
  - Completed day: teal filled circle with white checkmark (SF Symbol `checkmark`)
  - Current day (next uncompleted): pulsing teal border ring (animating opacity 0.3→1.0, repeating)
  - Future day: warm gray border, no fill
- Tapping the current day opens a Day Detail sub-view:
  - Day number + title in 18pt serif bold
  - Lesson text in 13pt body, warm brown, line height 1.75
  - Focus note in italic 13pt teal, inside a light teal card (8% teal bg, teal border at 12%)
  - "Start Session" button (teal filled pill) → dismiss sheet, switch to Breathe tab with pattern + duration pre-selected
- Tapping a completed day shows the same detail (read-only, no start button, "Completed" badge)
- Tapping a future day shows the detail but with "Locked" badge and dimmed start button

**"BEGIN PROGRAM" Button State:**
- Not started: "BEGIN PROGRAM" (teal filled pill)
- Active (in progress): "CONTINUE — DAY X" (teal filled pill)
- Completed: "COMPLETED" (teal outlined pill with checkmark) + "Restart" text button below

**Today Tab — Active Program Section:**
- New section after SUGGESTED pattern card (Feature 8) and before streak/week grid
- "ACTIVE PROGRAM" section header (11pt uppercase tracked dim)
- Card with paper background, warm border, 8pt corner radius:
  - Program title in 15pt serif bold
  - Progress bar: teal fill, warm gray track, 4pt height, rounded caps, width = completedDays/totalDays
  - "Day X of Y" in 11pt mid text (X = current uncompleted day, Y = total)
  - "Today: [Day Title]" in 13pt serif semibold (e.g., "Today: Hold Your Ground")
  - Right chevron (dim)
- Tapping opens program detail (as sheet)
- If no active program: section not visible (hide entirely, no empty state)

**Program Completion:**
- When all days completed, show a simple completion card in ProgramDetailView:
  - "Program Complete" in 22pt serif bold, teal
  - Checkmark animation (same as session complete)
  - "You completed [program name] in X days" in 13pt mid text
  - "Browse More Programs" text button (teal)

**New Files to Create:**
- `Sources/SocraticJournal/Domain/Entities/ProgramProgress.swift` — Progress model
- `Sources/SocraticJournal/Domain/Repositories/ProgramRepositoryProtocol.swift`
- `Sources/SocraticJournal/Data/Repositories/UserDefaultsProgramRepository.swift`
- `Sources/SocraticJournal/Presentation/Programs/ProgramDetailViewModel.swift` — Progress state, day completion, start/restart logic
- `Sources/SocraticJournal/Presentation/Programs/Components/ProgramDayRow.swift` — Day row with progress indicator
- `Sources/SocraticJournal/Presentation/Programs/Components/DayDetailView.swift` — Day detail with lesson + start button
- `Sources/SocraticJournal/Presentation/Programs/Components/ActiveProgramSection.swift` — Today tab section

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Programs/ProgramDetailView.swift` — Add progress indicators, day tapping, completion state
- `Sources/SocraticJournal/Presentation/Today/TodayView.swift` — Add active program section
- `Sources/SocraticJournal/Presentation/Today/TodayViewModel.swift` — Load active program progress
- `Sources/SocraticJournal/Presentation/Breathe/BreatheViewModel.swift` — After session save, check for program day completion
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` — Support tab switching from program day "Start Session"

**Acceptance Criteria:**
- "BEGIN PROGRAM" creates progress record and only 1 active program at a time
- Starting a new program when one is active shows replacement confirmation
- Day completion triggers automatically when matching pattern session is saved
- Program detail shows correct progress (completed/current/future indicators)
- Current day has pulsing animation
- Tapping current day opens day detail with lesson and "Start Session"
- "Start Session" dismisses sheet and opens Breathe tab with correct pattern + duration
- Today tab shows active program card with progress bar
- Tapping active program card opens program detail
- Program completion shows celebration card
- Progress persists across app launches
- No active program = section hidden on Today tab
- "CONTINUE — DAY X" replaces "BEGIN PROGRAM" for in-progress programs
- Design follows editorial aesthetic throughout

**Priority:** 10
**Dependencies:** 9

---

### 11. Enhanced Onboarding — Quick Assessment & Personalized Start

**User Story:** As a new user, I want the onboarding to optionally assess my breathing habits and personalize my starting pattern — so the app feels tailored to me from day one instead of generic.

**Description:** Extend the existing 3-page onboarding with 2 additional pages: a quick self-assessment (3 questions) and a personalized recommendation. This makes onboarding interactive and increases the chance of a meaningful first session.

**Updated Onboarding Flow (5 pages):**

**Pages 1-3:** Keep EXACTLY as they are (Breathe Better, Ancient Wisdom Modern Science, Just 5 Minutes)

**Page 3 Modification:** Change "Get Started" button to "Continue" text, and it advances to page 4 instead of dismissing. Remove the `hasCompletedOnboarding = true` from this button.

**Page 4 — "How Do You Breathe?" (NEW):**
- Cream background (consistent with pages 1-2)
- "How do you breathe?" in 28pt serif bold, dark
- Three questions appear sequentially (each slides up after the previous is answered):

  **Q1: "Your usual breathing:"**
  - Three tappable option cards, vertical stack, 12pt spacing:
    - "Through my nose" — SF Symbol `nose`, teal left border (4pt)
    - "Through my mouth" — SF Symbol `mouth`, coral left border
    - "I'm not sure" — SF Symbol `questionmark.circle`, warm border
  - Each card: paper background, 8pt corner radius, 16pt padding, 13pt serif bold label
  - Tapping highlights the card (teal border + light teal background) and reveals Q2

  **Q2: "Your main goal:"**
  - Four tappable option cards:
    - "Less stress" — SF Symbol `heart`, coral left border
    - "Better sleep" — SF Symbol `moon.stars`, purple left border
    - "General wellness" — SF Symbol `leaf`, teal left border
    - "Focus & performance" — SF Symbol `brain.head.profile`, brown left border
  - Same card style as Q1

  **Q3: "Your experience:"**
  - Three tappable option cards:
    - "Practice regularly" — teal left border
    - "Tried a few times" — warm border
    - "Complete beginner" — warm border

- "Skip" text button at bottom center (11pt dim) — skips to page 5 with default recommendation
- No "back" or "next" buttons — answering all 3 questions auto-advances to page 5 after a 0.5s delay

**Page 5 — "Your Starting Point" (NEW):**
- Teal background (`#2D5F5D`) — consistent with old page 3
- "Your Starting Point" in 34pt serif bold, white text
- Personalized recommendation card (white background, 12pt corner radius, centered, 24pt padding):
  - Pattern name in 18pt serif bold, teal
  - Pattern timing below in 13pt mid text (e.g., "5.5 · 5.5")
  - Reason: "Based on your goal: [goal text]" in 12pt mid text
  - "Start with 5 minutes" in 12pt teal
- Recommendation logic (simple mapping):
  - Stress goal → Box Breathing ("Structured breathing for stress control")
  - Sleep goal → 4-7-8 ("The natural tranquiliser for sleep")
  - Wellness goal → Resonance ("The perfect daily breath")
  - Focus goal → Box Breathing ("Navy SEAL focus technique")
  - Experienced user (regardless of goal) → Resonance at 10 min instead of 5
  - Complete beginner + any goal → Coherent ("The gentlest starting point")
- "Begin Your Journey" button (white filled pill, teal text)
- Tapping: sets `hasCompletedOnboarding = true`, saves recommended pattern ID to UserSettings, dismisses onboarding, opens app to Breathe tab with recommended pattern pre-selected

**Page Indicator:** 5 dots (teal on cream pages 1-2-4, white on teal pages 3-5)

**Data (NOT persisted beyond generating recommendation):**
```swift
struct OnboardingAssessment {
    var breathingStyle: BreathingStyle? // nose, mouth, unsure
    var mainGoal: BreathingGoal?        // stress, sleep, wellness, focus
    var experience: ExperienceLevel?     // regular, occasional, beginner
}
```

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — Add pages 4-5, update page count, update page indicator, modify page 3 button

**New Files to Create:**
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingAssessmentPage.swift` — Page 4 with 3 questions
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingRecommendationPage.swift` — Page 5 with personalized result
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingAssessmentData.swift` — Assessment enums and recommendation logic

**Acceptance Criteria:**
- Existing pages 1-3 visually unchanged (no regression)
- Page 3 "Get Started" changed to "Continue" and advances to page 4
- Page 4 shows 3 questions that appear sequentially with slide-up animation
- Each question has tappable card options with visual selection feedback
- Answering all 3 auto-advances to page 5 after brief delay
- "Skip" on page 4 goes to page 5 with default recommendation (Resonance, 5 min)
- Page 5 shows correct recommendation based on answers
- Recommendation logic covers all answer combinations
- "Begin Your Journey" marks onboarding complete and opens Breathe tab
- Page indicator shows 5 dots with correct color adaptation (teal on cream, white on teal)
- Swiping between pages works smoothly
- Works in both light and dark mode
- Returning users still skip onboarding (existing behavior preserved)

**Priority:** 11
**Dependencies:** None

---

### 12. Dark Mode Polish — Intentional Dark Theme

**User Story:** As a user, I want the app to look stunning in dark mode — with proper contrast, warm tones, and maintained readability — not just auto-inverted colors.

**Description:** While the app has basic dark mode via ThemeManager, this feature ensures every component is intentionally designed for dark mode with warm dark backgrounds (not cool grays), properly contrasted accents, and verified readability.

**Dark Mode Color Specifications:**
- Background main: `#0A0A0A` (existing, keep)
- Surface/Paper: `#1A1816` (warm dark brown, not pure gray)
- Card backgrounds: `#1E1C18` (slightly lighter warm dark)
- Text Primary: `#F5F0E8` (warm off-white, not pure white)
- Text Secondary: `#A89E90` (warm mid-tone)
- Text Tertiary: `#6B6258` (warm dim)
- Borders/Hairlines: `#2E2A24` (subtle warm dark)
- Teal accent: `#3A7A77` (slightly brighter for dark mode contrast)
- Coral accent: `#E06840` (slightly brighter for dark mode)
- Tag backgrounds: 15% opacity (instead of 8% in light mode)
- Mountain wave ghost outline: `#2E2A24`
- GeometricRing track: `#2E2A24`
- Selected pattern chip background: teal at 20% opacity (instead of 10%)

**Implementation Approach:**
- Update `AppColors.swift` to use `Color(uiColor: UIColor { traitCollection in ... })` or `Color(light:dark:)` for each color that needs adaptation
- OR use Asset Catalog color sets with light/dark variants
- Each color in AppColors should have explicit dark mode variant

**Screens to Audit & Fix (every single view file):**
1. **MainTabView** — Tab bar background, active/inactive colors, dot indicator
2. **TodayView** — Greeting, streak, week grid cells, practice checklist, suggested card, active program card
3. **BreatheView** — Pattern chips (selected/unselected), wave background, phase labels, duration chips, begin/pause buttons
4. **BreathWaveView** — Ghost outline, live path, baseline, phase colors on dark background
5. **LearnView** — Quick fact cards, article cards, tag badges, expanded body text, category filter chips
6. **SettingsView** — Section headers, toggles, pickers, about section
7. **NewOnboardingView** — Pages 1-2-4 need dark backgrounds (not cream), pages 3-5 teal stays
8. **ProgressView** — Bar chart, heatmap cells, pattern breakdown bars, milestone cards
9. **SessionCompleteView** — Overlay background, checkmark, stats, insight card
10. **ProgramBrowserView / ProgramDetailView** — Program cards, day rows, progress indicators

**Specific Component Fixes:**
- `HairlineDivider` in AppShapes: use adaptive border color (`#D8D0C4` light → `#2E2A24` dark)
- `SectionHeaderView`: use adaptive dim text color
- `AccentPillButton`: ensure teal button readable on dark backgrounds
- `StatCard`: use dark card background in dark mode
- `GeometricRing`: track color adaptive
- Pattern chip selected state: teal bg at 20% on dark (10% is too subtle)
- Week grid cells: dark background with visible borders
- Heatmap cells: teal intensities still distinguishable on dark

**Files to Modify:**
- `Sources/SocraticJournal/Presentation/Theme/AppColors.swift` — Primary file: add dark mode variants for every color
- `Sources/SocraticJournal/Presentation/Theme/AppShapes.swift` — Update HairlineDivider, StatCard, GeometricRing to use adaptive colors
- Every View file listed above — audit for hardcoded color values, replace with AppColors references
- `Sources/SocraticJournal/Presentation/Theme/ThemeManager.swift` — Verify theme switching handles all adaptive colors

**Acceptance Criteria:**
- Every screen intentionally designed for dark mode (not just auto-inverted)
- No white flash on any screen transition in dark mode
- All hairline borders visible but subtle on dark backgrounds
- Teal and coral accents have sufficient contrast (visible and readable)
- Mountain wave animation clearly visible in dark mode
- GeometricRing progress ring visible in dark mode
- Pattern selector chips clearly distinguishable (selected vs unselected) in dark mode
- Article tag badges readable in dark mode (slightly higher opacity)
- Week grid cells, heatmap cells clearly distinguishable
- Quick fact cards readable
- No hardcoded color values remaining in any View file (all use AppColors)
- Settings toggles and section headers visible
- Onboarding dark pages use warm dark background (not cream)
- Milestone cards (locked vs unlocked) clearly distinguishable in dark mode
- Test by setting system theme to dark and reviewing every screen

**Priority:** 12
**Dependencies:** 1, 6, 9

---

### 13. Verify & Fix All Unit Tests

**User Story:** As a developer, I need to ensure all existing unit tests pass and add basic test coverage for the new repository methods and key business logic — so the codebase remains stable and regressions are caught.

**Description:** Run all existing unit tests, fix any failures, and add tests for the new functionality added in Features 1-12. Focus on repository methods, recommendation logic, milestone checking, and program progress — pure logic that's easy to test without UI dependencies.

**Test Verification Steps:**
1. Run all existing tests: `xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`
2. Fix any failing tests (may be broken by Feature 1-12 changes)
3. Add new tests for critical logic

**New Tests to Add:**

**BreathSessionRepositoryTests:**
- Test `saveSession` and `getSessionsForDate` — save a session, retrieve for that date
- Test `getTotalMinutes` — save multiple sessions, verify sum
- Test `getTotalSessions` — verify count
- Test `getStreak` — save sessions for consecutive days, verify streak count
- Test `getLongestStreak` — verify longest run calculation
- Test `getSessionsByPattern` — verify grouping
- Test `getSessionsForMonth` — verify month filtering
- Test edge case: no sessions returns zero/empty

**PatternRecommendationServiceTests:**
- Test each time window returns correct pattern
- Test morning (6 AM) → Resonance
- Test midday (12 PM) → Physiological Sigh
- Test evening (8 PM) → 4-7-8
- Test late night (11 PM) → 4-7-8
- Test duration suggestions match time of day

**MilestoneTests:**
- Test "First Breath" unlocks after 1 session
- Test "Pattern Explorer" requires all 8 patterns
- Test "Marathon" requires 20+ minute session
- Test "Century" requires 100+ total minutes
- Test "Breath Master" requires all other milestones
- Test milestones stay unlocked once achieved

**ProgramProgressTests:**
- Test `currentDay` returns first uncompleted day
- Test `isCompleted` when all days done
- Test completing days out of order
- Test starting a new program resets progress

**OnboardingRecommendationTests:**
- Test stress goal → Box Breathing
- Test sleep goal → 4-7-8
- Test wellness goal → Resonance
- Test beginner + any goal → Coherent
- Test experienced user gets 10 min suggestion

**Test File Organization:**
- Place tests in `Tests/SocraticJournalTests/` directory
- One test file per component being tested
- Use XCTest framework
- Mock repository implementations for isolated testing

**New Files to Create:**
- `Tests/SocraticJournalTests/Repositories/BreathSessionRepositoryTests.swift`
- `Tests/SocraticJournalTests/Services/PatternRecommendationServiceTests.swift`
- `Tests/SocraticJournalTests/Domain/MilestoneTests.swift`
- `Tests/SocraticJournalTests/Domain/ProgramProgressTests.swift`
- `Tests/SocraticJournalTests/Onboarding/OnboardingRecommendationTests.swift`

**Files to Potentially Modify:**
- `project.yml` — Ensure test target is configured, add new test files
- Any source files with test-breaking changes from Features 1-12

**Acceptance Criteria:**
- All existing tests pass (zero failures)
- New repository tests cover save/retrieve/calculate operations
- Recommendation service tests cover all time windows
- Milestone tests verify all 10 unlock conditions
- Program progress tests verify state transitions
- Onboarding recommendation tests cover all answer combinations
- Tests run successfully via xcodebuild
- No flaky tests (all deterministic, no timing dependencies)
- Test naming follows pattern: `test_MethodName_Condition_ExpectedResult`

**Priority:** 13
**Dependencies:** 1, 3, 8, 9, 10, 11
