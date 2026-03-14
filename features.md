---
base_branch: master
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal
deep_quality: true
---

# Feature Queue: CO2 Tolerance & Breath-Hold Science

> Expands Next Breath with a dedicated CO2 Tolerance Training section featuring freediver-inspired exercises, and deepens the Learn tab with breath-hold science content. New training exercises draw from Buteyko, competitive freediving CO2/O2 tables, and altitude simulation protocols. New science articles cover the physiology of breath holding, the mammalian dive reflex, full-lungs vs empty-lungs holds, and the Bajau spleen adaptation. Same design language: warm cream editorial with teal accent, serif headings, hairline grids.

---

### 1. Add "High Altitude Breath Hold" Training Exercise

**User Story:** As a user who tried the high-altitude breathing technique (4s inhale, 2s hold, exhale, then 30s hold), I want a guided training exercise in the app that walks me through this protocol round by round so I can safely build CO2 tolerance with structured guidance.

**Description:** Add a new training exercise to `TrainingData.swift` called "High Altitude Hold". This simulates the hypoxic-hypercapnic conditions of high altitude (4,000-5,000m). The protocol: 4s nasal inhale, 2s hold, slow exhale, then hold after exhale for as long as comfortable (tap to stop). Run 5 rounds with 15s recovery breathing between rounds. Track hold times per round and show progression in the result step.

**Acceptance Criteria:**
- New `TrainingData.Exercise` with id `"altitude_hold"`, icon `"mountain.2"`, duration `"6 min"`
- 5 rounds, each round has: instruction -> 4s inhale countdown -> 2s hold countdown -> exhale instruction -> timerCountUp exhale-hold (tap to stop, max 90s) -> 15s recovery countdown
- Result step shows all 5 hold times and average
- Exercise appears in `allExercises` array after existing exercises
- Description references altitude simulation and CO2/O2 dual training stimulus

**Priority:** 1
**Dependencies:** None

---

### 2. Add "CO2 Table" Freediver Training Exercise

**User Story:** As a user interested in freediving-style breath training, I want a CO2 table exercise where I do fixed-length breath holds with progressively shorter rest periods, so I can systematically desensitize my chemoreceptors to rising CO2.

**Description:** Add a "CO2 Table" training exercise to `TrainingData.swift`. This is the classic freediving protocol: 8 rounds of a fixed breath hold (user's comfortable hold, estimated at 50% of max — we use 20s as a safe default) with rest periods that decrease by 5s each round (from 40s down to 5s). The shrinking rest means CO2 accumulates across the session.

**Acceptance Criteria:**
- New `TrainingData.Exercise` with id `"co2_table"`, icon `"chart.bar.decrease"` (or similar SF Symbol), duration `"7 min"`
- 8 rounds: each round has recovery countdown (40s, 35s, 30s, 25s, 20s, 15s, 10s, 5s) -> instruction "Take a normal breath in and out" -> timerCountdown hold (20s, with showPanicButton: true)
- After round 8, ratingScale asking "How did the last round feel?" (1-5, "Desperate" to "Comfortable")
- Result step summarizing completion
- Description explains this is a freediver CO2 desensitization protocol and references the shrinking rest mechanism
- Safety instruction step at the beginning: "Stop immediately if you feel dizzy, see spots, or feel tingling. Never practice in water."

**Priority:** 2
**Dependencies:** None

---

### 3. Add "Breath-Hold Walk" Training Exercise

**User Story:** As a user building CO2 tolerance, I want a walking breath-hold exercise from the Oxygen Advantage method, so I can train CO2 tolerance during light movement — which is more effective than resting holds alone.

**Description:** Add a "Breath-Hold Walk" exercise. This is Patrick McKeown's signature exercise from the Oxygen Advantage: after a gentle exhale, hold your breath and walk, counting steps. 6 rounds with progressive targets. Uses `tapCounter` step type to count steps during each hold.

**Acceptance Criteria:**
- New `TrainingData.Exercise` with id `"breathhold_walk"`, icon `"figure.walk"`, duration `"8 min"`
- Opening instruction: "You'll hold your breath after a gentle exhale and walk, counting your steps. Start easy — your goal is to add a few steps each round."
- 6 rounds: instruction "Breathe normally for 30s" -> timerCountdown 30s recovery -> instruction "Gentle breath in... and out. Pinch your nose." -> tapCounter "Walk and tap each step — stop when you need to breathe" (max 60s) -> instruction "Resume gentle nasal breathing"
- Result step shows step counts per round
- Description references Oxygen Advantage and explains why movement + holds is superior to static holds for BOLT improvement

**Priority:** 3
**Dependencies:** None

---

### 4. Add "Apnea Pyramid" Training Exercise

**User Story:** As an intermediate user, I want a pyramid-style breath-hold exercise where holds gradually increase then decrease, so I can push my limits in the middle rounds while having the psychological comfort of easier rounds at the end.

**Description:** Add an "Apnea Pyramid" exercise inspired by freediving dry static training. The pyramid goes: 10s, 15s, 20s, 25s, 30s, 25s, 20s, 15s, 10s holds with 20s recovery between each. The ascending half builds confidence; the peak challenges the limit; the descending half provides relief.

**Acceptance Criteria:**
- New `TrainingData.Exercise` with id `"apnea_pyramid"`, icon `"triangle"`, duration `"8 min"`
- 9 rounds with hold durations [10, 15, 20, 25, 30, 25, 20, 15, 10] seconds
- Each round: 20s recovery countdown -> instruction "Normal breath in... and out" -> timerCountdown hold (with showPanicButton: true for rounds with holds >= 25s)
- Instruction at start: "A pyramid of breath holds — building up, then easing down. All holds are after a normal exhale."
- Result step showing completion and which rounds triggered the panic button (if any)
- Description explains the pyramid concept and its psychological benefit for breath-hold training

**Priority:** 4
**Dependencies:** None

---

### 5. Organize Training Exercises into Sections (Basics + CO2 Tolerance)

**User Story:** As a user, I want the training exercises organized into clear sections so I can find beginner exercises separately from advanced CO2 tolerance drills.

**Description:** Refactor `TrainingData` to group exercises into sections. The existing 4 exercises go under "Basics" and the new CO2 tolerance exercises (Features 1-4) go under "CO2 Tolerance Training". Update `TrainingGrid` in the Learn tab to display section headers.

**Acceptance Criteria:**
- New `TrainingData.Section` struct with `id`, `title`, `subtitle`, `exercises` properties
- Two sections: "Basics" (existing 4 exercises) and "CO2 Tolerance" (new 4 exercises from Features 1-4)
- `TrainingData.allSections: [Section]` replaces or supplements `allExercises`
- `allExercises` computed property still works (flatMap of all sections' exercises) for backward compatibility
- `TrainingGrid.swift` updated to show section headers with editorial styling (serif font, teal divider)
- CO2 Tolerance section has subtitle: "Freediver-inspired protocols for chemoreceptor training"
- Basics section has subtitle: "Foundation exercises for better breathing"

**Priority:** 5
**Dependencies:** 1, 2, 3, 4

---

### 6. Add Learn Chapter 5: "The Breath Hold" — Article 1: "Full Lungs vs Empty Lungs"

**User Story:** As a user curious about breath holding, I want to understand whether it's better to hold my breath with full lungs or after exhaling, so I can choose the right technique for my training goals.

**Description:** Add the first article of a new Chapter 5 ("The Breath Hold") to `LearnContent.swift`. This article explains the physiology of full-lung (TLC) vs empty-lung (FRC/RV) breath holds, why each produces different training effects, and when to use which.

**Acceptance Criteria:**
- New Chapter 5 with id `5`, title "Chapter 5 · The Breath Hold", subtitle "The science of not breathing"
- Article id `12`, title "Full lungs or empty?\nThe hold that matters.", subtitle "Why the type of breath hold changes everything"
- Tag: "Physiology", tagColorHex: "7A6030", readTime: "5 min"
- Body covers: lung stretch receptors suppressing urge to breathe during full-lung holds, combined hypercapnic-hypoxic stimulus of empty-lung holds, the Bohr Effect connection, why BOLT is measured after passive exhale not full inhale, practical guidelines for when to use each type
- Content is scientifically accurate and references the Bohr Effect article from Chapter 3

**Priority:** 6
**Dependencies:** None

---

### 7. Add Learn Chapter 5 — Article 2: "The Mammalian Dive Reflex"

**User Story:** As a user, I want to learn about the mammalian dive reflex — the ancient survival mechanism that activates during breath holds — so I understand what's happening in my body during apnea training.

**Description:** Add article about the mammalian dive reflex to Chapter 5. Covers the four components (apnea, bradycardia, peripheral vasoconstriction, splenic contraction), triggers (cold water on face, breath holding), and the Bajau people's genetic adaptation.

**Acceptance Criteria:**
- Article id `13`, title "The dive reflex\nyou didn't know you had", subtitle "Bradycardia, vasoconstriction, and the Bajau spleen"
- Tag: "Evolution", tagColorHex: "2D5F5D", readTime: "5 min"
- Body covers: four components of the dive reflex, how cold water on the face triggers bradycardia (10-25% heart rate reduction), peripheral vasoconstriction shunting blood to brain and heart, the Bajau people of Southeast Asia having spleens 50% larger than neighboring populations (genetic evidence of natural selection for diving), how trained freedivers show enhanced dive reflex response
- References the mammalian evolutionary origin of the reflex

**Priority:** 7
**Dependencies:** 6

---

### 8. Add Learn Chapter 5 — Article 3: "Your Spleen Is a Scuba Tank"

**User Story:** As a user, I want to understand how the spleen contracts during breath holds to release stored red blood cells, so I appreciate the remarkable physiology behind breath-hold training.

**Description:** Add article about splenic contraction during apnea to Chapter 5. This is one of the most surprising findings in breath-hold science — the spleen acts as a biological oxygen reserve.

**Acceptance Criteria:**
- Article id `14`, title "Your spleen is a scuba tank", subtitle "The organ that gives you extra oxygen on demand"
- Tag: "Surprising", tagColorHex: "C4502A", readTime: "4 min"
- Body covers: spleen releasing stored red blood cells during breath holds, increased hematocrit and hemoglobin concentration, the sympathetic nervous system trigger, the Bajau genetic adaptation (50% larger spleens), how trained divers show more pronounced contraction than untrained, the temporary nature of the effect, connection to how CO2 tolerance training over weeks produces cumulative adaptations
- Tone: wonder and surprise — this is genuinely remarkable physiology most people don't know about

**Priority:** 8
**Dependencies:** 6

---

### 9. Add Learn Chapter 5 — Article 4: "How Freedivers Hold Their Breath for 10 Minutes"

**User Story:** As a user fascinated by extreme breath holding, I want to learn the techniques competitive freedivers use to achieve 5-10+ minute breath holds, so I can understand the training principles behind their superhuman abilities.

**Description:** Add article about competitive freediving training methods to Chapter 5. Covers CO2 and O2 tables, mental techniques (body scanning, visualization, segmented thinking), dry static apnea training, and the principle that apnea is 80% mental.

**Acceptance Criteria:**
- Article id `15`, title "How freedivers hold their breath\nfor 10 minutes", subtitle "CO2 tables, O2 tables, and the 80% mental rule"
- Tag: "Extreme", tagColorHex: "C4502A", readTime: "6 min"
- Body covers: the two table types (CO2 tables with shrinking rest, O2 tables with growing holds), dry static apnea training protocols, mental techniques (body scanning, visualization, mantras, segmented thinking), the role of relaxation in reducing oxygen consumption, lung packing/carping (mentioned with safety warnings), safety rules (never in water alone, never after hyperventilation)
- Makes clear these are elite techniques — the average user should focus on BOLT improvement, not max hold times

**Priority:** 9
**Dependencies:** 6

---

### 10. Add Quick Facts for Breath-Hold Science

**User Story:** As a user browsing the Learn tab, I want quick facts about breath holding and CO2 tolerance to spark curiosity and reinforce key concepts from the new chapter.

**Description:** Add 4 new quick facts to `LearnContent.quickFacts` related to breath-hold science and CO2 tolerance.

**Acceptance Criteria:**
- Add these 4 facts to the `quickFacts` array:
  - value: "40s+", label: "excellent BOLT score"
  - value: "50%", label: "larger Bajau spleens"
  - value: "80%", label: "of apnea is mental"
  - value: "10-25%", label: "heart rate drop in dive reflex"
- Facts appear after the existing 8 facts
- Each fact is accurate and references content covered in Chapter 5

**Priority:** 10
**Dependencies:** None

---

### 11. Update Existing "CO2 Problem" Article with Breath-Hold Context

**User Story:** As a user reading the existing CO2 article (Chapter 3, Article 6), I want a brief mention of how breath-hold training connects to CO2 tolerance, so there's a natural bridge to the new Chapter 5 content.

**Description:** Enhance the body text of the existing "The CO2 problem" article (id: 6) in Chapter 3 to add 1-2 sentences connecting CO2 tolerance to breath-hold training and the new exercises. Do NOT rewrite the article — append a brief bridge paragraph.

**Acceptance Criteria:**
- Append to the existing body of article id `6` (do not replace existing text)
- Add 1-2 sentences like: "Breath-hold training — from simple exhale holds to freediver CO2 tables — is the most direct way to retrain these chemoreceptors. Even a few weeks of structured practice can shift your CO2 alarm threshold significantly."
- Keep the existing text intact and unchanged
- The addition should feel like a natural continuation, not a forced upsell

**Priority:** 11
**Dependencies:** None

---

### 12. Update BOLT Score Interpretations with Training Recommendations

**User Story:** As a user who just took the BOLT test, I want my tier interpretation to recommend specific CO2 tolerance exercises, so I know which training to do based on my score.

**Description:** Enhance `BOLTTier.interpretation` in `BOLTScore.swift` to add a brief training recommendation for each tier that references the new CO2 tolerance exercises.

**Acceptance Criteria:**
- Each tier's interpretation string gets an appended sentence recommending appropriate training:
  - veryLow: Recommend "CO2 Tolerance Builder" (existing) and "High Altitude Hold" (new)
  - belowAverage: Recommend "Breath-Hold Walk" and "CO2 Tolerance Builder"
  - average: Recommend "CO2 Table" and "Apnea Pyramid"
  - good: Recommend "CO2 Table" and "Apnea Pyramid" for pushing further
  - excellent: Mention freediver-level training and maintaining with any CO2 exercise
- Recommendations feel natural, not like marketing copy
- Existing interpretation text is preserved — only append

**Priority:** 12
**Dependencies:** 1, 2, 3, 4

---

### 13. Unit Tests: TrainingData Exercises Validation

**User Story:** As a developer, I need unit tests that verify all training exercises have valid structure, correct step sequences, and unique IDs, so regressions are caught before they ship.

**Description:** Create unit tests for `TrainingData` covering all 8 exercises (4 existing + 4 new). Test structural integrity, step type sequences, and data consistency.

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Training/TrainingDataTests.swift`
- Tests verify:
  - All exercises have unique IDs
  - All exercises have non-empty name, icon, duration, description
  - Every exercise's step sequence ends with a `.result` step
  - Step IDs within each exercise are sequential (0, 1, 2, ...)
  - No exercise has zero steps
  - `allExercises` count equals expected total (8)
  - CO2 Builder has exactly 5 rounds (verify step count)
  - Altitude Hold has exactly 5 rounds
  - CO2 Table has exactly 8 rounds
  - Apnea Pyramid has exactly 9 hold rounds
  - Breath-Hold Walk has exactly 6 rounds
- Tests compile and pass with `xcodebuild test`

**Priority:** 13
**Dependencies:** 1, 2, 3, 4, 5

---

### 14. Unit Tests: TrainingData Sections Structure

**User Story:** As a developer, I need unit tests that verify the section grouping of exercises is correct and backward-compatible.

**Description:** Unit tests for the new `TrainingData.Section` structure added in Feature 5.

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Training/TrainingSectionsTests.swift`
- Tests verify:
  - `allSections` has exactly 2 sections
  - "Basics" section contains exactly 4 exercises
  - "CO2 Tolerance" section contains exactly 4 exercises
  - `allExercises` computed property returns all 8 exercises (backward compat)
  - Section titles and subtitles are non-empty
  - Each section has unique id
  - Exercise IDs across all sections are globally unique

**Priority:** 14
**Dependencies:** 5

---

### 15. Unit Tests: LearnContent Chapter 5 Articles

**User Story:** As a developer, I need unit tests verifying Chapter 5's articles have correct structure, sequential IDs, and required fields.

**Description:** Unit tests for the new Chapter 5 learn content (Features 6-9).

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Learn/LearnContentChapter5Tests.swift`
- Tests verify:
  - Chapter 5 exists with id `5`
  - Chapter 5 has exactly 4 articles
  - Article IDs are sequential (12, 13, 14, 15)
  - All articles have non-empty title, subtitle, tag, tagColorHex, readTime, body
  - `allArticles` count equals 16 (12 existing + 4 new)
  - All article IDs across all chapters are globally unique
  - All tagColorHex values are valid 6-character hex strings
  - Quick facts count equals 12 (8 existing + 4 new)

**Priority:** 15
**Dependencies:** 6, 7, 8, 9, 10

---

### 16. Unit Tests: BOLTScore Tier Interpretations

**User Story:** As a developer, I need unit tests that verify BOLT score tier boundaries, interpretations, and trend calculations are correct.

**Description:** Unit tests for `BOLTScore` and `BOLTTier` including the updated interpretations from Feature 12.

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Domain/BOLTScoreTests.swift`
- Tests verify:
  - Tier boundaries: score 5 -> veryLow, 15 -> belowAverage, 25 -> average, 35 -> good, 45 -> excellent
  - Edge cases: score 0 -> veryLow, 10 -> belowAverage (exact boundary), 20 -> average, 30 -> good, 40 -> excellent
  - Each tier has non-empty label, colorHex, interpretation
  - Trend calculation: (previous: 20, current: 25) -> .improved, (20, 18) -> .declined, (20, 21) -> .same
  - Trend symbols and colors are correct
  - BOLTScore initializer sets correct defaults (UUID, Date())
  - BOLTScore.tier computed property returns correct tier for given score

**Priority:** 16
**Dependencies:** 12

---

### 17. Unit Tests: TrainingData Persistence

**User Story:** As a developer, I need unit tests for the training completion persistence layer to ensure completion counts are stored and retrieved correctly.

**Description:** Unit tests for `TrainingData.completionCount(for:)` and `TrainingData.incrementCompletion(for:)` using an injected `UserDefaults` instance for isolation.

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Training/TrainingPersistenceTests.swift`
- Tests use a fresh `UserDefaults(suiteName:)` per test to avoid cross-contamination
- Tests verify:
  - Initial completion count is 0 for any exercise
  - After one increment, count is 1
  - After 3 increments, count is 3
  - Counts are independent per exercise ID
  - Incrementing one exercise does not affect another
  - Counts persist across separate calls (same UserDefaults instance)
- Teardown removes the test suite from UserDefaults

**Priority:** 17
**Dependencies:** None

---

### 18. Unit Tests: BreathPattern Static Data Integrity

**User Story:** As a developer, I need unit tests that verify all 8 breath patterns have valid phase structures and computed properties.

**Description:** Unit tests for `BreathPattern` ensuring all static pattern data is valid and `cycleDuration` is computed correctly.

**Acceptance Criteria:**
- Test file: `Tests/SocraticJournalTests/Domain/BreathPatternTests.swift`
- Tests verify:
  - `allPatterns` count is 8
  - All pattern IDs are unique
  - All patterns have non-empty name, timing, bpm, tag, importance, bestFor
  - Each pattern has at least 1 phase
  - All phase durations are > 0
  - `cycleDuration` equals sum of phase durations for each pattern
  - Resonance cycleDuration is 11.0 (5.5 + 5.5)
  - Box cycleDuration is 16.0 (4 + 4 + 4 + 4)
  - 4-7-8 cycleDuration is 19.0 (4 + 7 + 8)
  - Each pattern has a valid difficulty level
  - All tagColorHex values are valid 6-character hex strings

**Priority:** 18
**Dependencies:** None
