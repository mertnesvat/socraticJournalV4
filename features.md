---
base_branch: feature/circle-pivot-2
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal

# Deep Quality Mode - full app pivot, every feature must be solid
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.8
deep_quality_review_gate: true
---

# Feature Queue: Circle — Voice-First Relationship Deepening App

## Product Vision

**One-liner:** A voice-first app that deepens your closest relationships through AI-prompted daily questions and home screen widgets — replacing 25 minutes of scrolling with 5 minutes of hearing the voices of people who matter.

**Core mechanic:**
- You create a circle (2-5 people: partner, best friend, parent, sibling)
- Every day, the AI sends everyone in the circle the same prompt
- Each person responds with a 15-30 second voice note
- Responses appear on your home screen widget (waveform + transcript snippet)
- Tap to listen. Record yours. Done.

**Why this works:**
- The AI prompt breaks social inertia (you'd never send "what went wrong today?" unprompted)
- The widget delivers connection passively (no app to open)
- The bounded format means no conversation to maintain
- The AI deepens prompts over weeks based on circle dynamics

**Target persona:** Jack, 34, PM, married to a night-shift nurse, 4yo daughter. 90 minutes of nightly scrolling, surrounded by surface interactions, marriage running on logistics.

## Pivot Context

This is a **full app pivot** from Socratic Journal (philosophical self-reflection journaling) to Circle (voice-first relationship deepening). The existing codebase structure (Clean Architecture) will be preserved but all Socratic-specific domain models, views, and services will be replaced.

**What we keep:**
- Clean Architecture structure (Domain/Data/Presentation layers)
- Project configuration (xcconfig, XcodeGen, entitlements)
- AppEnvironment setup
- StoreKit subscription service (already built — reuse as-is)

**What we replace:**
- All domain entities (JournalSession, Exchange, ClarityScore, etc.)
- All repositories and service protocols
- All presentation layer (views, view models, navigation)
- Onboarding flow

## CRITICAL: Mock-First Architecture

**DO NOT configure or depend on Firebase for any feature in this queue.**

All backend functionality (auth, data persistence, file storage, push notifications) must be implemented as **protocols in Domain** with **mock/in-memory/local implementations in Data**. This ensures:

1. The Night Agent can build and run the full app without Firebase setup
2. Other worktrees won't conflict on Firebase configuration
3. Firebase integration happens in a separate session by swapping adapters

**The pattern for EVERY backend service:**
```
Domain/Services/      → AuthServiceProtocol, CircleRepositoryProtocol, etc.
Data/Services/Mock/   → MockAuthService, InMemoryCircleRepository, etc.
```

When Firebase is integrated later, we simply add:
```
Data/Services/Firebase/ → FirebaseAuthService, FirestoreCircleRepository, etc.
```

**No code outside the Data layer changes.** This is the entire point.

**Mock data strategy:**
- Auth: auto-sign-in with a hardcoded mock user, support switching between 2-3 mock users to simulate circle members
- Circles: in-memory storage with pre-seeded sample circle ("Family Circle" with mock members)
- Voice notes: save/load audio files from app's Documents directory (local filesystem)
- Prompts: curated local prompt library (50+ prompts) with simple daily rotation logic
- Notifications: local notifications via UNUserNotificationCenter (no server needed)
- Profiles: in-memory with UserDefaults persistence

---

### 1. App Shell Reset & New Navigation

Strip all existing Socratic Journal features and create the new app shell with Circle's navigation structure. The app should compile and run with empty placeholder screens after this feature.

**User Story:** As a user, I want to open the app and see a clean, focused interface centered on my circles rather than journaling features.

**Acceptance Criteria:**
- All Socratic-specific domain models, views, and view models removed from the project
- New navigation structure: single main feed screen (no tab bar — circles are the focus)
- App entry point rewired to new root view
- App compiles and runs showing a placeholder "Circle" screen
- Existing infrastructure preserved: AppEnvironment, xcconfig setup, StoreKit service
- Remove unused Firebase service implementations (Firebase SDK can remain as dependency for now, just don't use it)
- Clean project structure ready for new features

**Priority:** 1
**Dependencies:** None

---

### 2. Circle Domain Layer

Create all new domain entities and protocols for the Circle app. This is the foundation everything else builds on. Protocols are designed so Firebase can be swapped in later without changing anything outside the Data layer.

**User Story:** As a developer, I need clean domain models and protocols that capture circles, members, voice notes, and daily prompts so the entire app can be built on this foundation.

**Acceptance Criteria:**
- `Circle` entity: id, name, emoji/color, members (2-5), createdBy, createdAt, inviteCode
- `CircleMember` entity: id, userId, displayName, avatarURL, joinedAt, role (owner/member)
- `VoiceNote` entity: id, circleId, promptId, authorId, audioURL (local file path or remote URL), duration, transcript, createdAt, waveformData (array of floats)
- `DailyPrompt` entity: id, circleId, question text, generatedAt, theme/category, responseCount
- `UserProfile` entity: id, displayName, avatarURL, circleIds, createdAt
- **Repository protocols (in Domain/Repositories/):**
  - `CircleRepositoryProtocol`: CRUD for circles, join/leave, fetch user's circles
  - `VoiceNoteRepositoryProtocol`: save/fetch/delete voice notes for a circle+prompt
  - `PromptRepositoryProtocol`: fetch today's prompt, fetch prompt history for circle
  - `UserProfileRepositoryProtocol`: CRUD for user profiles
- **Service protocols (in Domain/Services/):**
  - `AuthServiceProtocol`: signIn, signOut, currentUser, authStateStream — abstract enough for any auth provider
  - `AudioServiceProtocol`: record, stopRecording, play, stopPlayback, extractWaveform — local audio operations
  - `AudioStorageServiceProtocol`: upload audio file, download audio file, delete — abstract file storage
  - `PromptGenerationServiceProtocol`: generatePrompt(for circle) — abstract prompt generation
  - `TranscriptionServiceProtocol`: transcribe(audioURL) → String
  - `NotificationServiceProtocol`: requestPermission, scheduleLocal, handle received
- All types are Sendable, Codable, Equatable, Identifiable where appropriate
- Protocols use async/await and AsyncStream where appropriate

**Priority:** 2
**Dependencies:** Feature 1

---

### 3. Mock Auth & User Profile System

Implement a mock authentication system that simulates sign-in/sign-out with local users. The app should feel like it has real auth but everything is local. Protocol-based so Firebase Auth drops in later.

**User Story:** As a user, I want to have a profile identity in the app so I'm recognized in my circles — even though real server auth comes later.

**Acceptance Criteria:**
- `MockAuthService` implementing `AuthServiceProtocol`
- Auto-signs-in with a default mock user on app launch (no sign-in screen needed yet)
- 2-3 pre-built mock user profiles for simulating circle members ("You", "Sarah", "Mike")
- Current user stored in UserDefaults, persisted across launches
- Sign-out clears current user, sign-in restores
- `authStateStream` emits current user on subscribe and on changes
- `InMemoryUserProfileRepository` implementing `UserProfileRepositoryProtocol`
- User profile editing works (display name, avatar placeholder)
- Auth state drives root navigation (signed out → placeholder auth screen, signed in → feed)
- **No Firebase Auth dependency** — protocol is designed so `FirebaseAuthService` can replace `MockAuthService` later with zero changes to Domain or Presentation layers

**Priority:** 3
**Dependencies:** Feature 2

---

### 4. Voice Recording & Playback Engine

Build the core audio infrastructure: record bounded voice notes and play them back with waveform visualization. Audio files stored locally on device. This is the heart of the app and must feel polished.

**User Story:** As a user, I want to record a short voice note (15-30 seconds) and hear my circle members' voices with a visual waveform so the experience feels intimate and effortless.

**Acceptance Criteria:**
- `AudioService` implementing `AudioServiceProtocol` using AVAudioRecorder/AVAudioPlayer
- Record voice notes in compressed AAC format
- Enforced time bounds: minimum 5 seconds, maximum 60 seconds (sweet spot 15-30s guidance shown in UI)
- Real-time waveform visualization during recording (audio metering → normalized float array)
- Playback with animated waveform (synced to audio position)
- Audio session management (interruptions, route changes)
- Waveform data extraction from recorded audio file for static display in feed
- Microphone permission handling with clear rationale string
- Recording UI: tap-to-start/stop with visual timer countdown and waveform growing
- `LocalAudioStorageService` implementing `AudioStorageServiceProtocol`
  - Saves audio files to app's Documents directory
  - Organizes files by circle/prompt: `circles/{circleId}/{promptId}/{userId}.m4a`
  - Load/delete files from local storage
  - **No Firebase Storage** — protocol is designed so `FirebaseStorageService` replaces this later
- Pre-seed 2-3 sample audio files (can be short sine-wave or silence files) for mock circle member responses

**Priority:** 4
**Dependencies:** Feature 2

---

### 5. Circle Creation & Management

Let users create circles and manage their membership. All data stored in-memory with optional UserDefaults persistence. Protocol-based for Firestore swap later.

**User Story:** As a user, I want to create a circle with my closest people, give it a name, and manage who's in it so I have a dedicated space for meaningful connection.

**Acceptance Criteria:**
- `InMemoryCircleRepository` implementing `CircleRepositoryProtocol`
- Create a new circle: name, emoji/color picker, auto-generate invite code (local UUID-based)
- Pre-seeded sample circle on first launch ("Family Circle" with 2-3 mock members) so the app isn't empty
- View circle details: members list, circle name/emoji, invite code display
- Edit circle name/emoji (owner only)
- Leave a circle (with confirmation alert)
- Remove a member (owner only, with confirmation)
- Circle size enforced: 2-5 members
- Circle list view showing all user's circles with member avatars
- Data persisted to UserDefaults/JSON file so circles survive app restart
- **No Firestore** — `InMemoryCircleRepository` stores in memory + serializes to local JSON. `FirestoreCircleRepository` replaces it later with zero changes outside Data layer.

**Priority:** 5
**Dependencies:** Feature 3

---

### 6. Circle Invite System (Mock)

Simulate the invite flow locally. Real deep links and server-side validation come with Firebase integration. For now, the UI and flow should be fully built with mock join logic.

**User Story:** As a user, I want to experience the invite flow — generating a code, sharing it, and seeing someone join — so the full circle creation journey works end to end.

**Acceptance Criteria:**
- Generate a shareable invite code (6-character alphanumeric, locally generated)
- Share sheet integration (share the invite code text via UIActivityViewController)
- "Join Circle" screen where user enters an invite code
- Mock join logic: entering a valid code (from any created circle) adds current mock user to that circle
- Invite validation: circle exists, not full (5 max), not already a member
- Success state: show "You joined [Circle Name]!" with members
- Error states: invalid code, circle full, already a member
- **Deep links deferred** — real Universal Links come with Firebase. For now, share plain text invite codes.
- **No push notification on join** — local notification ("Welcome to [Circle Name]!") as placeholder

**Priority:** 6
**Dependencies:** Feature 5

---

### 7. Daily Prompt Engine (Local Library)

Build the prompt system using a curated local prompt library instead of AI generation. The prompt selection protocol is designed so an AI-powered Firebase Function drops in later.

**User Story:** As a user, I want to see a fresh, thoughtful question every day that my whole circle answers so we have a reason to connect.

**Acceptance Criteria:**
- `LocalPromptGenerationService` implementing `PromptGenerationServiceProtocol`
- Curated library of 50+ high-quality prompts organized by category:
  - **Reflective:** "What's one thing that went better than expected today?"
  - **Playful:** "What's a song that perfectly describes your week?"
  - **Vulnerable:** "What's something you've been avoiding saying out loud?"
  - **Nostalgic:** "What's a memory from childhood that still makes you smile?"
  - **Aspirational:** "What would you do this week if failure wasn't possible?"
  - **Gratitude:** "Who made your day better today, and why?"
- One prompt per circle per day, selected based on date + circleId hash (deterministic so all members see the same one)
- New circles start with icebreaker prompts (lower vulnerability, more playful)
- Prompt history tracked so no repeats within 50-day window
- `InMemoryPromptRepository` implementing `PromptRepositoryProtocol`
- Fetch today's prompt, fetch prompt history for a circle
- **No Firebase Functions** — `LocalPromptGenerationService` serves prompts from bundled library. `AIPromptGenerationService` (calling Firebase Function) replaces it later.

**Priority:** 7
**Dependencies:** Feature 5

---

### 8. Circle Feed — The Main Experience

Build the main screen where users see today's prompt, record their response, and listen to circle members' voice notes. This is the daily touchpoint and must feel beautiful and effortless. Uses mock data from previous features.

**User Story:** As a user, I want to open the app, see today's question, tap to record my answer, and then hear what my closest people said — all in under 5 minutes.

**Acceptance Criteria:**
- Feed shows today's prompt prominently at top (large, inspiring typography)
- Below prompt: circle members' response cards (avatar, name, waveform visualization, duration)
- Unlistened responses visually distinct from listened ones (dot indicator or opacity)
- Tap a response card to play voice note inline (waveform animates with playback progress)
- "Record your response" prominent CTA button if user hasn't responded yet
- Recording flow: tap CTA → recording screen → preview with playback → send (or re-record)
- Transcript snippet shown under each voice note waveform (first ~80 chars)
- Pull-to-refresh gesture
- Empty states: "Waiting for responses..." when no one has answered yet, with gentle prompt to share circle
- Multi-circle support: if user has multiple circles, show circle switcher (horizontal pills or tabs)
- Data loads from in-memory repositories (pre-seeded mock responses from mock members)
- **No Firestore listeners** — data refreshes from in-memory store on pull-to-refresh. Real-time Firestore listeners added with Firebase integration.

**Priority:** 8
**Dependencies:** Feature 4, Feature 7

---

### 9. Onboarding Flow

Create a new onboarding experience that explains Circle's concept and guides users to create their first circle. Uses mock auth — no real sign-in needed.

**User Story:** As a new user, I want to understand what Circle does in 30 seconds and create my first circle so I can start connecting.

**Acceptance Criteria:**
- 3-4 beautiful onboarding screens explaining the concept:
  1. "Hear the voices of people who matter" — concept introduction
  2. "One question, every day" — explain the daily prompt mechanic
  3. "Your circle, your people" — explain circles (2-5 closest people)
  4. "Get started" — transition to circle creation
- Skip button available on all screens
- After onboarding: guided circle creation flow (name → emoji → done)
- Prompt to share invite code after first circle created (share sheet)
- Skip option for invite sharing (can do later from circle settings)
- Microphone permission request with clear rationale ("Circle needs your microphone to record voice notes for your people")
- Notification permission request ("Get notified when your people respond")
- Onboarding completion saved to UserDefaults
- **No Sign In with Apple** — mock auth auto-signs in. Real auth screen added with Firebase integration.
- Beautiful, minimal design — visual-first, not text-heavy

**Priority:** 9
**Dependencies:** Feature 5, Feature 6

---

### 10. Local Notifications

Set up local notifications for daily prompt reminders and simulated "new response" alerts. No server needed — all scheduled locally.

**User Story:** As a user, I want to get a daily reminder to check today's prompt and hear from my circle, even before server push is set up.

**Acceptance Criteria:**
- `LocalNotificationService` implementing `NotificationServiceProtocol`
- Daily scheduled notification: "Today's question for [Circle Name] is ready" (configurable time, default 7pm)
- Permission request with rationale
- Notification tapping opens app (deep link to specific circle deferred)
- Notification settings: enable/disable, change reminder time
- Per-circle notification toggle
- **No Firebase Cloud Messaging** — all notifications are local UNUserNotificationCenter. FCM integration added later.

**Priority:** 10
**Dependencies:** Feature 7, Feature 8

---

### 11. Home Screen Widget

Build a WidgetKit widget that shows today's prompt and response previews on the home screen — passive connection delivery.

**User Story:** As a user, I want to see today's question and who has responded on my home screen so I feel connected at a glance without opening the app.

**Acceptance Criteria:**
- Small widget: today's prompt text with circle emoji
- Medium widget: today's prompt + response count ("3 of 4 responded") + member avatars
- Widget updates daily when new prompt is available (Timeline provider with daily refresh)
- Tapping widget opens app to circle feed
- "No responses yet" state when circle is quiet
- App Group for shared data between app and widget extension
- Widget configuration: choose which circle to display (if multiple)
- WidgetKit extension target added to project.yml
- Data shared via App Group UserDefaults (read from in-memory store, write to shared container)
- **Waveform in widget deferred** — show text + avatars for now. Waveform rendering in widget added as polish later.

**Priority:** 11
**Dependencies:** Feature 8

---

### 12. Voice Transcription

Add on-device speech-to-text transcription so voice notes have readable transcript snippets in the feed and widget. Fully local — no server dependency.

**User Story:** As a user, I want to see a text snippet of what someone said so I can decide if I want to listen now or save it for later.

**Acceptance Criteria:**
- `AppleTranscriptionService` implementing `TranscriptionServiceProtocol`
- Uses Apple Speech framework (SFSpeechRecognizer) — fully on-device, free, private
- Transcription runs after recording completes, before saving voice note
- Transcript stored in VoiceNote entity alongside audio
- Transcript snippet shown in feed cards (first ~80 characters + "...")
- Full transcript viewable by tapping/expanding a voice note card
- Speech recognition permission handling with rationale
- Fallback: if transcription fails or is denied, show duration only
- Support English initially
- **No server transcription** — Apple Speech framework is on-device. Cloud transcription (Whisper etc.) can be added later if needed.

**Priority:** 12
**Dependencies:** Feature 4

---

## Implementation Order

```
Phase 1 — Foundation
├── 1. App Shell Reset & New Navigation
└── 2. Circle Domain Layer (needs 1)

Phase 2 — Core Infrastructure (Parallel)
├── 3. Mock Auth & User Profile (needs 2)
├── 4. Voice Recording & Playback Engine (needs 2)
└── 12. Voice Transcription (needs 4) ← can start once audio engine exists

Phase 3 — Social Structure
├── 5. Circle Creation & Management (needs 3)
└── 6. Circle Invite System (needs 5)

Phase 4 — Daily Loop
└── 7. Daily Prompt Engine with Local Library (needs 5)

Phase 5 — The Experience
└── 8. Circle Feed (needs 4, 7)

Phase 6 — Growth & Retention (Parallel)
├── 9. Onboarding Flow (needs 5, 6)
├── 10. Local Notifications (needs 7, 8)
└── 11. Home Screen Widget (needs 8)
```

## Notes for Night Agent

### Architecture — Mock-First, Firebase-Later

- **DO NOT add any Firebase service implementations.** All backend logic uses mock/in-memory/local adapters.
- **DO NOT add FirebaseAuth or FirebaseStorage as SPM dependencies.** Existing Firebase deps (Analytics, Firestore, Functions, Messaging) can stay in project.yml but should not be imported in new code.
- **Every backend service follows the Protocol + Adapter pattern:**
  - Protocol in `Domain/Services/` or `Domain/Repositories/`
  - Mock/Local implementation in `Data/Services/` or `Data/Repositories/`
  - Firebase implementation added LATER in a separate session
- **Dependency injection at app entry point** — `SocraticJournalApp.swift` wires mock services. Swapping to Firebase means changing only the DI wiring.
- The goal is a **fully functional app that runs entirely on-device** with realistic mock data.

### General Guidelines

- **This is a FULL APP PIVOT** — strip all Socratic Journal features before building Circle features
- **Deep Quality Mode is ON** — this is the foundation of a new product, every feature must be solid
- **Keep the Clean Architecture pattern** — Protocol in Domain, Implementation in Data, Views+ViewModels in Presentation
- **MVVM with @Observable @MainActor** — follow existing ViewModel patterns
- **Voice is the core** — audio recording/playback quality is paramount
- **Bounded format is key** — enforce time limits on recordings, this is a feature not a limitation
- **Pre-seed realistic mock data** — the app should feel alive on first launch with sample circles, members, prompts, and voice notes
- **Bundle ID stays the same** — com.StudioNext.socraticJournal
- **New Xcode target needed for Feature 11** — Widget extension

### What Firebase Integration Looks Like Later (NOT part of this queue)

When we run Firebase integration in a separate session, we will:
1. Add `FirebaseAuthService` implementing `AuthServiceProtocol`
2. Add `FirestoreCircleRepository` implementing `CircleRepositoryProtocol`
3. Add `FirebaseStorageService` implementing `AudioStorageServiceProtocol`
4. Add `AIPromptGenerationService` implementing `PromptGenerationServiceProtocol` (calling Firebase Function)
5. Add `FCMNotificationService` implementing `NotificationServiceProtocol`
6. Update DI wiring in `SocraticJournalApp.swift` to use Firebase implementations
7. Add new Firebase Cloud Functions for prompt generation and push notifications
8. **Zero changes to Domain or Presentation layers**

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the app
xcodebuild build -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run tests
xcodebuild test -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
