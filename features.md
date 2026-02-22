---
base_branch: feature/big-pivot-1
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.StudioNext.socraticJournal
action_logging: true

# Deep Quality Mode (enabled for this critical pivot)
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.7
deep_quality_review_gate: true
---

# Feature Queue: Socratic — Social Voice Opinion Platform (Big Pivot)

> **Context:** This is a MAJOR PIVOT from a solo journaling app to a social voice-opinion platform.
> The app "Socratic" asks controversial/thought-provoking questions daily. Users record voice answers,
> add friends, and unlock friends' answers only after recording their own ("Answer to Unlock" mechanic).
>
> **CRITICAL INSTRUCTIONS FOR NIGHT AGENT:**
> - This is a pivot — you are REPLACING most existing screens, not adding to them
> - KEEP all Firebase infrastructure, analytics service, StoreKit, push notifications, theme system, network monitor
> - DELETE/REPLACE: Dialogue session views, Letters feature, Character Quiz, Statistics, Wisdom Quotes, Onboarding
> - Use JSON mock data for ALL backend/Firebase calls — create MockDataService files with realistic static JSON
> - Do NOT implement real Firebase Cloud Functions or Firestore queries — mock everything
> - Audio recording should use AVAudioRecorder/AVAudioEngine with real iOS APIs (not mocked)
> - Navigation: Redesign MainTabView for new tab structure
> - The app should feel like a Gen Z social app — bold typography, dark theme default, minimal chrome, high contrast
> - Bundle ID stays: com.StudioNext.socraticJournal
> - Minimum iOS 17.0 target stays

---

### 1. Domain Layer Pivot — New Entities, Protocols & Mock Data Foundation

Replace the journaling domain with social voice-opinion domain models. This is the foundation everything else builds on.

**User Story:** As a developer, I need clean domain models and mock data so all features can build on a solid foundation.

**Acceptance Criteria:**

New Entity files to CREATE in `Sources/SocraticJournal/Domain/Entities/`:
- `User.swift` — id, displayName, username, avatarURL, createdAt, streakCount, friendCount
- `Friendship.swift` — id, userId, friendId, status (pending/accepted/blocked), createdAt
- `DailyQuestion.swift` — id, text, category (iceBreaker/gettingSpicy/deepDive/debateTrigger), level (1-4), isActive, createdAt, globalResponseCount, disagreementRatio
- `VoiceAnswer.swift` — id, questionId, userId, audioURL (local file path for now), duration, createdAt, isListened
- `AnswerReveal.swift` — id, myAnswerId, friendAnswerId, questionId, isUnlocked (false until user records), unlockedAt
- `FriendGroup.swift` — id, name, memberIds[], createdAt
- `QuestionStreak.swift` — userId, currentStreak, longestStreak, lastAnsweredDate
- `SpicyTakeAward.swift` — id, questionId, userId, weekNumber, year, category (mostControversial/mostPassionate/mostSurprising)

New Protocol files to CREATE in `Sources/SocraticJournal/Domain/Services/`:
- `QuestionFeedServiceProtocol.swift` — getTodaysQuestion(), getQuestionHistory(), getUpcomingQuestions()
- `VoiceRecordingServiceProtocol.swift` — startRecording(), stopRecording(), playRecording(url), deleteRecording(url), getRecordingDuration(url)
- `FriendServiceProtocol.swift` — getFriends(), sendFriendRequest(userId), acceptFriendRequest(id), removeFriend(id), searchUsers(query), getIncomingRequests()
- `AnswerRevealServiceProtocol.swift` — getRevealsForQuestion(questionId), unlockAnswer(revealId), hasAnsweredQuestion(questionId)
- `UserProfileServiceProtocol.swift` — getCurrentUser(), updateProfile(user), getUser(id)

New Protocol files to CREATE in `Sources/SocraticJournal/Domain/Repositories/`:
- `QuestionRepositoryProtocol.swift` — CRUD for questions
- `VoiceAnswerRepositoryProtocol.swift` — CRUD for voice answers
- `FriendshipRepositoryProtocol.swift` — CRUD for friendships
- `UserRepositoryProtocol.swift` — CRUD for user profiles

DELETE these files (no longer needed):
- `Sources/SocraticJournal/Domain/Entities/JournalSession.swift`
- `Sources/SocraticJournal/Domain/Entities/Exchange.swift`
- `Sources/SocraticJournal/Domain/Entities/FutureLetter.swift`
- `Sources/SocraticJournal/Domain/Entities/ClarityScore.swift`
- `Sources/SocraticJournal/Domain/Entities/WisdomQuote.swift`
- `Sources/SocraticJournal/Domain/Entities/FictionalCharacter.swift`
- `Sources/SocraticJournal/Domain/Entities/FictionalUniverse.swift`
- `Sources/SocraticJournal/Domain/Entities/CharacterQuizHistoryEntry.swift`
- `Sources/SocraticJournal/Domain/Entities/BigFiveProfile.swift`
- `Sources/SocraticJournal/Domain/Entities/PersonalityTrait.swift`
- `Sources/SocraticJournal/Domain/Entities/JournalExport.swift`
- `Sources/SocraticJournal/Domain/Services/QuestionServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/CharacterQuizServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/ClarityScoreServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/PersonalityAnalysisServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/WisdomQuoteServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/DataExportServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Services/FirebaseFunctionsServiceProtocol.swift`
- `Sources/SocraticJournal/Domain/Repositories/JournalRepositoryProtocol.swift`
- `Sources/SocraticJournal/Domain/Repositories/CharacterQuizHistoryRepositoryProtocol.swift`
- `Sources/SocraticJournal/Domain/Repositories/FictionalUniverseRepositoryProtocol.swift`

KEEP these files (still needed):
- `Sources/SocraticJournal/Domain/Entities/UserSettings.swift` — adapt for new settings
- `Sources/SocraticJournal/Domain/Entities/Subscription.swift` — monetization stays
- `Sources/SocraticJournal/Domain/Services/AnalyticsServiceProtocol.swift` — update events for new platform
- `Sources/SocraticJournal/Domain/Services/NotificationServiceProtocol.swift` — keep for push
- `Sources/SocraticJournal/Domain/Services/SubscriptionServiceProtocol.swift` — keep for IAP
- `Sources/SocraticJournal/Domain/Repositories/SettingsRepositoryProtocol.swift` — keep

Create `Sources/SocraticJournal/Data/Mock/MockDataProvider.swift`:
- Static JSON mock data for all entities
- At least 5 mock users (with fun Gen Z names/avatars)
- 3 mock friend groups
- 15+ mock questions across all 4 levels (use the exact questions from the brief: "What's a popular movie everyone loves that you think is actually trash?", "Is it ever okay to go through your partner's phone?", etc.)
- Mock voice answers (use placeholder local file URLs)
- Mock reveal states (some unlocked, some locked)
- Mock streaks and awards

Create `Sources/SocraticJournal/Data/Mock/MockQuestionFeedService.swift` — implements QuestionFeedServiceProtocol with mock data
Create `Sources/SocraticJournal/Data/Mock/MockFriendService.swift` — implements FriendServiceProtocol with mock data
Create `Sources/SocraticJournal/Data/Mock/MockAnswerRevealService.swift` — implements AnswerRevealServiceProtocol with mock data
Create `Sources/SocraticJournal/Data/Mock/MockUserProfileService.swift` — implements UserProfileServiceProtocol with mock data

DELETE these old data layer files:
- `Sources/SocraticJournal/Data/Repositories/InMemoryJournalRepository.swift`
- `Sources/SocraticJournal/Data/Repositories/LocalCharacterQuizHistoryRepository.swift`
- `Sources/SocraticJournal/Data/Repositories/LocalFictionalUniverseRepository.swift`
- `Sources/SocraticJournal/Data/Services/MockQuestionService.swift`
- `Sources/SocraticJournal/Data/Services/MockCharacterQuizService.swift`
- `Sources/SocraticJournal/Data/Services/MockClarityScoreService.swift`
- `Sources/SocraticJournal/Data/Services/MockPersonalityAnalysisService.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseQuestionService.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseCharacterQuizService.swift`
- `Sources/SocraticJournal/Data/Services/FirebasePersonalityAnalysisService.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseWisdomQuoteService.swift`
- `Sources/SocraticJournal/Data/Services/LocalWisdomQuoteService.swift`
- `Sources/SocraticJournal/Data/Services/JSONDataExportService.swift`
- `Sources/SocraticJournal/Data/Services/AppReviewService.swift`
- `Sources/SocraticJournal/Data/DataSources/InMemoryDataSource.swift`

KEEP these data layer files:
- `Sources/SocraticJournal/Data/Repositories/UserDefaultsSettingsRepository.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseAnalyticsService.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseFunctionsService.swift` — will be adapted later
- `Sources/SocraticJournal/Data/Services/FirebaseNotificationService.swift`
- `Sources/SocraticJournal/Data/Services/StoreKitSubscriptionService.swift`
- `Sources/SocraticJournal/Data/Services/NetworkMonitor.swift`
- `Sources/SocraticJournal/Data/Services/OfflineSyncQueue.swift`
- `Sources/SocraticJournal/Data/Services/OfflineSyncHandler.swift`
- `Sources/SocraticJournal/Data/Services/BackendHealthService.swift`
- `Sources/SocraticJournal/Data/Services/AppsFlyerService.swift`

**Priority:** 1
**Dependencies:** None

---

### 2. Voice Recording Engine — AVAudioRecorder Integration

Build the real voice recording and playback engine. This is the technical heart of the app — it must feel instant, reliable, and smooth.

**User Story:** As a user, I want to record my voice answer to today's question and play back recordings from my friends.

**Acceptance Criteria:**
- User can tap and hold to record (push-to-talk style) OR tap to start/stop
- Recording uses AVAudioRecorder with AAC format, 44.1kHz sample rate
- Maximum recording duration: 60 seconds with visual countdown
- Live audio waveform visualization during recording (use AVAudioRecorder.averagePower metering)
- Playback with AVAudioPlayer for local files
- Audio waveform visualization during playback (animated progress through waveform)
- Recording saved to app's documents directory with structured naming: `{userId}_{questionId}_{timestamp}.m4a`
- Proper AVAudioSession configuration (category: .playAndRecord, mode: .default)
- Handle microphone permission request gracefully with custom UI (not just system alert)
- Handle interruptions (phone calls, other audio) gracefully

Files to CREATE:
- `Sources/SocraticJournal/Data/Services/VoiceRecordingService.swift` — implements VoiceRecordingServiceProtocol, real AVAudioRecorder/AVAudioPlayer
- `Sources/SocraticJournal/Presentation/Components/Audio/AudioWaveformView.swift` — real-time waveform visualization (SwiftUI), animated bars that respond to audio levels
- `Sources/SocraticJournal/Presentation/Components/Audio/RecordButton.swift` — large circular record button with pulse animation, hold or tap modes
- `Sources/SocraticJournal/Presentation/Components/Audio/PlaybackView.swift` — audio playback with waveform, progress bar, duration display
- `Sources/SocraticJournal/Presentation/Components/Audio/MicrophonePermissionView.swift` — custom permission request UI

Design notes:
- RecordButton should be a large circle (80pt diameter), red when recording, with a pulsing ring animation
- Waveform should use 30-40 vertical bars that animate based on audio levels
- Playback waveform should show the full waveform shape with a progress overlay
- All animations should use SwiftUI's `.animation(.spring())` for organic feel
- Dark theme first — waveform bars in accent color (electric blue or hot pink) against dark background

**Priority:** 2
**Dependencies:** 1

---

### 3. Daily Question Feed Screen — The Home Experience

The main screen users see when they open the app. Shows today's question prominently with a big "Record Your Answer" call-to-action. This replaces the old HomeView entirely.

**User Story:** As a user, I want to see today's provocative question front and center so I feel compelled to record my take.

**Acceptance Criteria:**
- Full-screen immersive question card with bold typography
- Question category badge at top (e.g., "DEBATE TRIGGER", "GETTING SPICY", "ICE BREAKER", "DEEP DIVE")
- Question text in large, bold font (28-34pt) centered on screen
- Subtle animated gradient background that shifts colors slowly
- "Record Your Take" button at bottom — large, prominent, unmissable
- If user has already answered today: show "You answered - See what friends said" with friend avatars
- Daily question countdown timer: "Next question in 14h 23m"
- Streak counter displayed prominently: "7 day streak"
- Global stat: "12.4K people answered" (mock data)
- Disagreement meter: "67% disagree on this one" (mock data)
- Pull-to-refresh gesture
- Smooth transition animation when navigating to record screen

Files to CREATE:
- `Sources/SocraticJournal/Presentation/QuestionFeed/QuestionFeedView.swift` — main feed screen
- `Sources/SocraticJournal/Presentation/QuestionFeed/QuestionFeedViewModel.swift` — feed logic, uses MockQuestionFeedService
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/QuestionCard.swift` — the big question display card
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/StreakBadge.swift` — streak counter with fire animation
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/CountdownTimer.swift` — next question countdown
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/DisagreementMeter.swift` — visual meter showing opinion split

DELETE old home files:
- `Sources/SocraticJournal/Presentation/Home/HomeView.swift`
- `Sources/SocraticJournal/Presentation/Home/HomeViewModel.swift`
- `Sources/SocraticJournal/Presentation/Home/Components/StatsCardView.swift`

Design direction:
- Think Instagram Stories meets BeReal — full bleed, immersive, no chrome
- Background: dark with subtle animated gradient (deep purple to midnight blue to dark teal)
- Question text: white, SF Pro Display Bold or SF Pro Rounded Bold
- Accent color for CTAs: electric blue (#007AFF) or hot coral (#FF6B6B)
- The whole screen should feel like a single "moment" — not a list, not a dashboard

**Priority:** 3
**Dependencies:** 1, 2

---

### 4. Voice Recording Flow Screen — Record Your Take

The recording experience when a user taps "Record Your Take." This must feel intimate, focused, and a little bit exciting — like stepping up to a mic.

**User Story:** As a user, I want to record my voice answer in a focused, distraction-free screen that makes me feel like my opinion matters.

**Acceptance Criteria:**
- Modal/full-screen presentation from question feed
- Question text displayed at top for reference
- Large centered record button (RecordButton component from Feature 2)
- Real-time audio waveform while recording
- Recording timer counting up (0:00 to max 1:00)
- "Tap to record" / "Recording..." / "Tap to stop" state labels
- After recording: playback preview with waveform
- "Re-record" and "Submit" buttons after recording
- Submit triggers the "Answer to Unlock" — shows locked friend answers as teasable
- Subtle haptic feedback on record start/stop
- Background dims/blurs when recording (focus effect)
- Cancel/back button to return to question feed

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Recording/RecordingView.swift` — main recording screen
- `Sources/SocraticJournal/Presentation/Recording/RecordingViewModel.swift` — recording logic, manages VoiceRecordingService
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingStateLabel.swift` — animated state indicator
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingTimer.swift` — countdown/count-up timer display
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingPreview.swift` — post-recording preview with re-record/submit

Design direction:
- Minimal dark background with the record button as the hero element
- While recording: subtle red glow emanates from the record button
- Timer in monospace font for that "studio recording" feel
- After recording: the waveform "freezes" and becomes the playback visualization
- Submit button should feel rewarding — slight scale animation + haptic

**Priority:** 4
**Dependencies:** 2, 3

---

### 5. Answer Reveal Screen — "Unlock Friends' Takes"

The magic moment: after recording your answer, you unlock your friends' voice answers. This is the core "Answer to Unlock" mechanic that drives engagement and virality.

**User Story:** As a user, after recording my answer, I want to see which friends also answered and tap to hear their voice recordings, creating a reveal moment.

**Acceptance Criteria:**
- Shown after submitting a recording OR when tapping "See what friends said" from feed
- Grid/list of friend avatars with their answer status
- Locked state: friend avatar with lock icon + "Record yours to unlock" label (if user hasn't answered)
- Unlocked state: friend avatar with play button overlay + waveform preview
- Tap on unlocked friend: plays their voice answer with waveform visualization
- "New" badge on friends who answered since last visit
- Show total friend responses count: "5 of 8 friends answered"
- Empty state: "No friends answered yet — share the question!" with share button
- Quick-react after listening: emoji reactions (fire, laughing, shocked, skull, heart) — just UI, mock the backend
- Smooth scroll if many friends
- Each friend card shows: avatar, name, duration of their recording, time since answered

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Reveals/AnswerRevealView.swift` — main reveal screen
- `Sources/SocraticJournal/Presentation/Reveals/AnswerRevealViewModel.swift` — reveal logic, uses MockAnswerRevealService
- `Sources/SocraticJournal/Presentation/Reveals/Components/FriendAnswerCard.swift` — individual friend answer card (locked/unlocked states)
- `Sources/SocraticJournal/Presentation/Reveals/Components/LockedAnswerOverlay.swift` — the lock/blur overlay
- `Sources/SocraticJournal/Presentation/Reveals/Components/EmojiReactionBar.swift` — quick emoji reactions
- `Sources/SocraticJournal/Presentation/Reveals/Components/FriendAnswerPlayer.swift` — inline audio playback for a friend's answer

Design direction:
- Cards in a vertical scroll, each card roughly 80pt tall
- Locked cards: grayed out with blur effect, lock icon centered
- Unlocked cards: full color with subtle glow, play button on right side
- When playing: card expands slightly to show waveform
- Emoji reactions appear as floating chips below the playing card
- Background: same dark theme as rest of app

**Priority:** 5
**Dependencies:** 2, 4

---

### 6. Friends List & Social Graph Screen

The friends management screen — add friends, see pending requests, manage your social circle. This is the network that powers the whole app.

**User Story:** As a user, I want to find and add friends so I can hear their opinions on questions and they can hear mine.

**Acceptance Criteria:**
- Tab in main navigation (replaces old "Discover" tab)
- Friends list showing all accepted friends with: avatar, name, streak with you, last active
- Search bar at top to find new friends (by username)
- "Invite Friends" button that opens native share sheet with app link
- Pending requests section at top when incoming requests exist (with accept/decline)
- Sent requests section showing outgoing pending requests
- Friend count display
- Tap on friend: shows mini-profile with shared stats (questions both answered, agreement %, streak)
- "3 Friends Gate" indicator: if user has fewer than 3 friends, show progress "Add 2 more friends to unlock all answers" with progress bar
- Remove friend option (swipe to delete or long press menu)
- Contact list import suggestion (just UI placeholder, don't actually access contacts)

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Friends/FriendsListView.swift` — main friends screen
- `Sources/SocraticJournal/Presentation/Friends/FriendsListViewModel.swift` — friends logic, uses MockFriendService
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendRow.swift` — individual friend row
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendRequestRow.swift` — pending request row with accept/decline
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendSearchView.swift` — search for new friends
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendProfileSheet.swift` — mini profile bottom sheet
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendsGateView.swift` — "Add 3 friends" progress indicator
- `Sources/SocraticJournal/Presentation/Friends/Components/InviteFriendsButton.swift` — share sheet trigger

Design direction:
- Clean list design, similar to iMessage or Instagram followers
- Pending requests: highlighted card with blue accept / gray decline buttons
- Friend search: instant results as you type (mock data)
- The "3 Friends Gate" should feel motivating, not blocking — progress bar with encouraging copy
- Avatars: circular, 44pt, with online status dot

**Priority:** 6
**Dependencies:** 1

---

### 7. New Tab Navigation & App Shell Redesign

Redesign the MainTabView and overall app navigation for the new social voice platform. This replaces the old journaling-centric tab structure.

**User Story:** As a user, I want a clean, intuitive navigation between the core app experiences: today's question, friends, and my profile.

**Acceptance Criteria:**

New tab structure (3 tabs):
1. **Today** (mic icon) — QuestionFeedView (Feature 3)
2. **Friends** (people icon) — FriendsListView (Feature 6)
3. **Profile** (person icon) — ProfileView (Feature 8)

- Custom tab bar design: floating pill-shaped tab bar with subtle blur background
- Active tab: filled icon + label, accent color
- Inactive tabs: outline icon, muted color
- Tab bar hides when in recording flow (Feature 4) for immersive experience
- Smooth tab switching with subtle crossfade animation
- Badge on Friends tab when pending requests exist
- Badge on Today tab when new friend answers are available

Files to MODIFY:
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift` — completely rewrite tab structure

Files to DELETE (old tab views):
- `Sources/SocraticJournal/Presentation/Navigation/HomeTabView.swift`
- `Sources/SocraticJournal/Presentation/SelfDiscovery/SelfDiscoveryTabView.swift`
- `Sources/SocraticJournal/Presentation/SelfDiscovery/SelfDiscoveryViewModel.swift`
- `Sources/SocraticJournal/Presentation/Statistics/StatisticsTabView.swift`
- `Sources/SocraticJournal/Presentation/Statistics/StatisticsView.swift`
- `Sources/SocraticJournal/Presentation/Statistics/StatisticsViewModel.swift`
- `Sources/SocraticJournal/Presentation/Statistics/Components/` — all files in this directory
- `Sources/SocraticJournal/Presentation/SessionHistory/` — all files in this directory
- `Sources/SocraticJournal/Presentation/SessionDetail/` — all files in this directory
- `Sources/SocraticJournal/Presentation/SessionComplete/` — all files in this directory
- `Sources/SocraticJournal/Presentation/DialogueSession/` — all files in this directory
- `Sources/SocraticJournal/Presentation/Letters/` — all files in this directory
- `Sources/SocraticJournal/Presentation/CharacterDiscovery/` — all files in this directory
- `Sources/SocraticJournal/Presentation/CharacterQuiz/` — all files in this directory
- `Sources/SocraticJournal/Presentation/WisdomQuotes/` — all files in this directory
- `Sources/SocraticJournal/Presentation/Export/` — all files in this directory

Files to MODIFY:
- `Sources/SocraticJournal/App/SocraticJournalApp.swift` — update to use new services and navigation, remove old service initialization

Design direction:
- Floating tab bar: 60pt height, rounded corners (30pt radius), positioned 8pt from bottom with safe area
- Background: frosted glass effect (Material.ultraThinMaterial)
- Icons: SF Symbols — mic.fill, person.2.fill, person.fill
- The tab bar should feel premium — not stock UIKit

**Priority:** 7
**Dependencies:** 3, 6

---

### 8. User Profile Screen — Your Voice Identity

The user's profile showing their stats, streaks, and settings access. Replaces the old settings screen as the profile hub.

**User Story:** As a user, I want to see my profile with my streaks, stats, and settings so I feel invested in the app.

**Acceptance Criteria:**
- Large avatar at top (placeholder/initial-based for now) with edit button
- Display name and @username
- Stats row: questions answered, streak days, friends count
- "Spiciest Takes" section: list of user's most reacted-to answers (mock data)
- Weekly streak calendar visualization (7 dots, filled for days answered)
- Awards/badges section: "Spiciest Take of the Week" badges (mock)
- Settings gear icon opens SettingsView
- Sign out button at bottom
- Dark theme, consistent with app design

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Profile/ProfileView.swift` — main profile screen
- `Sources/SocraticJournal/Presentation/Profile/ProfileViewModel.swift` — profile logic, uses MockUserProfileService
- `Sources/SocraticJournal/Presentation/Profile/Components/ProfileHeader.swift` — avatar, name, username
- `Sources/SocraticJournal/Presentation/Profile/Components/StatsRow.swift` — horizontal stats display
- `Sources/SocraticJournal/Presentation/Profile/Components/StreakCalendar.swift` — weekly dots visualization
- `Sources/SocraticJournal/Presentation/Profile/Components/SpicyTakesSection.swift` — most popular answers
- `Sources/SocraticJournal/Presentation/Profile/Components/AwardsBadgeView.swift` — achievement badges

MODIFY existing settings:
- `Sources/SocraticJournal/Presentation/Settings/SettingsView.swift` — simplify for new app (keep theme, notifications, subscription; remove data export, letters, character quiz settings)

DELETE old settings components that don't apply:
- `Sources/SocraticJournal/Presentation/Settings/Components/DataManagementView.swift`
- `Sources/SocraticJournal/Presentation/Settings/Components/FeaturesSettingsView.swift`

Design direction:
- Profile header: large circular avatar (100pt), bold name below, muted username
- Stats row: 3 equal columns with number on top, label below
- Streak calendar: horizontal row of 7 circles, filled = answered, empty = missed, today highlighted
- Awards: horizontal scroll of badge cards
- Overall feel: like an Instagram profile but for voice opinions

**Priority:** 8
**Dependencies:** 1, 7

---

### 9. New Onboarding Flow — Welcome to Socratic

Replace the old journaling onboarding with a punchy, exciting onboarding that explains the core mechanic and gets users to their first recording fast.

**User Story:** As a new user, I want to quickly understand what Socratic is about and feel excited to record my first answer.

**Acceptance Criteria:**

4-screen onboarding flow:

Screen 1 — "Your friends have opinions. Hear them."
- Bold headline, subtitle: "Socratic drops a controversial question every day. Record your take. Unlock your friends'."
- Hero illustration area (placeholder colored rectangle for now)
- "Next" button

Screen 2 — "Answer to Unlock"
- Visual showing the lock/unlock mechanic
- "You can't hear their answer until you record yours."
- Animated lock to unlock transition
- "Next" button

Screen 3 — "Voice hits different"
- Audio waveform animation (decorative)
- "Text is dead. Voice captures the hesitation, the laughter, the passion."
- "Next" button

Screen 4 — "Add your crew"
- Contacts/friends illustration area
- "Add 3 friends to get started"
- "Find Friends" and "Skip for now" buttons

- After onboarding: land on QuestionFeedView with today's question
- Onboarding shows only once (persist in UserDefaults)
- Skip button available on all screens
- Page dots at bottom for progress

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift` — main onboarding container with paging
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingPageView.swift` — reusable page template
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingWelcomePage.swift` — Screen 1
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingUnlockPage.swift` — Screen 2
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingVoicePage.swift` — Screen 3
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingFriendsPage.swift` — Screen 4

DELETE old onboarding files:
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingView.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingWelcomeView.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingGuidedReflectionView.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingLettersView.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/OnboardingCharacterView.swift`

Design direction:
- Full-screen pages with TabView paging
- Bold, punchy headlines — max 6 words
- Subtitle text in muted gray
- Generous whitespace
- Dark background throughout
- Page dots: custom, not stock UIPageControl
- Typography: SF Pro Display Bold for headlines, SF Pro Text Regular for body

**Priority:** 9
**Dependencies:** 7

---

### 10. Question History & Past Takes Screen

Browse previous daily questions and your recorded answers. This gives the app depth beyond just "today's question" and creates a content library feel.

**User Story:** As a user, I want to look back at past questions and my recorded answers to relive conversations and see my history.

**Acceptance Criteria:**
- Accessible from profile or a "History" button on the question feed
- Vertical scrolling list of past questions, newest first
- Each card shows: question text, date, your answer status (answered/skipped), number of friends who answered
- Tap on a question: opens that question's reveal screen (Feature 5) to hear friends' answers
- Filter by: All, Answered, Skipped
- Visual indicator for question level/category
- Empty state for new users: "Your history starts today!"
- Smooth scrolling performance with lazy loading

Files to CREATE:
- `Sources/SocraticJournal/Presentation/History/QuestionHistoryView.swift` — main history list
- `Sources/SocraticJournal/Presentation/History/QuestionHistoryViewModel.swift` — history logic
- `Sources/SocraticJournal/Presentation/History/Components/QuestionHistoryCard.swift` — individual history item

Design direction:
- Clean card-based list, similar to Apple Notes or Reminders
- Each card: question text (2 lines max), date on right, status chip below
- Category color coding: ice breaker = blue, spicy = orange, deep dive = purple, debate = red
- Subtle fade-in animation as cards scroll into view

**Priority:** 10
**Dependencies:** 3, 5

---

### 11. Analytics Events Update for New Platform

Update the analytics events to track the new social voice platform interactions instead of the old journaling events.

**User Story:** As a product owner, I want to track user engagement with the new platform features to understand virality and retention.

**Acceptance Criteria:**

Update `AnalyticsServiceProtocol.swift` with new event cases:
- Question events: questionViewed, questionAnswered, questionSkipped, questionShared
- Recording events: recordingStarted, recordingCompleted, recordingReRecorded, recordingDurationSeconds
- Reveal events: friendAnswerUnlocked, friendAnswerPlayed, friendAnswerReacted(emoji)
- Social events: friendRequestSent, friendRequestAccepted, friendRemoved, friendSearched
- Engagement events: streakMaintained, streakBroken, streakMilestone(days)
- Onboarding events: onboardingStarted, onboardingCompleted, onboardingSkipped(atStep)
- Virality events: questionSharedExternal, appInviteSent, contactsImportStarted
- Profile events: profileViewed, profileEdited, historyViewed

Update `FirebaseAnalyticsService.swift` to log these new events.

Remove old journaling event cases (session, letter, character quiz, wisdom, clarity score events).

Files to MODIFY:
- `Sources/SocraticJournal/Domain/Services/AnalyticsServiceProtocol.swift`
- `Sources/SocraticJournal/Data/Services/FirebaseAnalyticsService.swift`

**Priority:** 11
**Dependencies:** 1

---

### 12. Sharing & Virality Cards — Social Sharing Engine

Create the shareable card generation system. After hearing a friend's hot take, users can generate a visual card to share on Instagram Stories, TikTok, etc. This is the organic growth engine.

**User Story:** As a user, I want to share a friend's spicy take as a beautiful card on my Instagram Story to spark conversation and get more friends on the app.

**Acceptance Criteria:**
- Share button appears after listening to a friend's answer
- Generates a shareable image card containing:
  - Question text in bold
  - Audio waveform visualization (static snapshot)
  - Friend's name (or "Anonymous" option)
  - Socratic app branding + "Download to hear the full answer"
  - QR code or deep link placeholder
- Card rendered as UIImage using SwiftUI's ImageRenderer
- Share via UIActivityViewController (native iOS share sheet)
- Card design: bold, Instagram Story-sized (1080x1920 aspect ratio or square)
- Multiple card style options (2-3 color themes)
- "Guess who said this?" variant: shows waveform + question but hides the friend's name

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Sharing/ShareCardView.swift` — the shareable card SwiftUI view
- `Sources/SocraticJournal/Presentation/Sharing/ShareCardGenerator.swift` — renders ShareCardView to UIImage
- `Sources/SocraticJournal/Presentation/Sharing/ShareViewModel.swift` — manages card generation and sharing
- `Sources/SocraticJournal/Presentation/Sharing/Components/ShareCardWaveform.swift` — static waveform for card
- `Sources/SocraticJournal/Presentation/Sharing/Components/ShareCardStyles.swift` — multiple card color themes
- `Sources/SocraticJournal/Presentation/Sharing/Components/GuessWhoCard.swift` — anonymous "guess who" variant

Design direction:
- Cards should look premium and "shareable" — think Spotify Wrapped cards
- Bold gradient backgrounds (dark purple to electric blue, hot coral to orange, etc.)
- Question in large white text, centered
- Waveform as decorative element below the question
- App logo small in corner
- "Hear the answer on Socratic" call-to-action at bottom

**Priority:** 12
**Dependencies:** 5

---

### 13. App Theme, Colors & Brand Polish

Give the app its new identity. Update the color scheme and overall brand feeling for Socratic as a social voice platform.

**User Story:** As a user opening the app for the first time, I want to see a bold, modern brand identity that signals "this is something new and exciting."

**Acceptance Criteria:**
- New color scheme defined in asset catalog or code:
  - Primary: Electric Blue (#007AFF) or similar vibrant accent
  - Secondary: Hot Coral (#FF6B6B)
  - Background: Near Black (#0A0A0A)
  - Surface: Dark Gray (#1A1A1A)
  - Text Primary: White (#FFFFFF)
  - Text Secondary: Gray (#8E8E93)
  - Success: Emerald (#34C759)
  - Warning: Amber (#FF9F0A)
- App defaults to dark mode (ThemeManager default should be .dark)
- Consistent typography scale across the app:
  - Headline: SF Pro Display Bold, 28-34pt
  - Title: SF Pro Display Semibold, 20-24pt
  - Body: SF Pro Text Regular, 16-17pt
  - Caption: SF Pro Text Regular, 13-14pt
- Update any remaining old "Socratic Journal" references to just "Socratic"

Files to CREATE:
- `Sources/SocraticJournal/Presentation/Theme/AppColors.swift` — centralized color definitions
- `Sources/SocraticJournal/Presentation/Theme/AppTypography.swift` — centralized font scale
- `Sources/SocraticJournal/Presentation/Theme/AppSpacing.swift` — consistent spacing scale (4, 8, 12, 16, 24, 32, 48)

Files to MODIFY:
- `Sources/SocraticJournal/Presentation/Theme/ThemeManager.swift` — default to dark mode

**Priority:** 13
**Dependencies:** 7

---

### 14. Notification System Update for Social Engagement

Update the push notification system to drive engagement with social-specific notifications that create FOMO and urgency.

**User Story:** As a user, I want to receive exciting notifications when friends answer today's question or when new questions drop, so I stay engaged.

**Acceptance Criteria:**

New notification types (local notifications, mocked triggers):
- "New question dropped!" — daily at configured time
- "{Friend} just recorded their take. Record yours to hear it." — when a friend answers
- "You're on a 7-day streak! Don't break it." — streak reminder
- "3 friends answered today's question. You haven't yet." — FOMO trigger
- "Someone disagreed with your take on '{question}'" — re-engagement hook
- "This week's Spiciest Take award goes to..." — weekly award notification

Update `LocalNotificationService.swift` to support new notification categories.
Keep `FirebaseNotificationService.swift` for remote push token management.

Files to MODIFY:
- `Sources/SocraticJournal/Data/Services/LocalNotificationService.swift` — new notification templates
- `Sources/SocraticJournal/Presentation/Settings/Components/NotificationSettingsView.swift` — update settings for new notification types

**Priority:** 14
**Dependencies:** 1, 7

---

### 15. Build Configuration & Cleanup — Make It Compile

Final cleanup pass to ensure the project compiles cleanly after the massive pivot. Update project.yml, fix any broken imports, remove dead code references.

**User Story:** As a developer, I want the project to compile successfully with all new features integrated and old code removed.

**Acceptance Criteria:**
- Update `project.yml` to include all new files and remove references to deleted files
- Update `SocraticJournalApp.swift` entry point to initialize new services (MockDataProvider, VoiceRecordingService, etc.)
- Fix any broken import statements
- Remove any remaining references to deleted entities/services
- Ensure all mock services are properly injected
- App should build for iOS Simulator without errors
- Run `xcodegen generate` and verify project opens in Xcode
- Remove any unused assets from asset catalog

Files to MODIFY:
- `project.yml` — update source file references
- `Sources/SocraticJournal/App/SocraticJournalApp.swift` — update initialization and dependency injection
- `Sources/SocraticJournal/App/Environment.swift` — remove any unused environment config

**Priority:** 15
**Dependencies:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14

---

## Implementation Order

```
Phase 1 — Foundation (Feature 1)
└── Domain models, protocols, mock data — EVERYTHING depends on this

Phase 2 — Core Engine (Features 2, 6, 11)
├── 2. Voice Recording Engine (real AVAudioRecorder)
├── 6. Friends List & Social Graph
└── 11. Analytics Events Update

Phase 3 — Main Screens (Features 3, 4, 5)
├── 3. Daily Question Feed (the home screen)
├── 4. Voice Recording Flow (record your take)
└── 5. Answer Reveal Screen (unlock friends' takes)

Phase 4 — App Shell & Navigation (Features 7, 8, 9)
├── 7. New Tab Navigation
├── 8. User Profile Screen
└── 9. New Onboarding Flow

Phase 5 — Polish & Growth (Features 10, 12, 13, 14)
├── 10. Question History
├── 12. Sharing & Virality Cards
├── 13. Brand & Theme Polish
└── 14. Notification Update

Phase 6 — Integration (Feature 15)
└── 15. Build Config & Cleanup — make it compile
```

## Question Bank (Use These Exact Questions in Mock Data)

### Level 1 — Ice Breakers
- "What's a popular movie everyone loves that you think is actually trash?"
- "Be honest — do you wash your legs in the shower or just let the water run down?"
- "What's something you pretend to like because everyone around you does?"
- "If you could delete one app from everyone's phone, which one?"

### Level 2 — Getting Spicy
- "What's a relationship red flag you've personally ignored?"
- "Who in your friend group would survive the longest in a zombie apocalypse? Who'd go first?"
- "What's an opinion you hold that would genuinely make people uncomfortable at a dinner party?"
- "If you had to bet your life savings — does God exist or not?"

### Level 3 — Deep Dive
- "What's something you've never said out loud but think about at least once a week?"
- "If your friend group had to vote one person out, who would it be and why?"
- "What's the most selfish thing you've done that you'd do again?"
- "Is there someone in your life you love but don't actually like?"

### Level 4 — Debate Triggers
- "Is it ever okay to go through your partner's phone?"
- "Should you tell your best friend their partner is cheating — even if it'll destroy the friendship?"
- "Rich and lonely or broke with the best people around you?"
- "Could you forgive cheating if everything else was perfect?"
- "Is it selfish to not want kids, or is having kids the selfish act?"

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

- **Deep Quality Mode is ON** — this is a critical pivot, quality matters
- This is a DESTRUCTIVE pivot — many files get DELETED. Confirm old files are removed before creating new ones
- Follow existing Clean Architecture patterns: Protocol in Domain, Implementation in Data, UI in Presentation
- Use `@Observable @MainActor` for all ViewModels (existing pattern)
- Mock ALL Firebase/backend calls — create MockDataProvider with static data
- Voice recording is the ONE thing that should use real iOS APIs (AVAudioRecorder)
- Dark theme is default — design dark-first, light mode is secondary
- Gen Z aesthetic: bold, minimal, high contrast, no clutter
- The "Answer to Unlock" mechanic is the MOST important UX flow — it must feel magical
- Keep the existing Firebase SDK dependency for analytics/notifications even though we're mocking data
- Widget implementation is explicitly EXCLUDED from this sprint — skip it entirely
- When in doubt, reference BeReal, Locket, and Gas for design inspiration
