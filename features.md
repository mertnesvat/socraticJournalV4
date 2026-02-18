---
base_branch: feature/circle-pivot-1
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal

# Deep Quality Mode
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.8
deep_quality_review_gate: true
---

# Feature Queue: Circle — Voice-First Relationship Deepening App

## Vision

**One-liner:** A voice-first app that deepens your closest relationships through AI-prompted daily questions and home screen widgets — replacing 25 minutes of scrolling with 5 minutes of hearing the voices of people who matter.

**Core Loop:**
1. You create a circle (2-5 people: partner, best friend, parent, sibling)
2. Every day, AI sends everyone in the circle the same prompt
3. Each person responds with a 15-30 second voice note
4. Responses appear on your home screen widget (waveform + transcript snippet)
5. Tap to listen. Record yours. Done.

**Why this works:** The AI prompt breaks social inertia (you'd never send "what went wrong today?" unprompted). The widget delivers connection passively (no app to open). The bounded format means no conversation to maintain. The AI deepens prompts over weeks.

**Target Persona:** Jack, 34, PM in Arizona, married to a night-shift nurse, 4yo daughter. 90 minutes nightly scrolling, surrounded by surface interactions, marriage runs on logistics, friendships on memes.

## Current State

This is a **complete pivot** from Socratic Journal (solo philosophical journaling) to Circle (multiplayer voice-first relationship deepening). The existing codebase provides:

- **Reusable:** Clean Architecture patterns (Domain protocols → Data implementations → Presentation MVVM), `@Observable @MainActor` ViewModel pattern, ThemeManager, XcodeGen build system, StoreKit 2 subscriptions
- **Strip away:** All journaling UI, dialogue sessions, character quizzes, personality analysis, wisdom quotes, self-discovery tab, statistics, letters, export, ALL Firebase service implementations
- **Build new:** Local auth, circle management, voice recording/playback, local prompt engine, circle feed, home screen widget, new onboarding

## Architecture Notes for Night Agent — LOCAL-FIRST, NO FIREBASE

**CRITICAL: This build must have ZERO Firebase runtime dependencies.** All features use local implementations behind clean protocols. Firebase can be swapped in later via protocol conformance — but nothing in this build should import Firebase, call Firestore, or require network connectivity to function.

**Pattern for every service:**
```
Domain/Services/SomeServiceProtocol.swift    ← Protocol (the contract)
Data/Services/LocalSomeService.swift         ← Local implementation (SwiftData, files, bundled JSON)
Data/Services/MockSomeService.swift          ← Mock for testing & previews
# FUTURE (not now):
Data/Services/FirebaseSomeService.swift      ← Firebase implementation (same protocol)
```

**Data persistence strategy:**
- **User profile & circles:** SwiftData (on-device database, iOS 17+)
- **Voice notes:** Local file storage in app's Documents directory
- **Prompts:** Bundled JSON file with 200+ curated prompts + local rotation logic
- **Transcripts:** Stored alongside voice note metadata in SwiftData
- **Settings/preferences:** UserDefaults (reuse existing pattern)

**What to REMOVE from the project:**
- All `Firebase*Service.swift` files in `Data/Services/`
- Firebase SPM dependencies from `project.yml` and `Package.swift` (FirebaseAnalytics, FirebaseFirestore, FirebaseFunctions, FirebaseMessaging)
- `GoogleService-Info.plist`
- `Firebase/` directory (Cloud Functions)
- All Firebase imports and configuration in `SocraticJournalApp.swift`
- AppsFlyer SDK and service
- Any `AppEnvironment.Firebase.*` references

**What to KEEP:**
- ThemeManager, XcodeGen build system, build configurations
- StoreKit 2 subscription system (it's already local/native)
- The Clean Architecture folder structure pattern
- `Configuration/` xcconfig files (strip Firebase variables)

**Dependency injection approach:**
- Create a simple `ServiceContainer` or `DependencyContainer` that holds protocol references
- Pass via SwiftUI `.environment()` — same pattern as existing ThemeManager
- ViewModels receive protocols via init injection
- Swapping to Firebase later = change one line in the container

**ViewModels use `@Observable @MainActor` pattern** — same as existing codebase.
**Minimum iOS 17.0** — leverage SwiftData, Observable macro, modern SwiftUI.
**Bundle ID stays** `com.StudioNext.socraticJournal`.

---

### 1. App Shell Reset & Circle Navigation

Strip ALL existing Socratic Journal code and create the new Circle app skeleton. Remove Firebase SDK entirely. This is a clean slate.

**User Story:** As a user opening Circle for the first time, I see a clean, focused app with a clear navigation structure that centers around my circles and today's prompt — not a cluttered journal app.

**Acceptance Criteria:**
- Remove ALL existing presentation layer views (dialogue sessions, character quiz, personality analysis, wisdom quotes, letters, statistics, export, self-discovery tab, onboarding)
- Remove ALL corresponding ViewModels, Domain entities, Domain protocols, and Data implementations that are Socratic Journal-specific
- Remove ALL Firebase dependencies: strip FirebaseAnalytics, FirebaseFirestore, FirebaseFunctions, FirebaseMessaging from `project.yml` SPM packages
- Remove `GoogleService-Info.plist`, `Firebase/` directory, all `Firebase*Service.swift` files
- Remove AppsFlyer SDK and `AppsFlyerService.swift`
- Remove Firebase configuration from `SocraticJournalApp.swift` app entry point
- Clean `AppEnvironment.swift` — remove all Firebase-related environment variables
- Clean xcconfig files — remove `FIREBASE_*` variables
- Keep: ThemeManager, StoreKit 2 subscription system, `Configuration/` folder structure, XcodeGen `project.yml` structure
- New navigation: single NavigationStack with a home screen as root
- Navigation destinations: Home (circle feed) → Circle Detail → Profile/Settings
- Placeholder views for each screen (real implementations come in later features)
- App launches to home screen showing "Create your first circle" empty state
- Warm, intimate color palette (not the existing Socratic blue/purple — think amber, warm grey, cream)
- Create `ServiceContainer` with protocol-based dependency injection, passed via `.environment()`
- App should build and run cleanly with ZERO Firebase imports after this feature

**Priority:** 1
**Dependencies:** None

---

### 2. Local Authentication & User Profiles

Create a local user identity system so the app knows who you are. No Firebase Auth — just on-device user profile with SwiftData.

**User Story:** As a user, I set up my name and optional profile photo on first launch so other circle members can see who I am when they listen to my voice notes.

**Acceptance Criteria:**
- `AuthServiceProtocol` with: `currentUser`, `signIn(name:)`, `signOut()`, `deleteAccount()`, `isAuthenticated: Bool`
- `User` entity: `id` (UUID), `displayName`, `avatarImageData` (optional), `createdAt`
- `LocalAuthService` implementation using SwiftData for persistence
- On first launch: simple profile setup screen (enter name, optional photo from camera roll)
- Auth state persists across app launches via SwiftData
- Profile edit screen accessible from settings: change name, change/remove photo
- Initials avatar generated automatically when no photo is set (e.g., "JD" for "John Doe")
- Sign out clears local data, returns to profile setup
- Delete account removes all local data
- Auth gate: no-profile users see setup screen, profiled users see home
- `MockAuthService` for SwiftUI previews and tests

**Priority:** 2
**Dependencies:** Feature 1

---

### 3. Circle Creation & Management

The core social unit — create a circle and manage its members. All data stored locally in SwiftData.

**User Story:** As a user, I can create a circle with a name (e.g., "Family", "College Crew") and see my circles listed, so I have a defined group to share voice notes with.

**Acceptance Criteria:**
- `CircleServiceProtocol` with: `createCircle(name:icon:)`, `getCircles()`, `getCircle(id:)`, `updateCircle(...)`, `deleteCircle(id:)`, `addMember(...)`, `removeMember(...)`
- `Circle` entity in SwiftData: `id` (UUID), `name`, `emojiIcon`, `createdAt`, members relationship
- `CircleMember` entity: `id`, `displayName`, `avatarImageData`, `joinedAt`, `isCurrentUser: Bool`
- `LocalCircleService` implementation backed by SwiftData
- Circle list view showing all circles with member count and emoji icon
- Create circle flow: name + emoji picker
- Circle detail view: see members with avatars, circle settings
- Edit circle: rename, change emoji
- Delete circle with confirmation
- For this local-only build: "members" are created locally as placeholder profiles (e.g., user adds "Sarah" with initials — simulating what would be real users later)
- Maximum 5 members per circle (including yourself)
- Empty state when no circles exist: warm CTA to create first one
- `MockCircleService` for previews and tests

**Priority:** 3
**Dependencies:** Feature 2

---

### 4. Circle Member Addition Flow

How you add people to your circle in the local-only build. Simulates the future invite system.

**User Story:** As a user, I can add members to my circle by entering their name, so I can start building my group even before the multiplayer backend exists.

**Acceptance Criteria:**
- "Add member" button in circle detail view
- Simple form: enter name, optional emoji/avatar
- Member appears in circle immediately
- Remove member with swipe-to-delete
- Cannot exceed 5 members per circle
- Each added member gets a simulated "voice note" capability (for the feed to work in demo mode, see Feature 8)
- Future adapter note: this flow will be replaced by invite links + real user lookup when backend is added
- Share sheet with "Invite to Circle" message (prepopulated text about the app — plants the seed even without deep links)

**Priority:** 4
**Dependencies:** Feature 3

---

### 5. Voice Recording Engine

The core input mechanism — recording short voice notes with a beautiful, confidence-building interface.

**User Story:** As a user, I can record a 15-30 second voice note response to today's prompt with a simple tap-and-talk interface that shows me a live waveform so I feel engaged, not awkward.

**Acceptance Criteria:**
- `VoiceRecordingServiceProtocol` with: `startRecording()`, `stopRecording() -> VoiceNote`, `cancelRecording()`, `isRecording: Bool`, `currentAmplitude: Float` (for waveform)
- `VoiceNote` entity: `id` (UUID), `fileURL` (local path), `duration`, `createdAt`, `circleId`, `promptId`, `userId`
- `LocalVoiceRecordingService` using AVFoundation (`AVAudioRecorder`)
- Tap-to-record button with animated state (idle → recording → done)
- Live waveform visualization during recording (sample audio levels → animated bars/wave)
- Recording timer showing elapsed seconds
- Minimum 5 seconds, maximum 60 seconds (visual nudge at 30s: "that's perfect!" without stopping)
- Playback preview after recording — listen back, re-record if not happy, or confirm
- Audio format: AAC/M4A saved to app's Documents directory
- Microphone permission request with warm explanation ("Circle needs your mic to record voice notes for your people")
- Add `NSMicrophoneUsageDescription` to Info.plist
- Works with AirPods/Bluetooth audio routing
- Haptic feedback on record start/stop
- Voice notes stored locally: `Documents/VoiceNotes/{circleId}/{date}/{noteId}.m4a`
- `MockVoiceRecordingService` that returns pre-recorded samples for previews

**Priority:** 5
**Dependencies:** Feature 1

---

### 6. Voice Note Playback & Local Storage

Play back voice notes with a polished audio experience. Everything stored and served from local files.

**User Story:** As a user, I can listen to voice notes with smooth playback and waveform visualization, hearing the warmth of real voices.

**Acceptance Criteria:**
- `VoicePlaybackServiceProtocol` with: `play(voiceNote:)`, `pause()`, `stop()`, `seek(to:)`, `isPlaying: Bool`, `currentTime: TimeInterval`, `duration: TimeInterval`
- `LocalVoicePlaybackService` using AVFoundation (`AVAudioPlayer`)
- Playback with waveform visualization (generate waveform data from audio file on save)
- Play/pause toggle with smooth animation
- Scrubbing via drag on waveform
- Speaker name and initials avatar shown alongside waveform
- Audio session configuration: plays through speaker, respects silent mode toggle, mixes with other audio appropriately
- Pre-generate waveform amplitude data when voice note is saved (store as `[Float]` array in metadata)
- Voice note metadata stored in SwiftData: links to local file path, duration, waveform data, transcript (if available)
- Handle missing/deleted files gracefully
- `MockVoicePlaybackService` for previews

**Priority:** 6
**Dependencies:** Feature 5

---

### 7. Local Daily Prompt Engine

A fully local prompt system using a curated, bundled prompt library. No cloud functions needed.

**User Story:** As a circle member, I see a fresh, thoughtful daily prompt that sparks genuine reflection — prompts that feel warm and specific, not generic icebreaker energy.

**Acceptance Criteria:**
- `PromptServiceProtocol` with: `getTodaysPrompt(for circleId:) -> Prompt`, `getPromptHistory(for circleId:) -> [Prompt]`, `markPromptSeen(id:)`
- `Prompt` entity: `id`, `text`, `category`, `depth` (1-5 scale), `dateAssigned`, `circleId`
- `LocalPromptService` that selects from a bundled JSON prompt library
- Bundled `prompts.json` with 200+ curated prompts organized by category and depth:
  - Categories: gratitude, reflection, vulnerability, shared memories, future hopes, daily moments, playful, nostalgia
  - Depth levels: 1 (light/safe) → 3 (moderate) → 5 (deep/vulnerable)
- Prompt selection logic: no repeats within 90 days per circle, alternates categories, progresses depth over weeks
- One prompt per circle per day (determined by date + circle ID as seed for consistency)
- Prompt visible on home screen with warm typography and "Record your response" CTA
- Prompt history view: see past prompts with dates
- Example prompts at various depths:
  - Depth 1: "What made you laugh today?"
  - Depth 2: "What's a small thing someone did for you recently that meant more than they know?"
  - Depth 3: "What's something you've been carrying this week that you haven't told anyone?"
  - Depth 4: "When was the last time you felt truly understood by someone?"
  - Depth 5: "What do you wish you could say to someone in this circle but haven't found the words?"
- `MockPromptService` for previews and tests

**Priority:** 7
**Dependencies:** Feature 3

---

### 8. Circle Response Feed

The main screen users interact with daily — see today's prompt and play responses.

**User Story:** As a user opening the app, I immediately see today's prompt and who has responded, with a simple flow to listen to everyone and record my own — all in under 5 minutes.

**Acceptance Criteria:**
- `ResponseServiceProtocol` with: `getResponses(circleId:date:) -> [VoiceResponse]`, `saveResponse(voiceNote:prompt:)`, `markAsHeard(responseId:)`
- `VoiceResponse` entity: `id`, `voiceNote` (relationship), `prompt` (relationship), `member` (relationship), `isHeard: Bool`, `createdAt`
- `LocalResponseService` backed by SwiftData
- Home screen layout:
  - Top: today's prompt in warm, readable typography
  - Middle: response cards for each circle member — avatar, name, waveform mini-preview, duration badge
  - Bottom: "Record yours" floating CTA button
- Visual indicator for unheard responses (subtle glow or badge dot)
- Tap a response card → plays that voice note inline (no navigation, stays on feed)
- Sequential playback option: play all responses in order (auto-advance)
- Show who has responded vs. who hasn't (grey avatar for pending, without guilt language)
- If user has multiple circles: segment control or horizontal pill selector at top
- Past days accessible via horizontal date scroller
- Pull-to-refresh gesture (for future backend sync — locally just re-fetches from SwiftData)
- Empty state: "No responses yet today. Be the first!" with record CTA
- For demo/local mode: include 2-3 sample voice notes bundled with the app so the feed isn't empty on first launch (attributed to sample members)

**Priority:** 8
**Dependencies:** Feature 6, Feature 7

---

### 9. Speech-to-Text Transcription

Transcribe voice notes using on-device Apple Speech for text snippet previews.

**User Story:** As a user, I can see a brief text transcript of each voice note so I can preview what someone said and so deaf/HoH users can participate fully.

**Acceptance Criteria:**
- `TranscriptionServiceProtocol` with: `transcribe(audioURL:) async -> String?`
- `LocalTranscriptionService` using Apple `Speech` framework (`SFSpeechRecognizer`) — fully on-device
- Add `NSSpeechRecognitionUsageDescription` to Info.plist
- Transcription runs automatically after recording completes (before user confirms send)
- Transcript stored in SwiftData alongside voice note metadata
- Show first ~15 words as snippet preview on response cards in the feed
- Full transcript available via tap/expand on the response card
- Fallback: if transcription fails or user denies permission, show "Voice note • [duration]" placeholder — never block the flow
- Language: English initially
- `MockTranscriptionService` that returns sample text for previews

**Priority:** 9
**Dependencies:** Feature 6

---

### 10. Local Notifications

Drive the daily habit loop with scheduled local notifications. No push notification server needed.

**User Story:** As a user, I get a gentle daily reminder with the prompt so I remember to participate, even without a backend sending push notifications.

**Acceptance Criteria:**
- `NotificationServiceProtocol` with: `scheduleDailyPrompt(circle:time:)`, `cancelNotifications(circle:)`, `requestPermission() -> Bool`
- `LocalNotificationService` using `UNUserNotificationCenter` (fully local, no FCM)
- Daily scheduled notification at user-configurable time (default: 6 PM)
- Notification content: "Today's Circle question: [prompt snippet]" with circle emoji
- Notification tap opens app to today's prompt
- Per-circle notification settings: enable/disable, custom time
- Notification permission request during onboarding with warm explanation
- Badge count management: increment on new prompt day, clear when app opens
- Respect system notification settings
- `MockNotificationService` for tests
- Remove Firebase Cloud Messaging dependency entirely

**Priority:** 10
**Dependencies:** Feature 7

---

### 11. Home Screen Widget

The passive connection surface — see your circle's responses without opening the app.

**User Story:** As a user, I glance at my home screen and see a transcript snippet from someone I love, tap it and hear their voice — replacing the Instagram widget with something that actually makes me feel connected.

**Acceptance Criteria:**
- New WidgetKit extension target added to `project.yml` (XcodeGen)
- App Group entitlement for data sharing between app and widget extension
- Small widget (2x2): Circle emoji + name + latest response snippet (member name + first ~10 words of transcript)
- Medium widget (4x2): Today's prompt text + 2-3 response previews with member names and transcript snippets
- Tap any widget → opens app to today's prompt feed
- Timeline provider refreshes when app writes new response data to shared container
- Shared data format: JSON file in App Group container (lightweight, no SwiftData in widget)
- Widget shows warm empty state if no responses yet: "Waiting for voices..." with circle name
- Widget configuration intent: user chooses which circle to display
- Warm visual design matching app palette — not default widget grey
- Add `SocraticJournal.entitlements` App Group + update widget target entitlements

**Priority:** 11
**Dependencies:** Feature 8, Feature 9

---

### 12. Circle Onboarding Experience

A warm, story-driven onboarding that explains the concept and gets users to create their first circle.

**User Story:** As a new user, I understand what Circle does and why it matters within 30 seconds, and I'm guided to create my first circle and add someone before I can overthink it.

**Acceptance Criteria:**
- 3-4 screen onboarding flow (not more — respect the user's time)
- Screen 1: The problem — "Your closest people are one scroll away, but somehow unreachable"
- Screen 2: The solution — "One question. Their voice. Every day."
- Screen 3: How it works — visual showing: prompt arrives → you record → you listen → connection deepens
- Screen 4: Profile setup (enter name, optional photo) → flows into "Create your first circle"
- Skip option available but discouraged (no skip button until screen 3)
- Warm color palette and micro-animations (scale, fade — not bouncy/playful)
- After profile setup: immediately guided to create first circle and add a member
- First prompt appears immediately after circle creation (don't make them wait until tomorrow)
- Onboarding completion saved in UserDefaults
- Analytics events (local, logged to console for now): `onboarding_screen_viewed(screen:)`, `onboarding_completed`, `onboarding_skipped(at_screen:)`
- `hasCompletedOnboarding` flag gates onboarding display

**Priority:** 12
**Dependencies:** Feature 2, Feature 3

---

### 13. Local Prompt Intelligence — Depth Progression

The prompt engine gets smarter about pacing and depth over time, all computed locally.

**User Story:** As a long-term user, I notice the prompts getting more personal and meaningful over weeks — they start light and safe, then gradually invite deeper sharing as the circle builds trust.

**Acceptance Criteria:**
- Extend `LocalPromptService` with depth progression logic
- Depth progression based on circle age and response consistency:
  - Week 1-2: Depth 1-2 only (light, safe, fun)
  - Week 3-4: Depth 1-3 (introduce moderate vulnerability)
  - Week 5-8: Depth 1-4 (deeper reflection)
  - Week 9+: Full range 1-5 (deep, specific)
- Category rotation: never repeat same category two days in a row
- Energy alternation: if yesterday was deep/heavy, today should be lighter (and vice versa)
- "Circle streak" tracking: consecutive days where at least one member responded
- Streak visible in circle detail view (warm visualization, not gamified/pressuring)
- If circle goes dormant (3+ days no responses from anyone), next prompt auto-selects depth 1 (re-engagement: light, easy, nostalgic)
- Thumbs up/down on daily prompts — stored locally, influences future category weighting
- All logic runs locally using circle metadata from SwiftData (creation date, response history, feedback)

**Priority:** 13
**Dependencies:** Feature 7

---

## Implementation Order

```
Phase 1 — Clean Slate
└── 1. App Shell Reset (strip ALL old code + Firebase, new navigation skeleton)

Phase 2 — Identity
└── 2. Local Auth & User Profiles (SwiftData, no Firebase Auth)

Phase 3 — Social Core
├── 3. Circle Creation & Management (SwiftData)
└── 4. Circle Member Addition (local member profiles)

Phase 4 — Voice Engine
├── 5. Voice Recording Engine (AVFoundation, local files)
└── 6. Voice Playback & Local Storage (AVAudioPlayer, SwiftData metadata)

Phase 5 — Daily Loop
├── 7. Local Prompt Engine (bundled JSON, local rotation logic)
└── 8. Circle Response Feed (main screen, ties it all together)

Phase 6 — Enhancement
├── 9. Speech-to-Text Transcription (Apple Speech, on-device)
├── 10. Local Notifications (UNUserNotificationCenter, no FCM)
└── 11. Home Screen Widget (WidgetKit, App Group shared data)

Phase 7 — Polish
├── 12. Circle Onboarding Experience
└── 13. Local Prompt Intelligence (depth progression)
```

## Notes for Night Agent

### ZERO FIREBASE — THIS IS THE #1 RULE

- **Do NOT import any Firebase framework.** No `import FirebaseAuth`, no `import FirebaseFirestore`, no `import FirebaseFunctions`, no `import FirebaseMessaging`, no `import FirebaseAnalytics`.
- **Remove Firebase SPM packages** from `project.yml` in Feature 1. The app must build with zero Firebase dependencies.
- **Remove `GoogleService-Info.plist`** and the `Firebase/` directory.
- **Remove AppsFlyer** SDK and service as well.
- Every service follows the protocol adapter pattern: `Protocol → LocalImplementation`. Future Firebase implementations will conform to the same protocols.

### Local-First Architecture

- **SwiftData** for all structured data (users, circles, members, prompts, responses, transcripts)
- **File system** for voice note audio files (`Documents/VoiceNotes/...`)
- **Bundled JSON** for the prompt library (`prompts.json` in Resources)
- **UserDefaults** for lightweight settings and flags (onboarding, notification prefs)
- **App Group container** for widget data sharing (JSON file)

### Protocol Adapter Pattern

Every service must have a clean protocol so Firebase (or any backend) can be plugged in later with zero UI changes:

```
Protocol (Domain) → Local impl (Data) → ViewModel uses protocol only
```

Create a `ServiceContainer` or `AppDependencies` struct that holds all protocol references. Initialize with local implementations. Inject via SwiftUI `.environment()`. Swapping to Firebase later = change container initialization, nothing else.

### Other Guidelines

- **This is a FULL PIVOT** — aggressively delete old Socratic Journal code in Feature 1. Don't preserve backwards compatibility.
- **Voice is core** — recording and playback must feel premium. Smooth waveforms, responsive controls, zero lag.
- **Widget is the secret weapon** — invest in making it beautiful and reliable.
- **Zero-friction design** — every interaction should take fewer taps than expected.
- **Include sample data** — bundle 2-3 sample voice notes and a demo circle so the app isn't empty on first launch. The feed should look alive.
- **Minimum iOS 17.0** — use SwiftData, Observable macro, modern SwiftUI, WidgetKit enhancements.
- **Bundle ID stays** `com.StudioNext.socraticJournal`.

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the app
xcodebuild build -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run tests
xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
