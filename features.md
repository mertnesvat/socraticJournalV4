---
base_branch: feature/ux-rehaul-1
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.mertnesvat.SocraticJournal
action_logging: true

# Deep Quality Mode (enabled for this UX rehaul)
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.7
deep_quality_review_gate: true
---

# Feature Queue: Socratic Journal UX Rehaul

## Overview

Major UX reorganization to create a dedicated "Self-Discovery" tab that consolidates personality-related features, plus a new AI-powered "Which Character Are You" feature that analyzes journal entries to match users with fictional characters.

**Key Changes:**
- Add new "Self-Discovery" tab (3-tab navigation)
- Move Character Analysis (Big Five) to Self-Discovery
- Add "Which Character Are You" AI feature
- Move Letters to Future Self to Home tab as a card
- Remove Wisdom Quotes from main navigation

---

### 1. Create Self-Discovery Tab with New Navigation Structure

Replace the current 2-tab navigation (Home, Statistics) with a 3-tab structure that better organizes features.

**User Story:** As a user, I want a dedicated space for self-discovery features so I can easily access personality insights and character matching without hunting through toolbar icons.

**Acceptance Criteria:**
- Main navigation has 3 tabs: Home, Self-Discovery, Statistics
- Self-Discovery tab icon uses sparkles.2 or brain SF Symbol
- Tab order: Home (house.fill), Self-Discovery (sparkles), Statistics (chart.bar.fill)
- Floating + button remains accessible from all tabs
- Tab bar maintains existing liquid glass visual effect
- Smooth tab switching animations work correctly

**Current State:**
- `MainTabView.swift` has 2 tabs defined in `MainTab` enum
- `HomeTabView.swift` toolbar has 4 icons: person (Character), quote (Wisdom), envelope (Letters), gear (Settings)

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -self-discovery-tab

---

### 2. Build Self-Discovery Tab Content View

Create the main view for the Self-Discovery tab that hosts personality analysis, character matching, and other introspective features.

**User Story:** As a user, I want to see all my self-discovery tools in one organized place with clear navigation between different analysis types.

**Acceptance Criteria:**
- New `SelfDiscoveryTabView.swift` created following existing tab patterns
- New `SelfDiscoveryViewModel.swift` with @Observable pattern
- Welcoming header section with title "Self-Discovery"
- Features presented as tappable cards/sections:
  - "Your Personality Profile" card (links to Big Five analysis)
  - "Which Character Are You?" card (links to character matching)
- Cards show preview/teaser content when analysis available
- Locked states shown appropriately when insufficient journal entries (< 5)
- Pull-to-refresh available for updating analyses
- Consistent visual style matching existing app design (rounded corners 12-16pt, shadows, cards)
- NavigationStack wrapper for proper navigation

**Priority:** 1
**Dependencies:** Feature #1
**Branch Suffix:** -self-discovery-content

---

### 3. Relocate Letters to Future Self to Home Tab

Move "Letters to My Future Self" from the toolbar to a more prominent, appropriate location on the Home tab.

**User Story:** As a user, I want easy access to my letters without it being hidden in a small toolbar icon, so I remember to write and read them.

**Acceptance Criteria:**
- New `LettersCard.swift` component created
- Letters card appears on Home tab below the calendar, above session list
- Card shows:
  - Icon and "Letters to Future Self" title
  - Count of sealed letters
  - Prominent badge when letters are ready to open
  - Chevron indicating tappable
- Tapping the card opens existing `LettersListView` as fullScreenCover
- Remove envelope icon from Home toolbar
- Home toolbar only keeps Settings gear icon after all migrations
- Visual design matches existing `StatsCardView` style
- Card respects theme (light/dark mode)

**Priority:** 2
**Dependencies:** Feature #1
**Branch Suffix:** -letters-card

---

### 4. Which Character Are You - UI and View Layer

Create the UI for the new "Which Character Are You" feature that displays character matching results.

**User Story:** As a user, I want to discover which fictional character I'm most like based on my journal entries, so I can gain new perspective on my personality through familiar characters.

**Acceptance Criteria:**
- New `CharacterMatchView.swift` created
- New `CharacterMatchViewModel.swift` with @Observable pattern
- Franchise selector with options: Lord of the Rings, Harry Potter, Star Wars
- Franchise buttons as horizontal scrolling pills/chips
- Results display showing top 3 character matches:
  - Character name prominently displayed
  - Confidence percentage (e.g., 75%)
  - Brief explanation snippet (1-2 sentences)
  - Progress bar or visual indicator for confidence
- Tapping a character expands to show detailed reasoning
- "Locked" state with progress indicator if < 5 journal entries
- Engaging loading animation during analysis (sparkles, thinking indicator)
- "Analyze" / "Refresh" button to trigger analysis
- Results cached/persisted locally after first analysis
- Empty state encouraging more journaling if locked

**Priority:** 2
**Dependencies:** Feature #2
**Branch Suffix:** -character-match-ui

---

### 5. Firebase Function for Character Matching Analysis

Create the backend Firebase Function that performs AI-powered character matching analysis.

**User Story:** As a developer, I need a backend function that analyzes journal entries and returns character matches with confidence scores.

**Acceptance Criteria:**
- New Firebase Function `analyzeCharacterMatch` in `Firebase/functions/src/index.ts`
- Function accepts:
  - `entries`: Array of {question, answer, clarityMirror} objects
  - `franchise`: String ("lordOfTheRings" | "harryPotter" | "starWars")
- Function returns JSON:
  ```json
  {
    "matches": [
      {"character": "Boromir", "confidence": 75, "reasoning": "Your entries show..."},
      {"character": "Gimli", "confidence": 15, "reasoning": "You also demonstrate..."},
      {"character": "Frodo", "confidence": 10, "reasoning": "At times you show..."}
    ],
    "analyzedAt": "2024-01-26T..."
  }
  ```
- System prompt includes franchise-specific character knowledge
- Uses GPT-4o-mini model
- Timeout set to 60 seconds
- Minimum 5 entries required (return error if fewer)
- Character roster per franchise:
  - **LOTR:** Frodo, Sam, Gandalf, Aragorn, Legolas, Gimli, Boromir, Galadriel, Eowyn, Faramir, Merry, Pippin
  - **Harry Potter:** Harry, Hermione, Ron, Dumbledore, Snape, Luna, Neville, Sirius, Hagrid, McGonagall, Ginny, Draco
  - **Star Wars:** Luke, Leia, Han, Obi-Wan, Yoda, Anakin, Padme, Rey, Finn, Ahsoka, Mando, Grogu
- Proper error handling for API failures

**Priority:** 2
**Dependencies:** Feature #4
**Branch Suffix:** -character-match-backend

---

### 6. Character Match Swift Service Integration

Create the Swift service layer to call the character matching Firebase function.

**User Story:** As a developer, I need a Swift service to communicate with the character matching backend.

**Acceptance Criteria:**
- Add `analyzeCharacterMatch` method to `FirebaseFunctionsServiceProtocol`
- Implement method in `FirebaseFunctionsService`
- Create `CharacterMatch` entity in Domain/Entities
- Create `CharacterMatchResult` entity with matches array and analyzedAt
- Create mock implementation for testing/offline
- Proper error handling matching existing patterns
- Add to `CharacterMatchViewModel` to call service

**Priority:** 2
**Dependencies:** Feature #5
**Branch Suffix:** -character-match-service

---

### 7. Move Personality Analysis to Self-Discovery Tab

Migrate the existing Character Discovery (Big Five personality analysis) from toolbar modal to Self-Discovery tab.

**User Story:** As a user, I want my personality analysis easily accessible within the Self-Discovery tab rather than hidden in a toolbar icon.

**Acceptance Criteria:**
- "Your Personality Profile" card on Self-Discovery tab navigates to personality view
- Personality section shows preview when analysis available:
  - Top trait displayed (e.g., "High Openness")
  - Mini chart or trait indicators
- Tapping opens existing `CharacterDiscoveryView` as fullScreenCover or sheet
- Unlock progress visible when analysis is locked (< 5 entries)
- Refresh capability maintained
- All existing Big Five functionality preserved
- Remove person icon from Home toolbar

**Priority:** 2
**Dependencies:** Feature #2
**Branch Suffix:** -personality-migration

---

### 8. Remove Wisdom Screen from Navigation

Remove the Wisdom Quotes feature from the main navigation to declutter.

**User Story:** As a user, I want a cleaner interface focused on journaling and self-discovery without less essential features cluttering the navigation.

**Acceptance Criteria:**
- Quote bubble icon removed from Home toolbar
- `WisdomQuotesView` fullScreenCover presentation removed from `HomeTabView`
- Wisdom quote on session completion screen remains (if implemented)
- No broken references or navigation errors
- WisdomQuotesView files remain in codebase (not deleted) for potential future use
- Clean build with no warnings

**Priority:** 3
**Dependencies:** Feature #7
**Branch Suffix:** -remove-wisdom

---

### 9. Self-Discovery Tab Empty and Locked States

Create engaging empty states and locked state UI for Self-Discovery features.

**User Story:** As a new user, I want to understand what Self-Discovery features offer and how to unlock them, so I'm motivated to journal more.

**Acceptance Criteria:**
- Empty/locked state when user has < 5 journal entries
- Clear explanation: "Complete 5 journal sessions to unlock personality insights"
- Visual progress indicator showing current progress (e.g., 2/5 sessions)
- Each feature card shows individual locked state
- Motivating, supportive copy encouraging journaling
- Smooth animation when transitioning from locked to unlocked
- Both Character Match and Personality sections show appropriate states

**Priority:** 3
**Dependencies:** Feature #4, Feature #7
**Branch Suffix:** -empty-states

---

### 10. Home Tab Toolbar Cleanup

Final cleanup of Home tab toolbar after all feature migrations.

**User Story:** As a user, I want a clean, uncluttered Home screen toolbar with only essential actions.

**Acceptance Criteria:**
- Home toolbar has only Settings (gear) icon remaining
- Person icon removed (moved to Self-Discovery)
- Quote icon removed (Wisdom feature deprioritized)
- Envelope icon removed (Letters moved to card)
- Toolbar styling consistent
- All navigation still works correctly
- No orphaned code or unused state variables

**Priority:** 3
**Dependencies:** Feature #3, Feature #7, Feature #8
**Branch Suffix:** -toolbar-cleanup

---

## Implementation Order

```
Phase 1: Foundation
├── Feature #1 - Create 3-tab navigation structure
└── Feature #2 - Build Self-Discovery tab content view

Phase 2: Feature Migration
├── Feature #3 - Relocate Letters to Home tab card
├── Feature #7 - Move Personality Analysis to Self-Discovery
└── Feature #8 - Remove Wisdom from navigation

Phase 3: New Character Match Feature
├── Feature #5 - Firebase Function for character matching
├── Feature #6 - Swift service integration
└── Feature #4 - Character Match UI

Phase 4: Polish
├── Feature #9 - Empty and locked states
└── Feature #10 - Home toolbar cleanup
```

---

## Key Files Reference

**Navigation:**
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` - Tab container
- `Sources/SocraticJournal/Presentation/Navigation/HomeTabView.swift` - Home tab

**Existing Features to Migrate:**
- `Sources/SocraticJournal/Presentation/CharacterDiscovery/CharacterDiscoveryView.swift`
- `Sources/SocraticJournal/Presentation/Letters/LettersListView.swift`
- `Sources/SocraticJournal/Presentation/WisdomQuotes/WisdomQuotesView.swift`

**Services:**
- `Sources/SocraticJournal/Data/Services/FirebaseFunctionsService.swift`
- `Sources/SocraticJournal/Domain/Services/FirebaseFunctionsServiceProtocol.swift`

**Backend:**
- `Firebase/functions/src/index.ts`
- `Firebase/functions/src/services/openai.ts`

**Design Patterns to Follow:**
- Cards: See `StatsCardView.swift` for styling
- ViewModels: Use @Observable pattern
- Loading states: Existing patterns in CharacterDiscoveryView
- Theme: Use ThemeManager for light/dark support

---

## Character Data for AI Prompts

### Lord of the Rings Characters
| Character | Key Traits |
|-----------|-----------|
| Frodo | Burden-bearer, humble, resilient, compassionate |
| Sam | Loyal, steadfast, hopeful, nurturing |
| Gandalf | Wise, patient, strategic, protective |
| Aragorn | Leader, honorable, reluctant hero, brave |
| Legolas | Graceful, observant, stoic, skilled |
| Gimli | Fierce, loyal, humorous, proud |
| Boromir | Protective, ambitious, conflicted, brave |
| Galadriel | Powerful, wise, tempted, serene |
| Eowyn | Brave, frustrated, determined, caring |
| Faramir | Thoughtful, honorable, overlooked, wise |

### Harry Potter Characters
| Character | Key Traits |
|-----------|-----------|
| Harry | Brave, loyal, impulsive, survivor |
| Hermione | Intelligent, dedicated, anxious, compassionate |
| Ron | Loyal, insecure, humorous, brave |
| Dumbledore | Strategic, caring, secretive, wise |
| Snape | Complex, protective, bitter, loyal |
| Luna | Unique, accepting, intuitive, resilient |
| Neville | Underestimated, brave, loyal, growth-oriented |
| Sirius | Rebellious, loyal, impulsive, loving |

### Star Wars Characters
| Character | Key Traits |
|-----------|-----------|
| Luke | Hopeful, idealistic, brave, conflicted |
| Leia | Leader, determined, compassionate, strong |
| Han | Rogue, loyal, skeptical, brave |
| Obi-Wan | Patient, wise, mentor, peaceful |
| Yoda | Wise, patient, mysterious, powerful |
| Anakin | Passionate, conflicted, powerful, loving |
| Padme | Diplomatic, brave, caring, principled |
| Rey | Resilient, searching, powerful, compassionate |
| Ahsoka | Independent, wise, skilled, principled |

---

## Notes for Night Agent

- Follow existing Clean Architecture patterns (Protocol in Domain, Implementation in Data)
- Use @Observable for all new ViewModels
- Match existing visual patterns (card styles, spacing, shadows)
- Ensure all fullScreenCovers propagate theme via `.environment()`
- Test tab switching and navigation thoroughly
- New entities go in `Domain/Entities/`
- New services follow singleton @unchecked Sendable pattern
- Firebase functions use existing openai.ts patterns
- All UI should support both light and dark modes
