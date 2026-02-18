---
base_branch: feature/circle-pivot-3
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal

# Deep Quality Mode - enabled for full app pivot
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.8
deep_quality_review_gate: true
---

# Feature Queue: Circle — Voice-First Relationship Deepening App

## Context

> **This is a complete app pivot.** The Socratic journaling concept is being replaced entirely.
>
> **New product vision:** A voice-first app that deepens your closest relationships through
> AI-prompted daily questions and home screen widgets — replacing 25 minutes of scrolling with
> 5 minutes of hearing the voices of people who matter.
>
> **Core mechanic:**
> 1. You create a circle (2-5 people: partner, best friend, parent, sibling)
> 2. Every day, the AI sends everyone in the circle the same prompt
> 3. Each person responds with a 15-30 second voice note
> 4. Responses appear on your home screen widget (waveform + transcript snippet)
> 5. Tap to listen. Record yours. Done.
>
> **Why this works:** The AI prompt breaks social inertia (you'd never send "what went wrong
> today?" unprompted). The widget delivers connection passively. The bounded format means no
> conversation to maintain. The AI deepens prompts over weeks.

## CRITICAL: Local-First Architecture (NO Firebase Runtime Dependencies)

> **All features MUST be implemented with local/mock backends.**
> Firebase would block the night agent (auth config, emulator setup, security rules, cloud function
> deployment). Instead, every feature uses local persistence and mock services behind clean protocols.
>
> **The adapter pattern:**
> 1. Define a protocol in Domain/ (e.g., `AuthServiceProtocol`)
> 2. Implement a LOCAL version in Data/ (e.g., `LocalAuthService` using UserDefaults/SwiftData/files)
> 3. Wire the local version in the app entry point
> 4. Later, we swap in a `FirebaseAuthService` implementing the same protocol — zero UI changes needed
>
> **Persistence strategy:**
> - User data, circles, prompts, voice note metadata → **SwiftData** (or JSON files in app documents directory if SwiftData causes issues — the prior SwiftData attempt was reverted, so JSON files may be safer)
> - Voice note audio files → **local file system** (app documents directory: `voices/{circleId}/{promptId}/{userId}.m4a`)
> - User preferences/settings → **UserDefaults** (existing pattern)
> - Auth state → **UserDefaults** (simple mock: auto-logged-in local user, or basic local user creation)
>
> **DO NOT import or reference** FirebaseAuth, FirebaseStorage, or any new Firebase products.
> Keep existing Firebase imports (Analytics, Functions, Messaging, Firestore) only where they're
> already used in the reusable infrastructure. Do NOT add new Firebase usage.

## Reusable Infrastructure (DO NOT delete or rebuild)

- `StoreKitSubscriptionService` + `PaywallView` + `PaywallViewModel` — full StoreKit 2 subscription system
- `FirebaseAnalyticsService` + `AppsFlyerService` — analytics & attribution (already wired, keep as-is)
- `NetworkMonitor` + `OfflineSyncQueue` + `OfflineSyncHandler` — offline resilience
- `BackendHealthService` — backend health polling
- `ThemeManager` — light/dark/system theme support
- `AppEnvironment` + xcconfig pattern — emulator/production switching
- `UserDefaultsSettingsRepository` + `SettingsRepositoryProtocol` — local preferences
- `AnalyticsServiceProtocol` — keep protocol, update events later
- `SubscriptionServiceProtocol` + `Subscription.swift` entities — keep entirely
- `NotificationServiceProtocol` — keep protocol
- `LocalNotificationService` — keep for local notification scheduling
- `AppReviewService` — keep for review prompts

## What to Strip

- **Domain Entities:** JournalSession, Exchange, FutureLetter, BigFiveProfile, ClarityScore, FictionalCharacter, FictionalUniverse, PersonalityTrait, WisdomQuote, JournalExport, CharacterQuizHistoryEntry, JournalStats
- **Repository Protocols:** JournalRepositoryProtocol, CharacterQuizHistoryRepositoryProtocol, FictionalUniverseRepositoryProtocol
- **Service Protocols:** QuestionServiceProtocol, CharacterQuizServiceProtocol, ClarityScoreServiceProtocol, DataExportServiceProtocol, PersonalityAnalysisServiceProtocol, WisdomQuoteServiceProtocol, FirebaseFunctionsServiceProtocol
- **Data Implementations:** InMemoryJournalRepository, InMemoryDataSource, LocalCharacterQuizHistoryRepository, LocalFictionalUniverseRepository, FirebaseQuestionService, FirebaseFunctionsService, FirebaseCharacterQuizService, FirebasePersonalityAnalysisService, FirebaseWisdomQuoteService, LocalWisdomQuoteService, JSONDataExportService, MockCharacterQuizService, MockClarityScoreService, MockPersonalityAnalysisService, MockQuestionService
- **Presentation:** DialogueSession/, SessionComplete/, SessionHistory/, Letters/, CharacterQuiz/, CharacterDiscovery/, WisdomQuotes/, Statistics/, Export/, SelfDiscovery/ (entire folders)
- **Presentation/Navigation:** HomeTabView, SelfDiscoveryTabView, SelfDiscoveryViewModel, StatisticsTabView (keep MainTabView but gut it)
- **Presentation/Home:** HomeView, HomeViewModel (will be replaced)
- **Presentation/Onboarding:** All 4 onboarding screens (will be replaced)
- **Presentation/Components:** SessionListView, StartSessionButton, StatsCardView, CalendarView, CharacterAvatar, DiscoveryCard, LettersBadge, UniverseIcon (keep BackendStatusView)
- **Resources:** wisdom_quotes.json

## New Dependencies

- **NONE.** No new packages. No new Firebase products.
- Apple system frameworks (no package needed): AVFoundation, Speech, WidgetKit, AppIntents
- All persistence is local (SwiftData or JSON files + file system)

---

### 1. Strip Old Domain & Scaffold New Architecture

**User Story:** As a developer, I need the old Socratic Journal domain completely removed and replaced with the new Circle domain scaffold so the app compiles with the new data model.

**Acceptance Criteria:**
- All Socratic-specific files listed in "What to Strip" above are deleted
- New domain entities created as minimal Codable structs with core properties:
  - `CircleUser` — id (UUID), displayName, email (optional), avatarURL (optional), createdAt
  - `Circle` — id (UUID), name, emoji, creatorId, memberIds, createdAt, promptTime (Date components for hour/minute)
  - `CircleMember` — userId, displayName, avatarURL, joinedAt, role (enum: creator/member)
  - `DailyPrompt` — id (UUID), circleId, promptText, generatedAt, respondedUserIds, weekNumber
  - `VoiceNote` — id (UUID), circleId, promptId, userId, localAudioPath (String), duration (TimeInterval), transcript (optional String), createdAt
- New repository protocols created with full method signatures:
  - `AuthServiceProtocol` — signUp(name, email, password), signIn(email, password), signOut(), currentUser, authStateStream (AsyncStream)
  - `CircleRepositoryProtocol` — create(name, emoji), fetchAll() -> [Circle], fetch(id) -> Circle, join(inviteCode), leave(circleId), generateInviteCode(circleId) -> String
  - `VoiceNoteRepositoryProtocol` — save(VoiceNote), fetchForPrompt(promptId) -> [VoiceNote], delete(id)
  - `PromptRepositoryProtocol` — save(DailyPrompt), fetchToday(circleId) -> DailyPrompt?, fetchHistory(circleId) -> [DailyPrompt]
- New service protocols created with full method signatures:
  - `VoiceRecordingServiceProtocol` — startRecording(to: URL), stopRecording() -> URL, isRecording, currentDuration (published)
  - `TranscriptionServiceProtocol` — transcribe(audioURL: URL) async -> String?
  - `PromptGenerationServiceProtocol` — generatePrompt(circleId, weekNumber, recentPrompts) async -> String
- MainTabView replaced with a single-screen placeholder that displays "Circle" and compiles
- SocraticJournalApp.swift updated: remove old service initialization, keep analytics/subscription/network infra
- **NO changes to project.yml dependencies** — no new Firebase products added
- App compiles and runs showing a blank placeholder screen
- All kept infrastructure (subscriptions, analytics, theme, network) still works

**Priority:** 1
**Dependencies:** None

---

### 2. Local Authentication System

**User Story:** As a user, I want to create a local profile so the app knows who I am within my circles.

**Acceptance Criteria:**
- `LocalAuthService` implementing `AuthServiceProtocol`
- Local user profile stored in UserDefaults (JSON-encoded `CircleUser`)
- First launch: show a simple "Create Profile" screen — just display name (required) and optional avatar (photo picker storing image to app documents)
- No email/password — this is local-only for now (Firebase Auth swapped in later)
- `AuthState` as `@Observable` class: currentUser (CircleUser?), isAuthenticated (Bool)
- Auth state drives navigation: no profile → profile creation screen, has profile → main app
- Profile persists across app launches via UserDefaults
- Edit profile: change display name and avatar from settings
- Sign out = clear local profile (with confirmation)
- SocraticJournalApp.swift observes AuthState and routes accordingly
- **Adapter-ready:** `AuthServiceProtocol` has signUp/signIn/signOut signatures — LocalAuthService implements signUp by saving locally and ignores email/password params. When Firebase is added later, `FirebaseAuthService` implements the same protocol with real auth

**Priority:** 2
**Dependencies:** 1

---

### 3. Circle Creation & Management

**User Story:** As a user, I want to create a circle of my closest people and manage membership, all stored locally.

**Acceptance Criteria:**
- `LocalCircleRepository` implementing `CircleRepositoryProtocol`
- All circle data persisted as JSON files in app documents directory (`circles/` folder)
- Create Circle screen: name the circle, pick emoji from a curated list, auto-adds current user as creator
- Circle detail screen: see all members with display names and avatars
- Invite flow (local mock): generate a 6-character code, display it for sharing. Since there's no server, joining by code creates a **simulated member** (mock user with a name the creator types in). This lets us build and test the full UI flow
- "Add Member" flow: type a name to add a simulated member to the circle (since no real multi-device yet)
- Leave circle (with confirmation). Creator can remove members
- Max 5 members per circle enforced at creation and when adding
- A user can have multiple circles
- Circle list view: shows all user's circles with member count and emoji
- Empty state: "No circles yet" with prominent "Create Your First Circle" CTA
- **Adapter-ready:** When Firestore is added, `FirestoreCircleRepository` replaces `LocalCircleRepository` — same protocol, real persistence. The simulated members become real users fetched from Firestore

**Priority:** 3
**Dependencies:** 2

---

### 4. Voice Recording & Playback Engine

**User Story:** As a user, I want to record a 15-30 second voice note and play it back with a satisfying waveform experience.

**Acceptance Criteria:**
- `LocalVoiceRecordingService` implementing `VoiceRecordingServiceProtocol` using AVFoundation
- Recording: tap-to-start/tap-to-stop with live waveform animation during recording
- Duration enforcement: show elapsed timer, encourage minimum ~15 seconds, auto-stop at 30 seconds
- Audio format: AAC (.m4a), mono, 44.1kHz — optimized for voice
- Audio files saved locally: `{documentsDir}/voices/{circleId}/{promptId}/{userId}.m4a`
- Playback: AVAudioPlayer with play/pause, waveform visualization that animates with playback position
- Waveform data: extract amplitude samples from audio file for visual display (use AVAudioFile to read PCM buffers)
- Microphone permission: request on first record attempt, show helpful message if denied with "Open Settings" button
- Audio session: configure `.playAndRecord` category, handle interruptions gracefully
- Playback speed: 1x, 1.5x, 2x toggle
- `LocalVoiceNoteRepository` implementing `VoiceNoteRepositoryProtocol`: metadata as JSON files, audio files on disk
- **Adapter-ready:** When Firebase Storage is added, upload audio files there and store remote URLs. `VoiceNote.localAudioPath` becomes `audioURL` pointing to Firebase Storage

**Priority:** 4
**Dependencies:** 1

---

### 5. Daily Prompts Engine (Local)

**User Story:** As a user, I want to receive a thoughtful daily question for my circle, with prompts that feel progressively deeper over time.

**Acceptance Criteria:**
- `LocalPromptGenerationService` implementing `PromptGenerationServiceProtocol`
- Ships with a curated bank of ~60 prompts organized by depth tier:
  - **Tier 1 (Week 1-2, ~20 prompts):** Light and fun — "What made you smile today?", "What song has been stuck in your head?", "What's the best thing you ate this week?"
  - **Tier 2 (Week 3-4, ~20 prompts):** Medium depth — "What's something you wish you said this week?", "What's a small kindness someone showed you recently?", "What are you overthinking right now?"
  - **Tier 3 (Week 5+, ~20 prompts):** Deep connection — "What's something you've never told anyone in this group?", "What do you need right now that you haven't asked for?", "What would you do differently if you could relive this past year?"
- Prompt selection: picks from appropriate tier based on circle's age (weekNumber), avoids repeats of last 7 prompts
- `LocalPromptRepository` implementing `PromptRepositoryProtocol`: stores prompts as JSON in app documents
- Each circle gets one prompt per day. If no prompt exists for today, generate one on app open
- Prompt entity tracks: which members have responded (respondedUserIds)
- "Respond first to unlock" mechanic: user must record their voice note before hearing/seeing others' responses. UI shows locked state for unheard responses until user records
- Prompt history: view past prompts with response counts, tap to see/hear old responses
- **Adapter-ready:** When Cloud Functions are added, `CloudPromptGenerationService` calls the AI endpoint instead. The protocol is the same. The local prompt bank serves as fallback for offline mode

**Priority:** 5
**Dependencies:** 3, 4

---

### 6. Home Feed — The Daily Circle Experience

**User Story:** As a user, I want a simple home screen that shows today's prompt and my circle's voice responses, making it effortless to listen and respond in under 5 minutes.

**Acceptance Criteria:**
- Home screen layout:
  - Circle selector at top if user has multiple circles (horizontal pill/chip tabs with emoji + name)
  - Today's prompt card: large, prominent, warm typography, stands out as the hero element
  - Response status row: member avatars with checkmark overlay for responded, dimmed for waiting
  - If user hasn't responded: large, inviting "Record Your Answer" button with mic icon and pulse animation
  - If user has responded: scrollable list of voice note cards from circle members
- Voice note card design: member avatar, display name, mini waveform visualization, duration label, play button
- Tapping play starts inline playback with waveform animation tracking playback position
- "Play All" button: plays all circle responses back-to-back sequentially
- Locked state: before user responds, other members' cards show blurred/locked waveforms with "Record yours first to unlock" overlay
- "All caught up" state: warm, encouraging message when all notes are listened to
- Empty states: "Waiting for today's prompt" / "Be the first to respond!" / "No circles yet — create one"
- Pull-to-refresh (regenerates today's prompt if none exists)
- NavigationStack: drill into circle settings, prompt history, profile/settings
- HomeViewModel as `@Observable @MainActor` managing all state

**Priority:** 6
**Dependencies:** 5

---

### 7. Speech-to-Text Transcription

**User Story:** As a user, I want voice notes automatically transcribed so I can read them when I can't listen with audio.

**Acceptance Criteria:**
- `LocalTranscriptionService` implementing `TranscriptionServiceProtocol` using Apple Speech framework (SFSpeechRecognizer)
- Transcription runs on-device after recording completes (privacy-friendly, no cloud cost)
- Transcript stored as part of VoiceNote metadata in local JSON
- In-app: transcript snippet (~20 words) visible below each voice note card
- Tap to expand and read full transcript
- Speech recognition permission: request on first use, explain why ("See text versions of voice notes")
- Graceful fallback: if transcription fails, is denied, or device doesn't support it — voice note works fine without transcript, just no text shown
- Language detection: use device locale, English fallback
- Transcripts are used by the widget (Feature 10) for snippet display
- **Adapter-ready:** Transcript storage is just a String field on VoiceNote — works the same whether stored locally or in Firestore

**Priority:** 7
**Dependencies:** 4

---

### 8. New Onboarding Flow

**User Story:** As a new user, I want to understand what Circle is about and create my first circle in under 2 minutes.

**Acceptance Criteria:**
- 4-screen onboarding flow (TabView pager, matching existing swipe pattern):
  1. **Welcome:** "The people you love are one voice note away" — emotional hook, warm visual (illustration or gradient background with large type)
  2. **How It Works:** 3-step visual: "A question arrives" → "You record 30 seconds" → "You hear your people"
  3. **Create Your Circle:** Name your first circle, pick an emoji, add member names (simulated members for local mode). Skip option available
  4. **Ready:** "Your first question arrives tonight" — explanation of daily rhythm, continue button
- After onboarding: request notification permission (UNUserNotificationCenter) → land on home feed
- If user created a circle in step 3, they land on a home feed with their circle selected and today's prompt ready
- Onboarding state persisted via existing `hasCompletedOnboarding` pattern in UserDefaults
- Design: warm, human, not techy — large typography, soft rounded shapes, muted warm colors
- Accessible: VoiceOver labels, Dynamic Type support
- Works for new users (no profile yet → create profile inline or before onboarding)

**Priority:** 8
**Dependencies:** 3

---

### 9. Local Notifications

**User Story:** As a user, I want to be reminded when it's time to respond to today's prompt and hear from my circle.

**Acceptance Criteria:**
- Use `LocalNotificationService` (already exists) + UNUserNotificationCenter for all notifications
- Notification types (all local, no server needed):
  - **Daily prompt reminder:** "Today's question for [Circle Name] is ready" — scheduled at circle's prompt time
  - **Gentle nudge:** "Your circle is waiting to hear from you" — scheduled 3 hours after prompt if user hasn't responded
- Schedule notifications when:
  - Circle is created (schedule recurring daily prompt notification)
  - Prompt time is changed in settings (reschedule)
  - Circle is left/deleted (remove scheduled notifications)
- Deep link support: tapping notification opens app (basic — just opens to home feed)
- Per-circle mute toggle stored in UserDefaults
- Request notification permission during onboarding (step 4)
- Badge management: set badge count to number of unresponded prompts across circles
- **Adapter-ready:** When FCM is added, remote push replaces local scheduling for real-time "X responded" notifications. The notification types and deep link handling stay the same

**Priority:** 9
**Dependencies:** 5

---

### 10. Home Screen Widget (WidgetKit)

**User Story:** As a user, I want a home screen widget showing today's prompt and response snippets so connection surfaces without opening the app.

**Acceptance Criteria:**
- New WidgetKit extension target added to project.yml (`CircleWidget` target)
- App Group entitlement: `group.com.StudioNext.socraticJournal` for shared data between app and widget
- Shared data: main app writes today's prompt + response metadata to shared UserDefaults (App Group container) as JSON
- Widget sizes:
  - **Small:** Circle emoji + today's prompt text (truncated) + "3/4 answered" count
  - **Medium:** Prompt text + row of member initials/avatars with responded checkmarks
  - **Large:** Prompt text + transcript snippets (first ~15 words) from each member
- Tapping widget opens main app (deep link to home feed)
- TimelineProvider: update timeline when app enters background (write latest data + signal widget reload via WidgetCenter)
- Widget configuration: if user has multiple circles, use AppIntent to select which circle to display
- Placeholder/snapshot states for widget gallery
- Empty states: "Create a circle" / "Waiting for today's prompt"
- Design: warm rounded corners, readable typography, supports light and dark mode
- **Adapter-ready:** Widget reads from shared UserDefaults — doesn't care if the data came from local or Firestore. When we add real backend, main app just writes the same JSON from Firestore data instead

**Priority:** 10
**Dependencies:** 7, 6

---

### 11. Settings & Profile Screen

**User Story:** As a user, I want to manage my profile, circles, notifications, and preferences from a clean settings screen.

**Acceptance Criteria:**
- Profile section: avatar (photo picker, stored locally in documents dir), display name (editable), saved via LocalAuthService
- My Circles section: list of circles with emoji + member count, tap to view details, swipe to leave
- Prompt Time section: time picker to configure when daily prompts appear (per-circle or global default)
- Notifications section: global notification toggle + per-circle mute switches
- Subscription section: reuse existing PaywallView + SubscriptionService (update marketing copy for Circle branding)
- Voice Quality: standard / high quality recording preference (stored in UserDefaults)
- Theme: light/dark/system (reuse existing ThemeManager)
- About: app version, privacy policy link, terms link, feedback/support link
- Clear Local Data button (with confirmation — resets all circles, prompts, voice notes)
- Reuse SettingsRepositoryProtocol and UserDefaultsSettingsRepository for preferences
- SettingsViewModel as `@Observable @MainActor`
- **No "Sign Out" or "Delete Account" needed** — local auth doesn't need these. They'll be added when Firebase Auth is integrated

**Priority:** 11
**Dependencies:** 2, 9

---

### 12. Analytics Events Refresh

**User Story:** As a product team, we want Circle-specific analytics events wired in so we're ready to track engagement from day one.

**Acceptance Criteria:**
- Update `AnalyticsEvent` enum — remove all old Socratic events, add Circle events:
  - **Profile:** `profile_created`, `profile_edited`
  - **Circle:** `circle_created`, `circle_member_added`, `circle_left`, `circle_deleted`
  - **Prompts:** `prompt_generated`, `prompt_viewed`, `prompt_responded`, `prompt_skipped`
  - **Voice:** `voice_note_recorded` (with duration param), `voice_note_played`, `voice_note_replayed`, `voice_note_play_all`
  - **Transcript:** `transcript_viewed`, `transcript_expanded`
  - **Widget:** `widget_tapped`, `widget_configured`
  - **Onboarding:** `onboarding_step_viewed` (with step param), `onboarding_completed`, `onboarding_skipped`
  - **Notifications:** `notification_permission_granted`, `notification_permission_denied`, `notification_tapped`
- User properties: `circle_count`, `total_voice_notes_sent`, `current_streak_days`
- Key funnel: profile_created → onboarding_completed → circle_created → prompt_responded → voice_note_played
- Wire events into all new screens and ViewModels (call analyticsService.logEvent where appropriate)
- Existing FirebaseAnalyticsService implementation handles the logging — just update the event enum and add log calls

**Priority:** 12
**Dependencies:** 6

---

## Implementation Order

```
Phase 1 — Foundation
└── 1. Strip Old Domain & Scaffold New Architecture

Phase 2 — Identity & Social
├── 2. Local Authentication System (needs 1)
└── 3. Circle Creation & Management (needs 2)

Phase 3 — Core Mechanic (parallel where possible)
├── 4. Voice Recording & Playback (needs 1, can start parallel with 2-3)
├── 7. Speech-to-Text Transcription (needs 4)
└── 5. Daily Prompts Engine — Local (needs 3, 4)

Phase 4 — Experience
├── 6. Home Feed (needs 5)
├── 8. New Onboarding (needs 3)
└── 9. Local Notifications (needs 5)

Phase 5 — Surface & Polish
├── 10. Home Screen Widget (needs 6, 7)
├── 11. Settings & Profile (needs 2, 9)
└── 12. Analytics Events Refresh (needs 6)
```

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the app
xcodebuild build -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run tests
xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Notes for Night Agent

- **ALL BACKENDS ARE LOCAL/MOCK** — do NOT import FirebaseAuth, FirebaseStorage, or add any new Firebase products to project.yml. The existing Firebase imports (Analytics, Functions, Messaging, Firestore) stay only where already used in kept infrastructure
- **This is a PIVOT, not an enhancement** — aggressively delete old code. Don't try to adapt Socratic screens
- **Adapter pattern is key** — every service/repository has a protocol in Domain/ and a Local* implementation in Data/. Name implementations `Local*` (e.g., `LocalAuthService`, `LocalCircleRepository`, `LocalVoiceNoteRepository`). This makes it obvious what gets swapped when Firebase is integrated
- **Persistence options:** Use JSON files in the documents directory for circles, prompts, voice note metadata. Use UserDefaults for auth state and settings. Use the file system for audio files. Avoid SwiftData — a prior attempt was reverted (commit a900505), it caused issues
- **Voice recording is the heart of the app** — invest in a smooth, satisfying recording/playback UX with real waveform visualization
- **The "respond first to unlock" mechanic is critical** — this drives engagement. In local mode, simulate other members' responses with the mock members so the unlock flow can be demonstrated
- **Simulated members:** Since there's no real multi-device sync, circles will have "simulated members" that the user adds by name. Pre-record or generate mock voice notes for these members so the full listening experience works. Use bundled sample audio files or generate silence with metadata
- **Prompt bank:** Ship ~60 curated prompts in a JSON resource file organized by tier. No AI generation needed locally
- The kept infrastructure is production-tested — DO NOT rewrite subscriptions, analytics, or network monitoring
- Follow existing patterns: `@Observable @MainActor` ViewModels, protocol-based DI, Clean Architecture layers
- The WidgetKit extension (Feature 10) requires a NEW target in project.yml — this is the only feature that adds a build target
- Apple frameworks AVFoundation and Speech require no package additions
- Test audio features on a real device when possible — simulator audio can behave differently

## Future Firebase Integration Checklist (NOT for night agent — just documentation)

When ready to add real Firebase backends, swap these implementations:
- `LocalAuthService` → `FirebaseAuthService` (add FirebaseAuth product to project.yml)
- `LocalCircleRepository` → `FirestoreCircleRepository` (use existing Firestore)
- `LocalVoiceNoteRepository` → `FirestoreVoiceNoteRepository` + Firebase Storage (add FirebaseStorage product)
- `LocalPromptRepository` → `FirestorePromptRepository` (use existing Firestore)
- `LocalPromptGenerationService` → `CloudPromptGenerationService` (call new Cloud Function)
- Local notifications → FCM push notifications (already have FirebaseMessaging)
- All swaps happen at the DI wiring point in SocraticJournalApp.swift — zero UI changes needed
