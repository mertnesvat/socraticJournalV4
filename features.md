# Socratic Journal - iOS Native Rebuild

A guided journaling app that uses Socratic dialogue methodology to help users gain clarity through deep self-reflection. Users engage in meaningful conversations with a virtual "Socrates" character, receive personalized insights, and can write sealed letters to their future selves.

---

## Firebase & App Configuration

**App Name:** Socratic Journal V3
**Bundle Identifier:** `com.StudioNext.socraticJournal`
**Firebase Project ID:** `socratic-journal`

### GoogleService-Info.plist Values
```
API_KEY: AIzaSyDQijVFO2lZ3hrp9j41WRAU_OdfAI5-7DA
GCM_SENDER_ID: 453670854244
BUNDLE_ID: com.StudioNext.socraticJournal
PROJECT_ID: socratic-journal
STORAGE_BUCKET: socratic-journal.firebasestorage.app
GOOGLE_APP_ID: 1:453670854244:ios:84adf881a9baa8102f0971
IS_GCM_ENABLED: true
IS_SIGNIN_ENABLED: true
IS_APPINVITE_ENABLED: true
IS_ANALYTICS_ENABLED: false
IS_ADS_ENABLED: false
```

### Firebase Cloud Functions Used
- `generateNextQuestion` - Generates AI follow-up questions based on user answers
- `generateSocratesReaction` - Creates emotional reactions (e.g., "Socrates nods slowly...")
- `generateClarityMirror` - Reflects user's thoughts back in a new perspective
- `generateFollowUpQuestion` - Contextual follow-up generation
- Big Five personality analysis function

---

## Features

### 1. Home Screen
**Priority:** 1
**Dependencies:** none

Main dashboard with:
- Stats summary card showing total entries, current streak, longest streak, weekly entries
- Interactive calendar with session indicators per date and average clarity scores
- Tap on calendar date to filter session history
- "Start Session" prominent button
- Session history list with most recent sessions
- Badge notification showing count of ready-to-read sealed letters
- Navigation icons: Character Discovery, Settings, Letters notification
- Empty state with encouraging message when no sessions exist

---

### 2. Socratic Dialogue Session
**Priority:** 2
**Dependencies:** Home Screen

The core journaling experience with exactly 3 questions per session:

**Question Flow:**
- First question always: "What's on your mind today?"
- Questions 2 and 3 are AI-generated based on previous answers (Firebase Cloud Function)
- Fallback questions available if Firebase is unavailable

**For Each Question:**
1. Display the Socratic question
2. User types answer in text field (can skip by leaving blank)
3. After submitting:
   - Show Socrates' reaction (AI-generated emotional response like "Socrates nods slowly...")
   - Display Clarity Mirror (AI-generated reflection of user's insights)
   - Show Insight Card (3-4 word summary like "Growth through challenge")
4. Continue button advances to next question

**Session Features:**
- Progress bar showing "Question 1 of 3"
- Text input field for answers
- Skip option (leave blank)
- Exit confirmation dialog to prevent accidental data loss

---

### 3. Session Complete Screen
**Priority:** 3
**Dependencies:** Socratic Dialogue Session

Post-session results display:
- Large clarity score (0-100) with visual styling
- Score breakdown showing three components:
  - Completion score (30% weight)
  - Depth score (40% weight)
  - Emotional score (30% weight)
- Score label (e.g., "Deep Dive", "Thoughtful Reflection", "Quick Check-in")
- Personalized encouraging message based on score quality
- Wisdom quote section with thematic quote matched to session content
- Action buttons:
  - "Write Letter to Future Self" - navigates to letter screen
  - "Back to Home" - returns to home

**Score Quality Levels:**
- High Quality: score >= 70
- Moderate: score 40-69
- Quick: score < 40

---

### 4. Future Letters
**Priority:** 4
**Dependencies:** Session Complete Screen

Write sealed letters to your future self:
- Text editor for letter content (20-2000 characters)
- Character counter with validity feedback
- Duration selector with options:
  - 1 Week
  - 1 Month (default)
  - 3 Months
  - 1 Year
- Display of exact unlock date
- Save letter button
- Exit confirmation when leaving without saving

**Letter Lifecycle:**
1. `sealed` - Letter is locked, waiting for unlock date
2. `ready` - Unlock date reached, user notified
3. `read` - User has opened and read the letter
4. `archived` - User archived the letter after reading

Letters are linked to the originating session for context.

---

### 5. Character Discovery (Personality Analysis)
**Priority:** 5
**Dependencies:** Socratic Dialogue Session

AI-powered Big Five (OCEAN) personality analysis based on journal entries:

**Progressive Unlock System (logarithmic: 25 * ln(entries + 1)):**
- **Locked** (< 30% progress): Show progress bar with "journal more" encouragement
- **Sample** (30-40% progress): Preview with sample personality data and disclaimer
- **Available** (> 40% progress): Full personality profile access

**Big Five Traits Displayed:**
1. **Openness to Experience** - Curiosity, creativity, openness to new ideas
2. **Conscientiousness** - Organization, dependability, self-discipline
3. **Extraversion** - Sociability, assertiveness, positive emotions
4. **Agreeableness** - Compassion, cooperation, trust
5. **Neuroticism** - Emotional sensitivity, tendency toward negative emotions

**Display Elements:**
- Overall progress bar toward full unlock
- Visual chart of trait scores (radar/spider chart)
- Individual trait cards showing:
  - Score (0-100)
  - Label (High/Moderate/Low)
  - Description
  - Supporting evidence quotes from journal entries
- Summary narrative interpretation
- Refresh button to regenerate after new sessions
- "Last analyzed" timestamp

---

### 6. Session History & Details
**Priority:** 6
**Dependencies:** Home Screen, Socratic Dialogue Session

View past sessions:
- List view of all sessions sorted by date
- Filter by tapping calendar dates
- Session preview cards showing date and clarity score

**Session Detail Modal (Bottom Sheet):**
- Swipeable/draggable to dismiss
- Full conversation history with all Q&A pairs
- Clarity mirrors displayed for each exchange
- Insight cards shown
- Wisdom quote from that session
- Clarity score breakdown

---

### 7. Journal Statistics
**Priority:** 7
**Dependencies:** Socratic Dialogue Session

Track journaling habits:
- Total entries completed
- Current streak (consecutive days with journal entry)
- Longest streak ever achieved
- This week's entry count
- Session count by date (shown on calendar)
- Average clarity score by date (shown on calendar)

---

### 8. Wisdom Quotes
**Priority:** 8
**Dependencies:** Session Complete Screen

Quote system with 390+ quotes:
- Organized by themes: Change, Struggle, Acceptance, Relationships, Purpose, Self-Knowledge, Time, Fear, Loss, Gratitude, Creativity, Universal
- Matched to session content themes
- Display with author and source attribution
- Stored in local JSON file (`wisdom_quotes.json`)

---

### 9. Settings Screen
**Priority:** 9
**Dependencies:** Home Screen

App configuration:

**Appearance:**
- Theme selector: System (default) / Light / Dark
- Changes apply immediately without restart

**Notifications:**
- Letter reminders toggle (on by default)
- Daily reminder toggle (off by default)
- Reminder time picker (when daily reminders enabled)

**Data:**
- Export journal as JSON file
- Clear all data (with confirmation dialog)

**About:**
- App version display (1.0.0)
- Privacy policy link

---

### 10. Data Export
**Priority:** 10
**Dependencies:** Settings Screen

Export all journal data:
- JSON format export
- Includes:
  - All sessions with exchanges
  - All future letters
  - Settings configuration
  - Export timestamp
- Saved to device documents directory
- Filename: `socratic_journal_export_[timestamp].json`

---

### 11. Notifications
**Priority:** 11
**Dependencies:** Future Letters, Settings Screen

Push notification support:
- Letter ready notifications when sealed letter unlock date is reached
- Optional daily journaling reminder at user-configured time
- Uses Firebase Cloud Messaging (GCM enabled)

---

## Data Models

### JournalSession
- `id`: String (UUID)
- `createdAt`: DateTime
- `exchanges`: Array of Exchange objects
- `clarityScore`: ClarityScore object (optional, set after completion)
- `wisdomQuote`: WisdomQuote object (optional)
- `isComplete`: Boolean

### Exchange
- `id`: String
- `question`: String
- `answer`: String
- `clarityMirror`: String (optional, AI-generated)
- `insightCard`: String (optional, 3-4 word summary)
- `skipped`: Boolean
- `answeredAt`: DateTime

### FutureLetter
- `id`: String (UUID)
- `sessionId`: String (links to originating session)
- `content`: String
- `createdAt`: DateTime
- `unlockAt`: DateTime
- `status`: Enum (sealed/ready/read/archived)
- `readAt`: DateTime (optional)

### ClarityScore
- `total`: Int (0-100)
- `completion`: Int (0-100, 30% weight)
- `depth`: Int (0-100, 40% weight)
- `emotional`: Int (0-100, 30% weight)
- `label`: String
- `message`: String

### BigFiveProfile
- `openness`: PersonalityTrait
- `conscientiousness`: PersonalityTrait
- `extraversion`: PersonalityTrait
- `agreeableness`: PersonalityTrait
- `neuroticism`: PersonalityTrait
- `summary`: String
- `analyzedAt`: DateTime

### PersonalityTrait
- `type`: Enum (openness/conscientiousness/extraversion/agreeableness/neuroticism)
- `score`: Int (0-100)
- `label`: String (High/Moderate/Low)
- `description`: String
- `evidence`: Array of Strings

### JournalStats
- `totalEntries`: Int
- `currentStreak`: Int
- `longestStreak`: Int
- `thisWeekEntries`: Int
- `sessionCountByDate`: Dictionary<Date, Int>
- `averageScoreByDate`: Dictionary<Date, Double>

### UserSettings
- `themeMode`: Enum (system/light/dark)
- `letterRemindersEnabled`: Boolean
- `dailyReminderEnabled`: Boolean
- `dailyReminderHour`: Int (optional)
- `dailyReminderMinute`: Int (optional)

### WisdomQuote
- `id`: String
- `text`: String
- `author`: String
- `source`: String (optional)
- `theme`: Enum (change/struggle/acceptance/relationships/purpose/self-knowledge/time/fear/loss/gratitude/creativity/universal)

---

## Key User Flows

### First-Time User
1. Launch app → Home screen (empty state)
2. Tap "Start Session"
3. Answer 3 Socratic questions
4. View clarity score and wisdom quote
5. Optionally write letter to future self
6. Return home, see first session in history

### Daily Returning User
1. Home shows stats, calendar with session indicators, recent sessions
2. Tap "Start Session"
3. Complete 3-question dialogue
4. View results
5. Progress toward character discovery increases

### Character Discovery Unlock
1. Complete 10-15 sessions → Hit 30% progress → See preview
2. Complete more sessions → Hit 40% progress → Full profile unlocked
3. View detailed Big Five personality analysis
4. Refresh profile after additional journaling

### Future Letter Lifecycle
1. Complete session → Tap "Write Letter" on complete screen
2. Write message, choose unlock duration (1 week to 1 year)
3. Letter sealed
4. On unlock date, notification badge appears on home
5. Read letter → Option to archive