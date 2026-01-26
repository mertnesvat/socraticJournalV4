---
base_branch: master
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.StudioNext.socraticJournal
action_logging: true

# Deep Quality Mode (enabled for UX rehaul - critical user experience changes)
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.7
deep_quality_review_gate: true
---

# Feature Queue: UX Rehaul & Character Quiz - Socratic Journal

## Context

The app currently has a two-tab architecture (Home + Statistics) with features accessed via toolbar icons. This rehaul introduces a new **Self-Discovery** tab to consolidate personality insights, character quizzes, and future letters into a dedicated exploration space. The Home tab will become purely journal-focused.

**Current State:**
- Two tabs: Home (calendar, sessions, stats overview) and Statistics
- Toolbar icons for: Letters, Character Discovery, Wisdom Quotes, Settings
- Character Discovery uses Big Five personality analysis with unlock system
- Future Letters accessed via envelope icon in toolbar
- Wisdom Quotes library accessible from toolbar

**Target State:**
- Three tabs: Home (journal-centric), Self-Discovery (insights hub), Statistics
- Home focuses purely on journaling: calendar, sessions, quick stats
- Self-Discovery contains: Character Analysis, Which Character Am I quiz, Future Letters
- Wisdom Quotes moved to Settings (hidden but accessible)
- New AI-powered character matching feature with 7+ fictional universes

**Existing Patterns:**
- Clean Architecture: Protocol in Domain, Implementation in Data
- MVVM with @Observable @MainActor ViewModels
- Firebase Functions for AI features via `FirebaseFunctionsService.shared`
- Tab navigation in `MainTabView.swift`
- Feature screens in dedicated folders under `/Presentation/`

---

### 1. Create Self-Discovery Tab Infrastructure

Create the new Self-Discovery tab with a cards grid layout that will house all self-insight features.

**User Story:** As a user, I want a dedicated space for self-discovery features so that I can explore insights about myself without cluttering my journaling experience.

**Acceptance Criteria:**
- New `MainTab.selfDiscovery` case added to tab enum
- `SelfDiscoveryTabView` created with cards grid layout
- Tab appears between Home and Statistics tabs
- Tab icon is appropriate (e.g., sparkles, compass, or person.crop.circle.badge.questionmark)
- Grid shows placeholder cards for: "My Personality", "Which Character Am I?", "Letters to Future Me"
- Cards are visually distinct and tappable
- Empty state handled gracefully before features are connected

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -self-discovery-tab

**Implementation Notes:**
- Add to `Navigation/` folder: `SelfDiscoveryTabView.swift`
- Create `SelfDiscoveryViewModel.swift` for grid state management
- Update `MainTabView.swift` to include third tab
- Use SF Symbols for tab icon
- Cards should use consistent styling with existing app theme

---

### 2. Create Discovery Card Component

Create a reusable discovery card component for the Self-Discovery grid that provides consistent visual style and interaction patterns.

**User Story:** As a user, I want visually appealing cards that invite me to explore each self-discovery feature.

**Acceptance Criteria:**
- `DiscoveryCard` component created with: icon, title, subtitle, optional badge
- Card supports locked/unlocked states visually
- Card has subtle animation on tap
- Card shows progress indicator if feature has unlock requirements
- Consistent styling with app theme (colors, shadows, corners)
- Cards adapt to different content lengths
- VoiceOver accessible

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -discovery-card

**Implementation Notes:**
- Place in `Presentation/Components/DiscoveryCard.swift`
- Support configurable accent colors per card
- Badge for "New" or notification counts
- Consider using ViewModifier for card styling

---

### 3. Move Character Analysis to Self-Discovery

Relocate the existing Character Analysis (Big Five personality) feature from toolbar to Self-Discovery tab as the "My Personality" card.

**User Story:** As a user, I want to access my personality analysis from the Self-Discovery tab so that all my personal insights are in one place.

**Acceptance Criteria:**
- "My Personality" card in Self-Discovery grid
- Tapping card opens existing `CharacterDiscoveryView`
- Card shows current unlock state (locked/sample/available)
- Progress percentage shown if not fully unlocked
- Remove person icon from Home tab toolbar
- All existing personality analysis functionality preserved
- Navigation works correctly (back button returns to Self-Discovery)

**Priority:** 1
**Dependencies:** 1, 2
**Branch Suffix:** -move-personality

**Implementation Notes:**
- Use NavigationLink or sheet presentation
- Preserve all existing CharacterDiscoveryView behavior
- Update HomeTabView to remove toolbar button

---

### 4. Move Future Letters to Self-Discovery

Relocate the Future Letters feature from toolbar to Self-Discovery tab as the "Letters to Future Me" card.

**User Story:** As a user, I want to access my future letters from the Self-Discovery tab so that this reflective feature is grouped with other self-insight tools.

**Acceptance Criteria:**
- "Letters to Future Me" card in Self-Discovery grid
- Tapping card opens existing `LettersListView`
- Card shows badge with count of ready-to-read letters
- Envelope icon removed from Home tab toolbar
- All existing letters functionality preserved
- Compose letter flow works correctly from new location

**Priority:** 1
**Dependencies:** 1, 2
**Branch Suffix:** -move-letters

**Implementation Notes:**
- Badge shows `repository.getReadyLettersCount()` value
- Use same navigation pattern as personality card
- Ensure deep links still work if implemented

---

### 5. Move Wisdom Quotes to Settings

Relocate Wisdom Quotes library from toolbar to Settings screen as a less prominent feature.

**User Story:** As a user, I want wisdom quotes accessible from settings while keeping my main screens focused on core functionality.

**Acceptance Criteria:**
- "Wisdom Quotes Library" row added to Settings screen
- Tapping row opens existing `WisdomQuotesView`
- Quote bubble icon removed from Home tab toolbar
- All existing wisdom quotes functionality preserved
- Settings row shows quote count or "Browse quotes" subtitle

**Priority:** 2
**Dependencies:** None
**Branch Suffix:** -move-wisdom

**Implementation Notes:**
- Add section to SettingsView for "Features" or similar grouping
- Could group with other secondary features
- Consider adding Daily Quote toggle in settings too

---

### 6. Simplify Home Tab to Journal-Centric View

Refocus the Home tab purely on journaling by removing discovery-related toolbar icons and keeping only calendar, sessions, and quick stats.

**User Story:** As a user, I want my Home tab to focus on journaling so I can quickly review my history and start new sessions without distractions.

**Acceptance Criteria:**
- Home tab shows: Calendar view, Recent sessions list, Quick stats card
- Toolbar only has: Settings gear icon
- Floating action button preserved for new session
- Stats overview card shows: streak, total sessions, last session date
- Clean, uncluttered layout
- All journal session functionality preserved

**Priority:** 2
**Dependencies:** 3, 4, 5
**Branch Suffix:** -simplify-home

**Implementation Notes:**
- Remove: Letters icon, Character icon, Wisdom icon from toolbar
- Keep calendar, session list, and minimal stats
- Consider moving detailed stats to Statistics tab only

---

### 7. Create Fictional Universe Data Model

Create the data model for fictional universes and their characters to support the "Which Character Am I?" feature.

**User Story:** As a developer, I need a structured way to represent fictional universes and their characters for the character matching feature.

**Acceptance Criteria:**
- `FictionalUniverse` entity with: id, name, icon, description, characters
- `FictionalCharacter` entity with: id, name, universe, description, traits, imageAssetName
- Initial universes defined: Lord of the Rings, Harry Potter, Star Wars, Marvel, DC Comics, Game of Thrones, Narnia
- At least 10-15 notable characters per universe
- Characters have personality trait keywords for matching
- Data stored as local JSON or embedded Swift data

**Priority:** 2
**Dependencies:** None
**Branch Suffix:** -universe-models

**Implementation Notes:**
- Place entities in `Domain/Entities/`
- Consider `FictionalUniverseRepository` for data access
- Characters need trait descriptors that map to journal analysis
- Start with main characters, can expand later

---

### 8. Create Character Quiz Firebase Function

Create the Firebase Function that analyzes journal entries and matches the user's personality to characters from a selected fictional universe.

**User Story:** As a user, I want AI to analyze my journal entries and tell me which fictional character I'm most like so I can have fun discovering my personality through beloved characters.

**Acceptance Criteria:**
- New Firebase function `matchFictionalCharacter` created
- Function accepts: journal entries (text), selected universe ID
- Function returns: top 3 character matches with confidence percentages
- Each match includes: character name, confidence (0-100%), reasoning from entries
- Reasoning cites specific themes/patterns from journal entries
- Function handles all 7 supported universes
- Appropriate error handling for insufficient journal content

**Priority:** 2
**Dependencies:** 7
**Branch Suffix:** -character-function

**Implementation Notes:**
- Add to `Firebase/functions/src/index.ts`
- Create `services/characterMatching.ts` for logic
- Use GPT-4o-mini with structured output for consistent results
- Prompt should include universe-specific character knowledge
- Consider caching results for same entries + universe combo

---

### 9. Create Character Quiz Swift Service

Create the Swift service layer to call the character matching Firebase function and handle responses.

**User Story:** As a developer, I want a service that handles character quiz API calls following our existing patterns.

**Acceptance Criteria:**
- `CharacterQuizServiceProtocol` defined in Domain layer
- `FirebaseCharacterQuizService` implementation in Data layer
- Service calls `matchFictionalCharacter` Firebase function
- Proper request/response types defined
- Error handling with meaningful error types
- Timeout of 45 seconds (analysis may take time)
- Mock service available for testing

**Priority:** 2
**Dependencies:** 8
**Branch Suffix:** -character-service

**Implementation Notes:**
- Follow `PersonalityAnalysisServiceProtocol` pattern
- Request type: `CharacterMatchRequest(journalEntries: [String], universeId: String)`
- Response type: `CharacterMatchResult(matches: [CharacterMatch], generatedAt: Date)`
- `CharacterMatch`: `characterId, characterName, confidence, reasoning`

---

### 10. Create Which Character Am I Quiz View

Create the user interface for the character quiz feature, including universe selection and results display.

**User Story:** As a user, I want to select a fictional universe and see which character I match with, along with why the AI thinks I'm like that character.

**Acceptance Criteria:**
- "Which Character Am I?" card in Self-Discovery grid
- Tapping opens universe selection screen
- Universe selection shows grid of universe cards with icons
- After selecting universe, analysis runs with loading state
- Results screen shows top 3 matches:
  - Character name and image/icon
  - Confidence percentage with visual bar
  - Reasoning text citing journal patterns
- User can try different universes from results screen
- Results can be shared (optional)
- Handles case when user has insufficient journal entries

**Priority:** 3
**Dependencies:** 2, 9
**Branch Suffix:** -character-quiz-ui

**Implementation Notes:**
- Create `Presentation/CharacterQuiz/` folder
- Views: `CharacterQuizView`, `UniverseSelectionView`, `CharacterResultsView`
- ViewModel: `CharacterQuizViewModel`
- Use existing unlock pattern if requiring minimum entries
- Consider fun animations for reveal

---

### 11. Create Character Results Card Component

Create a visually engaging component to display individual character match results with confidence and reasoning.

**User Story:** As a user, I want to see my character matches displayed in an engaging way that shows the confidence level and explains why I matched.

**Acceptance Criteria:**
- `CharacterResultCard` component displays single character match
- Shows: character image/icon, name, universe badge, confidence percentage
- Confidence shown as animated percentage and visual bar
- Expandable/collapsible reasoning section
- Visual hierarchy: #1 match larger, #2 and #3 progressively smaller
- Smooth animations for loading/reveal
- Accessible with VoiceOver

**Priority:** 3
**Dependencies:** 10
**Branch Suffix:** -character-result-card

**Implementation Notes:**
- Place in `Presentation/CharacterQuiz/Components/`
- Consider medal/rank indicators (gold, silver, bronze)
- Reasoning should show journal entry excerpts if possible

---

### 12. Add Character Quiz History & Favorites

Allow users to view their past character quiz results and save favorites.

**User Story:** As a user, I want to see my past character quiz results and save my favorite matches so I can revisit them later.

**Acceptance Criteria:**
- Character quiz results saved locally after each analysis
- "My Results" section in quiz view showing past results by universe
- Can favorite/unfavorite character matches
- Favorites accessible from results view
- Can re-analyze with updated journal entries
- Shows when result was generated
- Can delete old results

**Priority:** 4
**Dependencies:** 10
**Branch Suffix:** -character-history

**Implementation Notes:**
- Add `CharacterQuizResult` entity for persistence
- Add to repository layer
- Consider showing "personality evolved" if re-analysis differs significantly

---

### 13. Add Universe-Specific Character Assets

Add visual assets (icons or images) for characters and universes to enhance the quiz experience.

**User Story:** As a user, I want to see recognizable images or icons for characters and universes so the experience feels more immersive.

**Acceptance Criteria:**
- Each universe has a distinctive icon/symbol
- Major characters have representative icons (can be stylized/abstract due to licensing)
- Assets work in both light and dark mode
- Assets are appropriately sized for cards and results
- Fallback placeholder for characters without custom assets
- All assets added to asset catalog

**Priority:** 4
**Dependencies:** 7
**Branch Suffix:** -character-assets

**Implementation Notes:**
- Use SF Symbols where possible for universes
- Consider abstract/stylized character representations
- Could use emoji as lightweight fallback
- Add to Assets.xcassets

---

## Implementation Order

```
Phase 1 - Tab Infrastructure (Parallel)
├── 1. Self-Discovery Tab Infrastructure
├── 2. Discovery Card Component
└── 7. Fictional Universe Data Model

Phase 2 - Feature Relocation (Sequential)
├── 3. Move Character Analysis to Self-Discovery (needs 1, 2)
├── 4. Move Future Letters to Self-Discovery (needs 1, 2)
├── 5. Move Wisdom Quotes to Settings
└── 6. Simplify Home Tab (needs 3, 4, 5)

Phase 3 - Character Quiz Backend (Sequential)
├── 8. Character Quiz Firebase Function (needs 7)
└── 9. Character Quiz Swift Service (needs 8)

Phase 4 - Character Quiz UI (Sequential)
├── 10. Character Quiz View (needs 2, 9)
└── 11. Character Result Card (needs 10)

Phase 5 - Polish (Parallel)
├── 12. Character Quiz History & Favorites (needs 10)
└── 13. Universe-Specific Character Assets (needs 7)
```

## Notes for Night Agent

- **Deep Quality Mode is ON** - This is a major UX rehaul affecting navigation patterns
- All new views should follow existing SwiftUI patterns (NavigationStack, @Observable)
- Preserve all existing functionality when relocating features
- The Self-Discovery tab should feel inviting and exploration-focused
- Character quiz should be fun and engaging, not overly serious
- Use consistent spacing, colors, and typography with existing app
- Test navigation flows thoroughly - especially back button behavior
- The character matching AI should provide thoughtful, personalized reasoning
- Consider accessibility throughout (VoiceOver, Dynamic Type)

## Supported Fictional Universes (Initial Launch)

1. **Lord of the Rings** - Frodo, Aragorn, Gandalf, Legolas, Gimli, Boromir, Sam, Gollum, Eowyn, Faramir
2. **Harry Potter** - Harry, Hermione, Ron, Dumbledore, Snape, Luna, Neville, Draco, Hagrid, McGonagall
3. **Star Wars** - Luke, Leia, Han, Obi-Wan, Yoda, Vader, Rey, Kylo, Ahsoka, Mandalorian
4. **Marvel** - Iron Man, Captain America, Thor, Black Widow, Spider-Man, Hulk, Black Panther, Scarlet Witch, Doctor Strange, Groot
5. **DC Comics** - Batman, Superman, Wonder Woman, Aquaman, Flash, Green Lantern, Joker, Harley Quinn, Alfred, Catwoman
6. **Game of Thrones** - Jon Snow, Daenerys, Tyrion, Arya, Cersei, Jaime, Sansa, Brienne, The Hound, Varys
7. **Narnia** - Aslan, Peter, Susan, Edmund, Lucy, White Witch, Reepicheep, Mr. Tumnus, Caspian, Puddleglum

## Character Matching Approach

The AI should analyze journal entries for:
- **Themes**: What topics does the user reflect on? (duty, adventure, relationships, power, justice)
- **Emotional patterns**: How do they process emotions? (introspective, action-oriented, empathetic)
- **Decision-making**: How do they approach choices? (logical, intuitive, values-driven)
- **Relationships**: How do they view connections with others? (loyal, independent, protective)
- **Growth mindset**: How do they handle challenges? (resilient, cautious, transformative)

Then map these patterns to character archetypes in each universe, providing specific reasoning tied to actual journal content.
