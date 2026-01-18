---
base_branch: master
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.mertnesvat.SocraticJournal
action_logging: true
---

# Feature Queue: Onboarding Experience

Create an elegant, minimal onboarding flow that introduces new users to Socratic Journal. The onboarding should make a great first impression, explain the app's value proposition, and guide users to start their first session.

---

### 1. Onboarding Data & State Management

Set up the infrastructure for onboarding: track whether user has completed onboarding and provide content for screens.

**User Story:** As a new user, I want to see onboarding only on my first launch, so returning users go straight to the app.

**Acceptance Criteria:**
- User can launch app and see onboarding on first run
- User's onboarding completion status persists across app launches
- User who completed onboarding goes directly to home screen
- Onboarding state is stored in UserDefaults via SettingsRepository

**Priority:** 1
**Dependencies:** None

---

### 2. Onboarding Screen 1 - Welcome & Value Proposition

Create the first onboarding screen that welcomes users and introduces the core concept of Socratic journaling.

**User Story:** As a new user, I want to understand what this app does, so I know if it's right for me.

**Acceptance Criteria:**
- User sees a welcoming headline: "Know Thyself"
- User sees a supporting tagline explaining Socratic dialogue concept
- User sees an elegant, minimal illustration or icon representing self-reflection (use SF Symbols)
- Screen has smooth fade-in animation on appear
- User can swipe to next screen or tap continue
- User can tap "Skip" button in top-right corner to skip all onboarding

**Priority:** 1
**Dependencies:** 1

---

### 3. Onboarding Screen 2 - Guided Reflection Feature

Create the second onboarding screen that explains the dialogue session feature.

**User Story:** As a new user, I want to understand how the journaling works, so I know what to expect.

**Acceptance Criteria:**
- User sees headline about guided questions (e.g., "Thoughtful Questions")
- User sees explanation that the app asks meaningful questions to guide reflection
- User sees visual representation of the dialogue concept (question/answer flow)
- User sees mention of "Clarity Score" that measures reflection depth
- Screen maintains consistent styling with screen 1
- Smooth transition animation from previous screen

**Priority:** 1
**Dependencies:** 2

---

### 4. Onboarding Screen 3 - Discover Your Character

Create the third onboarding screen that introduces the personality discovery feature.

**User Story:** As a new user, I want to know about personality insights, so I'm excited about long-term value.

**Acceptance Criteria:**
- User sees headline about character discovery (e.g., "Discover Your Character")
- User sees explanation that journaling reveals personality traits over time
- User sees visual hint at the Big Five personality model (5 trait icons or abstract representation)
- User understands this unlocks with continued journaling
- Creates anticipation for the feature without overpromising

**Priority:** 1
**Dependencies:** 3

---

### 5. Onboarding Screen 4 - Letters to Future Self & Get Started

Create the final onboarding screen that mentions letters feature and has the call-to-action.

**User Story:** As a new user, I want a clear next step, so I can start using the app immediately.

**Acceptance Criteria:**
- User sees mention of "Letters to Future Self" feature
- User sees a brief explanation of time-locked letters concept
- User sees prominent "Begin Your Journey" or "Start First Session" button
- Button has elegant styling consistent with app's accent color
- Tapping button marks onboarding complete and navigates to home screen
- User can also tap skip to complete onboarding and go to home

**Priority:** 1
**Dependencies:** 4

---

### 6. Onboarding View Container & Navigation

Create the parent container view that manages all onboarding screens with paging.

**User Story:** As a new user, I want smooth navigation between onboarding screens, so the experience feels polished.

**Acceptance Criteria:**
- User sees page indicator dots showing current position (4 dots)
- User can swipe horizontally between screens
- User can tap continue/next button to advance
- Skip button visible on all screens except the last
- Page indicators update smoothly with swipe progress
- Transitions between pages are smooth and elegant
- Container handles both light and dark mode

**Priority:** 1
**Dependencies:** 2, 3, 4, 5

---

### 7. App Entry Point Integration

Integrate onboarding into the app's launch flow.

**User Story:** As a user, I want the app to show the right screen on launch based on my onboarding status.

**Acceptance Criteria:**
- App checks onboarding status on launch
- New users see OnboardingView as full-screen cover
- Returning users go directly to MainTabView
- Completing onboarding dismisses it and shows MainTabView
- Transition from onboarding to main app is smooth

**Priority:** 1
**Dependencies:** 1, 6

---

## Design Guidelines

**Visual Style:**
- Elegant and minimal - lots of whitespace
- Use SF Symbols for illustrations (brain.head.profile, text.bubble, person.fill, envelope.fill, etc.)
- Large, centered icons with subtle accent color tinting
- Clean typography using system fonts (.largeTitle for headlines, .body for descriptions)
- Subtle fade and slide animations

**Colors:**
- Follow existing app theme (system colors, accent color)
- Support both light and dark mode
- Use opacity for secondary text

**Layout:**
- Content centered vertically with generous padding
- Page dots at bottom with continue button
- Skip button in navigation area (top-right or as text button)

**Animations:**
- Fade-in on appear for each screen's content
- Smooth horizontal paging transition
- Subtle scale animation on CTA button

