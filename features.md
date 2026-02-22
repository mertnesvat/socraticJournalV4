# Night Agent Feature Queue — Bold UI Revamp

---
base_branch: feature/big-ui-3
max_retries: 2
continue_on_failure: true
---

## Features

### 1. Design System Foundation — Bold Editorial Palette
**Priority:** 1
**Dependencies:** none

Completely overhaul the app's design system tokens to establish a bold, editorial aesthetic inspired by three reference designs: Bold Geometric (red/black), Structured Minimalism (cream/hairline borders), and Conversational Cards (warm, personality-driven).

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Theme/AppColors.swift`
- `Sources/SocraticJournal/Presentation/Theme/AppTypography.swift`
- `Sources/SocraticJournal/Presentation/Theme/AppSpacing.swift`

**New Color Palette (AppColors.swift):**
Replace the current palette entirely:
```
// Accent — Bold Coral Red (the hero color, from Image 1 & 2)
accent: #E8503A (the dusty coral-red seen across all three references)

// Backgrounds — Cream editorial (from Image 2)
background: #FAF7F2 (warm cream/off-white — the main background)
surface: #FFFFFF (white cards and surfaces)
surfaceElevated: #F0EBE3 (slightly darker cream for secondary surfaces)

// Dark variants (for recording studio and dark cards from Image 1)
backgroundDark: #0A0A0A (near-black)
surfaceDark: #1A1A1A (dark cards)

// Text — High contrast on cream
textPrimary: #1A1A1A (near-black on cream)
textSecondary: #6B6B6B (medium gray)
textTertiary: #9E9E9E (light gray)
textOnDark: #FFFFFF (white text on dark backgrounds)
textOnAccent: #FFFFFF (white on coral-red)

// Semantic
success: #34C759
warning: #FF9F0A
error: #E8503A (same as accent for this editorial feel)

// Card colors for conversational stacking (from Image 3)
cardYellow: #FADF63
cardTeal: #8EDDD0
cardDark: #1C1C1E

// Question Categories — keep but harmonize with new palette
iceBreaker: #3A7BD5 (softer blue)
gettingSpicy: #F5A623 (warm amber)
deepDive: #9B59B6 (rich purple)
debateTrigger: #E8503A (accent red)

// Borders (from Image 2's hairline grid)
border: #E0DDD7 (subtle cream-gray for hairlines)
borderStrong: #C8C4BC (more visible borders)
```

Remove all existing gradients. Replace with a single subtle gradient for special elements:
```
accentGradient: [#E8503A → #D04030] (subtle coral gradient)
```

**New Typography (AppTypography.swift):**
The design is driven by BIG, confident typography. Add new sizes:
```
// Display — The editorial heroes (from all 3 images)
displayLarge: 48pt, bold, default design (for hero numbers like "67", "14")
displayMedium: 40pt, bold, default design (for question text, conversational headers)
display: 34pt, bold, default design (for section heroes)

// Headlines — keep but adjust
headline: 28pt, bold
headlineMedium: 24pt, semibold

// Section headers — ALL CAPS editorial (from Image 2)
sectionHeader: 13pt, heavy, with 2.0 tracking (for "CONDITION REPORTS & SURVEYS" style)

// Body
body: 17pt, regular
bodyBold: 17pt, semibold
bodyLarge: 20pt, regular (for descriptive text like Image 2's paragraph)

// Caption
caption: 13pt, regular
captionBold: 13pt, semibold

// Special
timer: 28pt, medium, monospaced
stat: 56pt, bold, default (oversized stat numbers from Image 1 — "14", "67")
statSmall: 32pt, bold, default (smaller stat numbers — "21")
badge: 11pt, bold
```

**New Spacing (AppSpacing.swift):**
Add editorial whitespace tokens:
```
// Keep existing xxs through xxl
// Add editorial-specific spacing
heroTopPadding: 60 (generous top padding for hero screens)
sectionGap: 40 (breathing room between sections)
cardGap: 16 (space between stacked cards)
gridGutter: 1 (hairline for grid borders from Image 2)
displayBottomMargin: 24 (under big display text)
```

**Also create a new file `Sources/SocraticJournal/Presentation/Theme/AppShapes.swift`:**
Add geometric shape components inspired by Image 1 (the red/black circles):
```swift
// GeometricRing — donut chart shape for data viz
// GeometricCircle — filled circle for buttons and accents
// HairlineDivider — 1px line for grid borders (Image 2)
// GridCell — bordered cell component for icon grids (Image 2)
```

Make sure to keep the `Color(hex:)` extension. Ensure all color tokens use the new palette consistently. Keep `#if os(iOS)` guards.

---

### 2. Question Feed & Tab Bar — Bold Geometric Hero
**Priority:** 2
**Dependencies:** Design System Foundation

Revamp the Question Feed (home screen) and Tab Bar to be the bold, editorial hero experience. Inspired by Image 1 (Bold Geometric) and Image 3 (Conversational Cards).

**Design vision:**
The question feed should feel like a design magazine spread. The question text is MASSIVE — it IS the UI. No cards wrapping it, no rounded rectangles. Just enormous text on a clean cream background with a bold coral accent.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/QuestionFeed/QuestionFeedView.swift`
- `Sources/SocraticJournal/Presentation/QuestionFeed/QuestionFeedViewModel.swift` (only if needed)
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/QuestionCard.swift`
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/DisagreementMeter.swift`
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/StreakBadge.swift`
- `Sources/SocraticJournal/Presentation/QuestionFeed/Components/CountdownTimer.swift`
- `Sources/SocraticJournal/Presentation/Navigation/MainTabView.swift`

**QuestionFeedView redesign:**
- Replace the animated gradient background with a clean cream `AppColors.background` (#FAF7F2)
- Remove the dark aesthetic entirely — this is now a bright, editorial screen
- Layout from top to bottom:
  1. Small category label: ALL-CAPS tracking, e.g. "GETTING SPICY" in accent color
  2. MASSIVE question text: 40pt bold, left-aligned (not centered!), near-black on cream. The text IS the visual hero — like Image 1's "Sold Services" but even bigger. Left-aligned, not centered.
  3. Level intensity dots below the question (kept but simplified — just 4 small circles)
  4. A large geometric ring (donut) visualization showing the disagreement ratio — inspired by Image 1's giant red/black donut chart. The ring should be 200pt+ diameter, using accent red and light gray, with the ratio displayed as a big number inside
  5. Below the ring: response count as a big stat number ("1,203" in 56pt bold) with a small "responses" label below
  6. A filled coral-red pill button "Record Your Take" (or "See What Friends Said") — like Image 1's "More" button
  7. Countdown timer: minimal, just text "Next question in 4h 23m" in caption style

**QuestionCard redesign:**
- Remove the glass-morphism card background entirely
- Just the question text, massive, left-aligned, on the cream background
- Category badge becomes a small ALL-CAPS label above the text
- No rounded rectangle container — let the text breathe

**DisagreementMeter redesign:**
- Replace the current visualization with a large geometric donut ring (200pt diameter)
- Ring colors: accent red for "disagree" portion, `AppColors.border` (light gray) for "agree" portion
- Inside the ring: the disagreement percentage as a display-size number (e.g. "81%")
- Below the ring: "disagree" label

**StreakBadge redesign:**
- Simple, editorial: just the number in stat font with "day streak" label
- No capsule/badge background — let typography do the work
- Positioned at the top of the screen, left-aligned

**CountdownTimer redesign:**
- Minimal: "Next in 4h 23m" as caption text, right-aligned at bottom

**MainTabView (Tab Bar) redesign:**
- Replace the floating pill tab bar with a clean, minimal bottom tab bar
- Cream background matching the main screen, with a hairline top border (from Image 2)
- Three icons: simple line-weight SF Symbols
- Active tab: accent coral red icon + label
- Inactive tab: medium gray icon + label
- No capsule, no glassmorphism, no shadow
- Remove the page-swipe TabView behavior — use a standard tab-switching approach
- Keep badge overlays but style them as small coral-red dots (no numbers for cleaner look)

---

### 3. Profile Screen — Conversational Stats Dashboard
**Priority:** 3
**Dependencies:** Design System Foundation

Revamp the Profile screen into a conversational, stats-forward dashboard. Inspired by Image 3 (Conversational Cards) and Image 1 (bold stat numbers).

**Design vision:**
The profile opens with a warm, personality-driven greeting (like Image 3's "Hello Daniel, your overall score is above average") followed by big stat numbers and contrasting colored cards.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Profile/ProfileView.swift`
- `Sources/SocraticJournal/Presentation/Profile/Components/ProfileHeader.swift`
- `Sources/SocraticJournal/Presentation/Profile/Components/StatsRow.swift`
- `Sources/SocraticJournal/Presentation/Profile/Components/StreakCalendar.swift`
- `Sources/SocraticJournal/Presentation/Profile/Components/SpicyTakesSection.swift`
- `Sources/SocraticJournal/Presentation/Profile/Components/AwardsBadgeView.swift`

**ProfileView redesign:**
- Remove NavigationStack title bar — use custom inline title
- Cream background (`AppColors.background`)
- ScrollView with generous padding
- Layout from top:
  1. Top bar: small settings gear icon (right-aligned), no title
  2. **Conversational greeting header**: "Hello [Name]," on one line, then below "you've answered [X] questions this week" in display-medium (40pt) bold. The number should be in accent color. Like Image 3's "Hello Daniel, your overall score is above average"
  3. **Stat pills row**: Small pill-shaped badges in a horizontal scroll. E.g. "Growth +15%" with green tint, "Best Streak: 14 days" with accent tint. From Image 3's pill badges.
  4. **Stats cards section**: Three large stat cards stacked vertically, each with contrasting background:
     - Card 1 (teal `cardTeal`): "Questions Answered" + big number "67" in stat font (56pt)
     - Card 2 (yellow `cardYellow`): "Day Streak" + big number "14" in stat font, with a small ring chart showing weekly completion
     - Card 3 (dark `cardDark`): "Friends" + big number "23" in stat font, white text
     Like Image 3's "Your progress — You are doing well 78%" card but with our data
  5. **Streak Calendar**: Simplified — just 7 circles for the week (Mon-Sun), filled accent for completed, border for incomplete. Minimal, in a hairline-bordered section.
  6. **Spicy Takes**: Cards with hairline borders (Image 2 style), showing the question text prominently
  7. **Awards**: Grid of icons in bordered cells (exactly like Image 2's 3x2 icon grid with one coral-red accent cell)
  8. Sign out button: Minimal text link, not a big red button

**ProfileHeader redesign:**
- Remove the circular avatar and centered name
- Instead: just the conversational greeting as described above
- No avatar at all — let the words introduce the user

**StatsRow redesign:**
- Replace the 3-column stat row with the contrasting colored cards described above
- Each card is full-width, ~120pt tall, rounded corners (16pt)
- Big number left or right aligned, label on the opposite side

**StreakCalendar redesign:**
- 7 inline circles, minimal
- Inside a section with ALL-CAPS "THIS WEEK" header and hairline top/bottom borders

---

### 4. Friends Screen — Structured Editorial Grid
**Priority:** 4
**Dependencies:** Design System Foundation

Revamp the Friends screen using the Structured Minimalism approach from Image 2 — clean grid, hairline borders, cream background, refined typography.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Friends/FriendsListView.swift`
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendRow.swift`
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendRequestRow.swift`
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendsGateView.swift`
- `Sources/SocraticJournal/Presentation/Friends/Components/FriendProfileSheet.swift`

**FriendsListView redesign:**
- Replace the `List` with insetGrouped style → custom ScrollView with hairline-bordered sections
- Cream background throughout
- Remove NavigationStack default title — use custom inline ALL-CAPS "FRIENDS" section header with tracking
- Search bar: minimal, with hairline border bottom, no background fill

**Section headers:**
- ALL-CAPS with letter spacing (e.g., "PENDING REQUESTS", "YOUR FRIENDS")
- Hairline top border above each section
- Like Image 2's "CONDITION REPORTS & SURVEYS"

**FriendRow redesign:**
- Hairline bottom border between each friend (not rounded cards)
- Left: small circular avatar (32pt), then name and username vertically
- Right: subtle chevron or status indicator
- No background color — just text on cream with hairline dividers
- Clean, refined, lots of whitespace

**FriendRequestRow redesign:**
- Same hairline-separated layout
- Accept button: small filled coral-red pill
- Decline button: text-only, gray
- Minimal, not flashy

**FriendsGateView redesign:**
- Instead of an encouragement card, use a clean section at the top:
  - Big text: "Add [X] more friends to unlock reveals"
  - Progress: 3 circles showing friend slots (filled for added, empty for remaining)
  - Coral-red "Invite Friends" text button
  - Hairline top and bottom borders framing the section

**FriendProfileSheet redesign:**
- Clean cream background
- Big display name at top, left-aligned
- Username below in caption style
- Stats in big numbers (questions answered, mutual friends)
- Remove friend: text link at bottom, not a button
- Hairline dividers between sections

---

### 5. Recording View — Bold Geometric Studio
**Priority:** 5
**Dependencies:** Design System Foundation

Revamp the Recording View with the Bold Geometric style from Image 1. This screen STAYS dark — it's the recording studio. But now with the bold geometric language.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Recording/RecordingView.swift`
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordButton.swift`
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingPreview.swift`
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingTimer.swift`
- `Sources/SocraticJournal/Presentation/Recording/Components/RecordingStateLabel.swift`
- `Sources/SocraticJournal/Presentation/Components/Audio/AudioWaveformView.swift`

**Design vision:**
The recording screen is the one place we keep dark, like a recording studio. But now it uses the Bold Geometric language from Image 1 — massive shapes, coral-red accent, oversized typography.

**RecordingView redesign:**
- Background: solid near-black (`AppColors.backgroundDark` — #0A0A0A), no gradient
- Question text: MASSIVE, 34pt bold, left-aligned at the top of the screen, white on black. Like Image 1's "Sold Services" headline.
- Below question: category in ALL-CAPS tracking, coral-red, small
- Giant record button: 120pt filled coral-red circle. Nothing else — just a massive red circle. Like Image 1's geometric circles. On tap, it starts recording.
- During recording: the red circle pulses. Timer in stat font (56pt) below.
- Waveform: simplified — just a few thick bars, coral-red on black
- Close button: top-right, just an "X" in white, no background circle

**RecordButton redesign:**
- Single massive filled circle (120pt), coral-red
- When recording: circle has a pulsing ring animation around it
- When idle: static filled circle with no decoration
- Like Image 1's geometric circle language

**RecordingPreview redesign:**
- After recording, show:
  - Duration as a massive stat number (e.g., "0:47" in 56pt)
  - Simplified waveform in coral-red
  - Two actions: "Re-record" (text button, gray) and "Submit" (filled coral-red pill)
  - All on near-black background

**RecordingTimer redesign:**
- Just the time in stat font, coral-red on black
- No additional chrome

**AudioWaveformView redesign:**
- Thicker bars (4pt width instead of thin lines)
- Coral-red color on dark background
- Fewer bars (20 instead of 35) for a bolder look

---

### 6. Onboarding — Conversational Pages
**Priority:** 6
**Dependencies:** Design System Foundation

Revamp Onboarding with the Conversational Cards approach from Image 3 — warm, personality-driven, contrasting colored backgrounds.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Onboarding/NewOnboardingView.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingWelcomePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingUnlockPage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingVoicePage.swift`
- `Sources/SocraticJournal/Presentation/Onboarding/Pages/OnboardingFriendsPage.swift`

**NewOnboardingView redesign:**
- Remove black background
- Each page gets its own contrasting background color (like Image 3's card stacking)
- Page dots: small, minimal, in the accent color
- Skip button: top-right, subtle gray text
- Next button: filled coral-red pill at bottom
- Last page: "Get Started" instead of "Find Friends"

**Page 1 — Welcome (cream background):**
- Massive text: "Welcome to Socratic" in display-large (48pt)
- Below: "Your voice matters. Answer bold questions. Hear what your friends think." in body-large (20pt), left-aligned
- No icon/image — let the typography be the hero
- Cream background (#FAF7F2)

**Page 2 — Unlock Answers (teal `cardTeal` background):**
- Massive text: "Answer first, then listen"
- Below: "Record your take on today's question. Then unlock what everyone else said."
- Maybe a simple geometric shape (a lock → unlock icon transition)

**Page 3 — Voice (coral-red `accent` background, white text):**
- Massive text: "Your voice, not your thumbs"
- Below: "60 seconds. No editing. No overthinking. Just you."
- This page is the bold red statement — like Image 1's red background

**Page 4 — Friends (yellow `cardYellow` background):**
- Massive text: "Better with friends"
- Below: "The real fun starts when you hear how differently your friends think."
- "Get Started" button in dark (near-black on yellow)

---

### 7. Paywall & Settings — Refined Editorial
**Priority:** 7
**Dependencies:** Design System Foundation

Revamp the Paywall and Settings screens with Structured Minimalism from Image 2 — elegant, refined, grid-based.

**Files to modify:**
- `Sources/SocraticJournal/Presentation/Paywall/PaywallView.swift`
- `Sources/SocraticJournal/Presentation/Settings/SettingsView.swift`
- `Sources/SocraticJournal/Presentation/Settings/Components/ThemeSelectorView.swift`
- `Sources/SocraticJournal/Presentation/Settings/Components/NotificationSettingsView.swift`
- `Sources/SocraticJournal/Presentation/Settings/Components/SubscriptionSettingsView.swift`
- `Sources/SocraticJournal/Presentation/Settings/Components/AboutView.swift`

**PaywallView redesign:**
- Cream background
- Remove the icon/sparkle circle at top
- Instead: massive headline "Go Premium" in display (34pt), left-aligned
- Below: "Unlock everything. Journal without limits." in body-large
- Feature grid: 2x2 grid with hairline borders (exactly like Image 2's icon grid), each cell with an icon and feature name
  - One cell highlighted with coral-red background (like Image 2's red accent cell)
- Product cards: hairline-bordered rectangles
  - Selected: coral-red left border (4pt)
  - Unselected: hairline gray border
  - Big price number in stat font
  - Period label in caption
- Subscribe button: full-width coral-red filled pill
- Footer: minimal gray text links
- No shadows, no gradients — pure structure

**SettingsView redesign:**
- Cream background
- Sections divided by hairline borders with ALL-CAPS headers
- Each row: text on left, control on right, hairline bottom border
- No grouped list style — flat cream with dividers
- Section headers like Image 2: "APPEARANCE", "NOTIFICATIONS", "SUBSCRIPTION", "ABOUT"
- Toggle switches: coral-red tint
- Navigation chevrons: subtle gray

---
