---
base_branch: feature/ux-rehaul-3
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.StudioNext.socraticJournal
action_logging: true

# Deep Quality Mode enabled for UX rehaul
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.7
deep_quality_review_gate: true
---

# Feature Queue: Socratic Journal UX Rehaul - Self-Discovery Update

## Overview

Major UX restructuring to create a dedicated "Self-Discovery" tab consolidating personality analysis features, adding the new "Which Character Am I" quiz, and relocating features for better user experience.

**Current State:**
- 2 main tabs: Home, Statistics
- Character Analysis accessible via Home toolbar modal
- Wisdom Library accessible via Home toolbar modal
- Future Letters accessible via Home toolbar modal

**Target State:**
- 3 main tabs: Home, Self-Discovery, Statistics
- Character Analysis embedded in Self-Discovery tab
- "Which Character Am I" quiz feature in Self-Discovery tab
- Future Letters relocated to Self-Discovery tab
- Wisdom Library removed from prominent navigation (accessible via Settings if needed)

---

### 1. Create Self-Discovery Tab Structure

Create a new third tab called "Self-Discovery" in the main tab navigation.

**User Story:** As a user, I want a dedicated space for self-discovery features so I can easily access personality insights and character quizzes in one place.

**Acceptance Criteria:**
- New "Self-Discovery" tab appears as the second tab (between Home and Statistics)
- Tab uses appropriate icon (e.g., `sparkles` or `person.crop.circle.badge.questionmark`)
- Tab label displays "Discover" or "Self-Discovery"
- Tab view has a consistent header design matching other tabs
- Empty state shows inviting message about self-discovery features
- Tab view uses ScrollView for vertical content

**Implementation Notes:**
- Modify `MainTab` enum in `MainTabView.swift` to add `.selfDiscovery` case
- Create new `SelfDiscoveryTabView.swift` in Navigation folder
- Update tab order: Home → Self-Discovery → Statistics
- Ensure smooth transition animations

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -self-discovery-tab

---

### 2. Migrate Character Analysis to Self-Discovery Tab

Move the existing Character Analysis (Big Five personality) feature from the Home toolbar modal to be the primary section in the Self-Discovery tab.

**User Story:** As a user, I want to find my personality analysis in a dedicated self-discovery area rather than hidden in the toolbar.

**Acceptance Criteria:**
- Character Discovery section is prominently displayed in Self-Discovery tab
- Full functionality preserved: unlock progress, trait visualization, evidence quotes
- Remove the Character Discovery button from Home toolbar
- Big Five personality chart is visible when unlocked
- User can still refresh analysis from Self-Discovery tab
- Navigation feels native (no modal, integrated into tab)
- Trait detail sheets still work when tapping individual traits

**Implementation Notes:**
- Embed `CharacterDiscoveryView` content directly in `SelfDiscoveryTabView`
- May need to refactor `CharacterDiscoveryView` into reusable components
- Keep `CharacterDiscoveryViewModel` logic intact
- Remove `showingCharacterDiscovery` state from `HomeTabView`
- Consider creating `CharacterAnalysisSection.swift` for clean composition

**Priority:** 1
**Dependencies:** 1
**Branch Suffix:** -migrate-character-analysis

---

### 3. Create Character Quiz Data Models and Service Protocol

Create the data models and service protocol for the "Which Character Am I" quiz feature.

**User Story:** As a developer, I need data models to support character matching from multiple franchises with confidence scores.

**Acceptance Criteria:**
- `FictionalCharacter` entity: name, franchise, description, imageAssetName, personalityTraits
- `CharacterQuizResult` entity: franchise, matches (array of character + percentage + explanation), analyzedAt, journalEntriesUsed
- `CharacterMatchEntry` entity: character, confidencePercentage, explanation (based on journal evidence)
- `Franchise` enum: lordOfTheRings, harryPotter, starWars (expandable)
- `CharacterQuizServiceProtocol` defined in Domain layer
- Character trait mappings for initial franchises

**Implementation Notes:**
- Place entities in `Domain/Entities/`
- Place protocol in `Domain/Services/CharacterQuizServiceProtocol.swift`
- Franchise enum should have display name and icon properties
- Character data can be embedded in app or loaded from JSON

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -character-quiz-models

---

### 4. Create Firebase Function for Character Matching

Implement the backend AI function to analyze journal entries and match to fictional characters.

**User Story:** As a user, I want accurate and insightful character matches based on my actual journal content.

**Acceptance Criteria:**
- New Firebase function `analyzeCharacterMatch` created
- Function accepts: journal entries (questions + answers), selected franchise
- Function returns: top 3 character matches with percentages and explanations
- Percentages represent confidence levels (don't need to sum to 100%)
- Explanations reference specific journal themes (not verbatim quotes for privacy)
- Response time under 45 seconds
- Graceful error handling with descriptive error codes

**Implementation Notes:**
- Create function in `Firebase/functions/src/index.ts`
- Add character mappings service in `Firebase/functions/src/services/characters.ts`
- **Lord of the Rings characters:** Aragorn, Frodo, Gandalf, Legolas, Gimli, Boromir, Sam, Gollum, Eowyn, Galadriel
- **Harry Potter characters:** Harry, Hermione, Ron, Dumbledore, Snape, Luna, Neville, Draco, McGonagall, Hagrid
- **Star Wars characters:** Luke, Leia, Han Solo, Obi-Wan, Yoda, Anakin, Rey, Kylo Ren, Padmé, Ahsoka
- Use GPT-4o-mini with character personality descriptions
- Follow existing function patterns (timeout, error handling, logging)

**Priority:** 1
**Dependencies:** None (can develop in parallel)
**Branch Suffix:** -character-match-function

---

### 5. Create Character Quiz Swift Service

Implement the Swift service to call the character matching Firebase function.

**User Story:** As a developer, I need a service layer to communicate with the character quiz backend.

**Acceptance Criteria:**
- `FirebaseCharacterQuizService` implements `CharacterQuizServiceProtocol`
- Service calls `analyzeCharacterMatch` Firebase function
- Proper error handling for timeout, network, and backend errors
- Timeout set to 60 seconds (extended for complex analysis)
- Mock implementation for testing/preview
- Service follows existing singleton pattern

**Implementation Notes:**
- Place implementation at `Data/Services/FirebaseCharacterQuizService.swift`
- Create `MockCharacterQuizService.swift` for SwiftUI previews
- Follow pattern from `FirebasePersonalityAnalysisService`
- Use `@unchecked Sendable` shared singleton pattern

**Priority:** 2
**Dependencies:** 3, 4
**Branch Suffix:** -character-quiz-service

---

### 6. Create Character Quiz UI - Franchise Selection

Create the franchise selection interface for the "Which Character Am I" quiz.

**User Story:** As a user, I want to choose which fictional universe to be matched with so I can discover my character in my favorite franchise.

**Acceptance Criteria:**
- User sees available franchises: Lord of the Rings, Harry Potter, Star Wars
- Each franchise has recognizable icon or imagery
- Clear tap targets for selection
- Selected franchise is highlighted
- "Analyze Me" button initiates the quiz
- Unlock requirement similar to Character Analysis (minimum journal entries)
- Progress indicator shows if more entries needed

**Implementation Notes:**
- Create `CharacterQuiz/` folder in Presentation
- `CharacterQuizView.swift` - Main container view
- `FranchiseSelectionView.swift` - Grid or list of franchises
- `CharacterQuizViewModel.swift` - State management, unlock logic
- Use SF Symbols or custom icons for franchises
- Consider using similar unlock formula as Character Analysis

**Priority:** 2
**Dependencies:** 3, 5
**Branch Suffix:** -character-quiz-ui

---

### 7. Create Character Quiz Results UI

Create the results display showing character matches with confidence percentages.

**User Story:** As a user, I want to see my character matches displayed in an engaging way with explanations for why I match each character.

**Acceptance Criteria:**
- Primary match (highest confidence) displayed prominently
- Shows character name with large confidence percentage (e.g., "75% Boromir")
- Brief explanation of why user matches this character
- Secondary matches shown below with smaller display
- All 3 matches visible with their percentages and explanations
- Franchise branding/theming applied to results
- Share functionality to create shareable image
- Save result option

**Implementation Notes:**
- `CharacterQuizResultView.swift` - Main results display
- `CharacterMatchCard.swift` - Individual character match component
- Consider animated reveal for delight (confetti optional)
- Use gradient or themed colors per franchise
- Store results in repository for history

**Priority:** 2
**Dependencies:** 5, 6
**Branch Suffix:** -quiz-results-ui

---

### 8. Add Character Quiz Section to Self-Discovery Tab

Integrate the Character Quiz feature into the Self-Discovery tab.

**User Story:** As a user, I want to access the character quiz alongside my personality analysis in the Self-Discovery tab.

**Acceptance Criteria:**
- Character Quiz section appears below Character Analysis in Self-Discovery tab
- Section shows available franchises with "Try it" call-to-action
- If quiz has been taken, shows most recent result with "Retake" option
- Clear visual separation between sections
- Consistent styling with Character Analysis section

**Implementation Notes:**
- Add `CharacterQuizSection.swift` component
- Embed in `SelfDiscoveryTabView` below character analysis
- Use NavigationLink or sheet for quiz flow
- Consider collapsible/expandable section design

**Priority:** 2
**Dependencies:** 2, 6, 7
**Branch Suffix:** -quiz-in-discovery

---

### 9. Remove Wisdom Screen from Top Navigation

Remove the Wisdom Quotes button from the Home toolbar as part of the UX simplification.

**User Story:** As a user, I want a cleaner home screen that focuses on my journaling without extra buttons cluttering the toolbar.

**Acceptance Criteria:**
- Wisdom Quotes button removed from Home toolbar
- Wisdom Library accessible through Settings > Wisdom Library (preserved for users who want it)
- Daily wisdom quote still appears in session completion flow
- No broken navigation or dead ends
- Settings row uses "Wisdom Library" label with book icon

**Implementation Notes:**
- Remove `showingWisdomQuotes` state and button from `HomeTabView`
- Add "Wisdom Library" row in `SettingsView` (new section if needed)
- Keep wisdom quote integration in session completion flow
- Remove wisdom-related onboarding content if present

**Priority:** 2
**Dependencies:** None
**Branch Suffix:** -remove-wisdom-nav

---

### 10. Relocate Future Letters to Self-Discovery Tab

Move the Future Letters feature to the Self-Discovery tab for better organization.

**User Story:** As a user, I want to find my future letters in a dedicated self-discovery space rather than hunting for them in the toolbar.

**Acceptance Criteria:**
- Future Letters section appears in Self-Discovery tab
- Badge count for ready-to-open letters visible in section
- "Write New Letter" call-to-action clearly visible
- Tap on section opens letters list (existing `LettersListView`)
- Remove letters button from Home toolbar
- If letters are ready to open, consider subtle indicator on Self-Discovery tab icon

**Implementation Notes:**
- Add `FutureLettersSection.swift` component
- Embed in `SelfDiscoveryTabView` as third section
- Remove `showingLetters` state from `HomeTabView`
- Consider showing preview of most recent letter or ready count
- Tab badge for ready letters (optional enhancement)

**Priority:** 2
**Dependencies:** 1
**Branch Suffix:** -relocate-letters

---

### 11. Add Quiz History and Retake Functionality

Allow users to view their past character quiz results and retake quizzes.

**User Story:** As a user, I want to see how my character matches have changed over time and retake quizzes with new franchises.

**Acceptance Criteria:**
- Quiz history section shows past results
- Each result shows franchise, primary match, date taken
- Tap on result shows full details (all 3 matches with explanations)
- Can retake quiz for any franchise
- Clear indication that new journal entries may change results
- Results persist across app restarts

**Implementation Notes:**
- `CharacterQuizResultRepository` for persistence
- Store in UserDefaults (matching other feature patterns)
- `QuizHistoryView.swift` for list display
- Add "entries used" count to show data freshness

**Priority:** 3
**Dependencies:** 7, 8
**Branch Suffix:** -quiz-history

---

### 12. Self-Discovery Tab Section Navigation and Polish

Create cohesive navigation and visual hierarchy within the Self-Discovery tab.

**User Story:** As a user, I want to easily navigate between different self-discovery features with clear visual organization.

**Acceptance Criteria:**
- Clear visual sections for: Character Analysis, Character Quiz, Future Letters
- Section headers with descriptive titles and icons
- Smooth scrolling between sections
- Each section has clear call-to-action
- Consistent card styling across sections
- Pull-to-refresh to update analysis data

**Implementation Notes:**
- ScrollView with LazyVStack for performance
- Section headers using consistent style component
- Consider subtle dividers between sections
- Loading states for each section independently

**Priority:** 3
**Dependencies:** 2, 8, 10
**Branch Suffix:** -discovery-polish

---

### 13. Update Onboarding for New Navigation

Update the onboarding flow to reflect the new Self-Discovery tab and features.

**User Story:** As a new user, I want onboarding to accurately show me where to find personality features in the app.

**Acceptance Criteria:**
- Onboarding page 2 (Character) updated to reference Self-Discovery tab
- Mention of Character Quiz feature as additional discovery tool
- Navigation hints point to correct tab location
- Remove any references to toolbar buttons that no longer exist

**Implementation Notes:**
- Update `OnboardingCharacterView.swift`
- Update copy to mention "Self-Discovery tab"
- Consider adding "Which Character Am I" teaser

**Priority:** 3
**Dependencies:** 1, 2, 8
**Branch Suffix:** -update-onboarding

---

## Dependency Graph

```
Feature 1 (Self-Discovery Tab) ────┬──→ Feature 2 (Migrate Character Analysis) ──→ Feature 8 (Quiz in Discovery)
                                   │                                                       ↑
                                   ├──→ Feature 10 (Relocate Letters)                      │
                                   │                                                       │
                                   └──→ Feature 12 (Polish) ←──────────────────────────────┤
                                                                                           │
Feature 3 (Quiz Models) ──→ Feature 5 (Quiz Service) ──→ Feature 6 (Quiz Selection UI) ───┤
        ↑                           ↑                              │                       │
        │                           │                              └──→ Feature 7 (Results UI)
        │                           │                                          │
Feature 4 (Firebase Function) ──────┘                              Feature 11 (Quiz History) ←┘

Feature 9 (Remove Wisdom) ──→ Independent

Feature 13 (Update Onboarding) ──→ Depends on 1, 2, 8
```

## Execution Order Recommendation

**Phase 1 (Foundation - Parallel):**
1. Feature 1: Create Self-Discovery Tab Structure
2. Feature 3: Create Character Quiz Data Models
3. Feature 4: Create Firebase Function for Character Matching
4. Feature 9: Remove Wisdom Screen from Navigation

**Phase 2 (Migration):**
5. Feature 2: Migrate Character Analysis to Self-Discovery
6. Feature 10: Relocate Future Letters to Self-Discovery
7. Feature 5: Create Character Quiz Swift Service

**Phase 3 (New Feature):**
8. Feature 6: Character Quiz UI - Franchise Selection
9. Feature 7: Character Quiz Results UI
10. Feature 8: Add Character Quiz Section to Self-Discovery

**Phase 4 (Polish):**
11. Feature 11: Quiz History and Retake
12. Feature 12: Self-Discovery Tab Polish
13. Feature 13: Update Onboarding

---

## Notes for Night Agent

### Bundle & App Info
- **Bundle ID:** `com.StudioNext.socraticJournal`
- **Architecture:** Clean Architecture with MVVM presentation
- **iOS Target:** 17.0+

### Key Files to Modify
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` - Add new tab
- `Sources/SocraticJournal/Presentation/Navigation/HomeTabView.swift` - Remove toolbar buttons
- `Sources/SocraticJournal/Presentation/CharacterDiscovery/` - Refactor for embedding

### Key Folders to Create
- `Sources/SocraticJournal/Presentation/CharacterQuiz/` - New quiz feature
- `Sources/SocraticJournal/Presentation/SelfDiscovery/` - Tab sections

### Pattern References
- Follow `CharacterDiscoveryViewModel` for AI service integration with unlock logic
- Follow `FirebasePersonalityAnalysisService` for Firebase function calls
- Follow `FutureLetter` entity pattern for new quiz result persistence

### Character Data for Quiz
**Lord of the Rings:**
- Aragorn (leadership, duty, hidden identity)
- Frodo (burden-bearing, resilience, innocence)
- Gandalf (wisdom, guidance, sacrifice)
- Sam (loyalty, optimism, humble courage)
- Boromir (internal conflict, redemption, honor)
- Legolas (grace, friendship, skill)
- Gimli (stubbornness, loyalty, humor)
- Eowyn (defiance, hidden strength, longing)
- Galadriel (power, temptation, ancient wisdom)
- Gollum (obsession, duality, tragedy)

**Harry Potter:**
- Harry (bravery, destiny, sacrifice)
- Hermione (intellect, preparation, loyalty)
- Ron (friendship, insecurity, humor)
- Dumbledore (wisdom, secrets, greater good)
- Snape (complexity, hidden depths, redemption)
- Luna (uniqueness, acceptance, intuition)
- Neville (growth, courage, underestimation)
- Draco (conflict, privilege, fear)

**Star Wars:**
- Luke (hope, growth, redemption)
- Leia (leadership, determination, compassion)
- Han Solo (charm, independence, hidden heart)
- Obi-Wan (wisdom, sacrifice, duty)
- Yoda (patience, teaching, perspective)
- Anakin (passion, conflict, fall/redemption)
- Rey (discovery, belonging, power)
- Kylo Ren (conflict, legacy, choice)

### Testing Notes
- Ensure unlock progress calculations work after Character Analysis migration
- Test quiz flow with mock service before Firebase integration
- Verify no regressions in existing Character Discovery functionality
- Test accessibility/VoiceOver in new tab
