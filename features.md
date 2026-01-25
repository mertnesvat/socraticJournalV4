---
base_branch: master
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.mertnesvat.SocraticJournal
action_logging: true

# Deep Quality Mode (enabled for Firebase integration - critical backend services)
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.7
deep_quality_review_gate: true
---

# Feature Queue: Firebase Functions Integration for Socratic Journal

## Context

The app was previously built with Flutter and Firebase Functions. Now it's rewritten as a native Swift app. The Firebase Functions backend is already deployed and functional (see `Firebase/functions/`), but the Swift app is not yet connected to these cloud functions.

**Available Firebase Functions:**
- `generateClarityMirror` - AI reflection on user's journal answer
- `generateFollowUpQuestion` - Socratic follow-up question generation
- `generateSocratesReaction` - Character reaction to user responses
- `analyzePersonality` - Big Five personality profile from journal entries
- `healthCheck` - Backend health monitoring

**Swift App Status:**
- Uses Clean Architecture with MVVM
- Firebase SDK already integrated (Analytics, Messaging, Firestore, Functions dependencies exist)
- Currently uses mock/local services for AI features
- Protocol-based dependency injection pattern established

---

### 1. Create Firebase Functions Service Layer

Create a centralized Firebase Functions service in Swift that handles all cloud function calls with proper error handling, retry logic, and timeout management.

**User Story:** As a developer, I want a robust Firebase Functions service so that all AI features can reliably communicate with the backend.

**Acceptance Criteria:**
- FirebaseFunctionsService class created following existing service patterns (Sendable singleton)
- Service handles Firebase Functions callable invocations
- Proper error types defined for network failures, timeout, and backend errors
- Configurable timeout settings (default 30 seconds matching backend)
- Logging for debugging API calls
- Service protocol defined in Domain layer

**Priority:** 1
**Dependencies:** None
**Branch Suffix:** -firebase-service

**Technical Notes:**
- Place protocol at: `Domain/Services/FirebaseFunctionsServiceProtocol.swift`
- Place implementation at: `Data/Services/FirebaseFunctionsService.swift`
- Follow pattern from `FirebaseAnalyticsService` (shared singleton, @unchecked Sendable)
- Use `Functions.functions().httpsCallable()` pattern

---

### 2. Integrate Clarity Mirror AI Generation

Connect the dialogue session to the `generateClarityMirror` Firebase function so users receive AI-generated empathetic reflections after each answer.

**User Story:** As a user, I want to receive thoughtful AI-generated reflections on my journal answers so that I feel understood and validated.

**Acceptance Criteria:**
- User completes answering a Socratic question
- App calls `generateClarityMirror` function with question, answer, and previous exchanges
- AI-generated mirror text is displayed to the user
- Graceful fallback to local mock if network fails
- Loading state shown while waiting for AI response
- Mirror text is saved with the Exchange entity

**Priority:** 1
**Dependencies:** 1
**Branch Suffix:** -clarity-mirror

**Integration Points:**
- Update `DialogueSessionViewModel` to call Firebase function
- Modify `Exchange` entity if needed to store mirror response
- Add clarity mirror display in `DialogueSessionView`

---

### 3. Integrate Follow-Up Question Generation

Connect the dialogue flow to the `generateFollowUpQuestion` Firebase function for dynamic, contextual Socratic questions.

**User Story:** As a user, I want follow-up questions that respond to what I've shared so that the journaling feels like a real conversation.

**Acceptance Criteria:**
- After user answers, app calls `generateFollowUpQuestion` with context
- AI-generated question replaces static question list (for questions 2-3)
- First question remains from curated starter set
- Fallback to local question bank if network fails
- Question appears naturally in dialogue flow
- Previous exchanges sent for context continuity

**Priority:** 1
**Dependencies:** 1
**Branch Suffix:** -followup-questions

**Integration Points:**
- Update `QuestionServiceProtocol` to support remote generation
- Create `FirebaseQuestionService` implementation
- Modify `DialogueSessionViewModel` question flow

---

### 4. Integrate Socrates Character Reactions

Connect to the `generateSocratesReaction` Firebase function to bring the Socrates character to life with contextual reactions.

**User Story:** As a user, I want Socrates to react naturally to my responses so that the experience feels more engaging and personal.

**Acceptance Criteria:**
- After each user answer, app calls `generateSocratesReaction`
- Reaction text displayed alongside the AI character
- Reactions describe Socrates' body language/expressions (e.g., "Socrates strokes his beard thoughtfully")
- Fallback to local reaction set if network fails
- Reactions cached/saved with session data

**Priority:** 2
**Dependencies:** 1
**Branch Suffix:** -socrates-reactions

**Integration Points:**
- Add reaction display component in dialogue UI
- Store reactions in `Exchange` entity
- Create animated/visual representation if desired

---

### 5. Integrate Personality Analysis

Connect to the `analyzePersonality` Firebase function to generate Big Five personality profiles from journal entries.

**User Story:** As a user who has journaled multiple times, I want to see an AI-generated personality profile so that I can gain insights into my character traits.

**Acceptance Criteria:**
- User with 5+ journal sessions can request personality analysis
- App calls `analyzePersonality` with journal history
- Big Five profile (OCEAN) displayed with scores and descriptions
- Evidence from journal entries shown for each trait
- Profile saved locally and can be viewed later
- Loading state during analysis (may take longer ~60s)
- Clear messaging if insufficient journal entries

**Priority:** 2
**Dependencies:** 1
**Branch Suffix:** -personality-analysis

**Integration Points:**
- Replace `MockPersonalityAnalysisService` with Firebase implementation
- Update `CharacterDiscoveryView` and its ViewModel
- Ensure `BigFiveProfile` entity matches backend response format

---

### 6. Add Offline Mode & Sync Queue

Create a queuing system for Firebase function calls when offline, automatically syncing when connection returns.

**User Story:** As a user with intermittent connectivity, I want to continue journaling offline and have my sessions enhanced with AI when I'm back online.

**Acceptance Criteria:**
- User can complete full journal sessions offline
- Pending AI requests queued locally
- Queue processes automatically when connectivity returns
- User notified when AI enhancements are added to past sessions
- No data loss during offline periods
- Sessions work seamlessly whether online or offline

**Priority:** 2
**Dependencies:** 2, 3, 4
**Branch Suffix:** -offline-sync

**Technical Notes:**
- Consider using Firestore for persistence + sync
- Implement network reachability monitoring
- Queue should persist across app restarts

---

### 7. Create Backend Health Monitoring

Implement health check functionality to verify backend availability and provide appropriate user feedback.

**User Story:** As a user, I want clear feedback when AI features are unavailable so that I understand why and can still use the app.

**Acceptance Criteria:**
- App checks `healthCheck` endpoint on launch
- Backend status cached and refreshed periodically
- UI indicates when AI features are degraded/unavailable
- Automatic failover to local services when backend is down
- No crashes or hangs if backend is unreachable

**Priority:** 3
**Dependencies:** 1
**Branch Suffix:** -health-monitoring

---

### 8. Add Firebase Function for Wisdom Quote Generation

Create a new Firebase function that generates contextual wisdom quotes based on user's recent journal themes.

**User Story:** As a user, I want wisdom quotes that relate to what I've been journaling about so that they feel more personally meaningful.

**Acceptance Criteria:**
- New Firebase function `generateWisdomQuote-nightprep` created
- Function analyzes recent journal themes
- Returns contextually relevant philosophical quote
- Includes quote source/attribution when available
- Swift service integration to call this function
- Fallback to local quote database if unavailable

**Priority:** 3
**Dependencies:** 1
**Branch Suffix:** -wisdom-quotes

**Technical Notes:**
- Create function in `Firebase/functions/src/index.ts`
- Add service in `Firebase/functions/src/services/`
- Follow existing function patterns (timeout, error handling)
- Use branch suffix `-nightprep` for the function name

---

### 9. Add Firebase Function for Session Summary Generation

Create a new Firebase function that generates a brief summary of a completed journal session.

**User Story:** As a user, I want a summary of my journal session so that I can quickly recall what I explored.

**Acceptance Criteria:**
- New Firebase function `generateSessionSummary-nightprep` created
- Function takes completed session with all exchanges
- Returns 2-3 sentence summary of session themes
- Summary highlights key insights and emotions explored
- Swift integration to call after session completion
- Summary displayed on session completion screen
- Summary saved with JournalSession entity

**Priority:** 3
**Dependencies:** 1
**Branch Suffix:** -session-summary

**Technical Notes:**
- Create function with `-nightprep` suffix
- Follow existing OpenAI integration patterns
- Consider token limits for summary generation

---

### 10. Add Firebase Function for Letter Enhancement

Create a new Firebase function that enhances Future Letters with AI-generated reflection prompts.

**User Story:** As a user writing a letter to my future self, I want thoughtful prompts to guide my reflection so that my letters are more meaningful.

**Acceptance Criteria:**
- New Firebase function `enhanceFutureLetter-nightprep` created
- Function suggests reflection prompts based on letter content
- Returns 2-3 thought-provoking questions for the user
- Swift integration in letter composition flow
- Prompts displayed as optional writing aids
- Works without disrupting manual letter writing

**Priority:** 4
**Dependencies:** 1
**Branch Suffix:** -letter-enhancement

**Technical Notes:**
- Create function with `-nightprep` suffix
- Integrate with `LetterWritingView` and ViewModel
- Make prompts optional/dismissable

---

## Implementation Order

```
1. Firebase Functions Service Layer (foundation)
   |
   +-- 2. Clarity Mirror Integration
   |
   +-- 3. Follow-Up Question Integration
   |
   +-- 4. Socrates Reactions Integration
   |
   +-- 5. Personality Analysis Integration
   |       |
   |       +-- 6. Offline Mode & Sync Queue
   |
   +-- 7. Health Monitoring (parallel)
   |
   +-- 8. Wisdom Quote Function (parallel)
   |
   +-- 9. Session Summary Function (parallel)
   |
   +-- 10. Letter Enhancement Function (parallel)
```

## Notes for Night Agent

- All new Firebase functions should have `-nightprep` suffix to avoid conflicts with other branches
- Follow existing Clean Architecture patterns (Protocol in Domain, Implementation in Data)
- Use `@unchecked Sendable` and `shared` singleton pattern for services
- Ensure fallback to mock services on any failure
- Test with Firebase emulator if possible before deployment
- Consider rate limiting on client side to avoid excessive API calls
- All services should be injectable for testing

## Existing Backend Reference

The Firebase Functions are located at `Firebase/functions/src/`:
- `index.ts` - Function exports (generateClarityMirror, generateFollowUpQuestion, generateSocratesReaction, analyzePersonality, healthCheck)
- `services/openai.ts` - OpenAI integration for most functions
- `services/personality.ts` - Personality analysis service

Model used: `gpt-4o-mini` with Firebase secrets for API key management.
