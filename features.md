---
base_branch: master
max_retries: 2
continue_on_failure: true
visual_gate_enabled: false
bundle_id: com.mertnesvat.SocraticJournal
action_logging: true
---

# Feature Queue: Unit Tests for Critical Business Logic

These features add unit tests for the most important business logic in the app. Focus is on catching real bugs - no flaky or unnecessary edge case tests.

---

### 1. ClarityScore Calculation Tests

Add unit tests for the ClarityScore calculation algorithm in `MockClarityScoreService`. This is the core scoring system that evaluates journal session quality.

**User Story:** As a developer, I want tests for the clarity score calculation so bugs in scoring don't ship to users.

**Acceptance Criteria:**
- Test completion score calculation (answered vs skipped exchanges)
- Test depth score based on word count thresholds (0-10, 10-30, 30-50, 50+ words)
- Test emotional score detection with known emotional words
- Test weighted total calculation (30% completion, 40% depth, 30% emotional)
- Test quality level labels (Quick Check-in, Thoughtful Reflection, Deep Dive)

**Priority:** 1
**Dependencies:** None

---

### 2. Streak Calculation Tests

Add unit tests for streak calculation in `InMemoryJournalRepository.calculateStats()`. Streaks are shown prominently in the app stats.

**User Story:** As a developer, I want tests for streak calculation so user streak counts are always accurate.

**Acceptance Criteria:**
- Test current streak with consecutive days
- Test current streak resets after missed day
- Test longest streak is remembered even after current streak breaks
- Test streak counts today's entry correctly
- Test streak handles single-day gaps properly

**Priority:** 1
**Dependencies:** None

---

### 3. Character Discovery Unlock State Tests

Add unit tests for `CharacterDiscoveryUnlockState` progression formula. This gates access to personality analysis feature.

**User Story:** As a developer, I want tests for unlock state calculation so users unlock features at the correct times.

**Acceptance Criteria:**
- Test locked state with 0 entries (progress < 30%)
- Test sample state unlocks around 3 entries (30-40% progress)
- Test available state unlocks around 5 entries (40%+ progress)
- Test progress formula: `25 * ln(entries + 1)`

**Priority:** 2
**Dependencies:** None

---

### 4. Milestone Unlock Tests

Add unit tests for milestone unlocking in `StatisticsViewModel.calculateMilestones()`. Milestones reward user engagement.

**User Story:** As a developer, I want tests for milestone unlocks so achievements trigger at correct thresholds.

**Acceptance Criteria:**
- Test first entry milestone unlocks at 1 entry
- Test streak milestones unlock at 3, 7, 14, 30 days
- Test entry count milestones at 10, 25, 50, 100 entries
- Test milestones stay unlocked once achieved

**Priority:** 2
**Dependencies:** None

---

### 5. FutureLetter Status Transition Tests

Add unit tests for `FutureLetter` status transitions and `isReadyToOpen` logic. Letters have time-based unlocking.

**User Story:** As a developer, I want tests for letter status logic so letters unlock and transition correctly.

**Acceptance Criteria:**
- Test `isReadyToOpen` returns true when delivery date has passed
- Test `isReadyToOpen` returns false for future delivery dates
- Test `timeRemaining` calculation accuracy
- Test status transitions: sealed → ready → read → archived

**Priority:** 2
**Dependencies:** None

---

### 6. JournalStats Aggregation Tests

Add unit tests for stats aggregation (weekly entries, session counts by date, average scores).

**User Story:** As a developer, I want tests for stats aggregation so displayed statistics are accurate.

**Acceptance Criteria:**
- Test thisWeekEntries counts only current week sessions
- Test sessionCountByDate groups correctly by calendar date
- Test averageScoreByDate calculates mean scores per day
- Test stats handle empty session list gracefully

**Priority:** 3
**Dependencies:** None

---

### 7. WisdomQuote Content Matching Tests

Add unit tests for quote matching logic in `LocalWisdomQuoteService`. Quotes should match session content themes.

**User Story:** As a developer, I want tests for quote matching so relevant quotes are shown after sessions.

**Acceptance Criteria:**
- Test `matchQuoteToContent()` selects quotes with matching theme keywords
- Test `getDailyQuote()` returns consistent quote for same date
- Test `getDailyQuote()` returns different quote on different dates
- Test fallback when no theme matches content

**Priority:** 3
**Dependencies:** None
