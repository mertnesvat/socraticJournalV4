---
base_branch: main
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.StudioNext.socraticJournal
action_logging: true
---

# Feature Queue: Socratic Journal UX Overhaul

This queue addresses two main areas: fixing app-wide theming and modernizing the navigation UX with a tab bar.

---

### 1. Fix App-Wide Dark/Light Theme Support

The theme selector in Settings changes the theme, but it doesn't apply to full-screen covers (DialogueSessionView, LettersListView, StatisticsView, WisdomQuotesView, CharacterDiscoveryView, SessionCompleteView). Users expect their theme choice to apply everywhere.

**User Story:** As a user, I want my dark/light theme preference to apply to every screen in the app, so I have a consistent visual experience.

**Acceptance Criteria:**
- User can select System/Light/Dark theme in Settings
- Theme applies immediately to all screens including full-screen covers
- DialogueSessionView respects the selected theme
- LettersListView respects the selected theme
- StatisticsView respects the selected theme
- WisdomQuotesView respects the selected theme
- CharacterDiscoveryView respects the selected theme
- SessionCompleteView respects the selected theme
- SettingsView respects the selected theme
- All sheets and modals respect the selected theme
- Theme persists across app restarts

**Current Issues to Address:**
- Full-screen covers don't inherit `.preferredColorScheme()` from parent
- Some views have hardcoded colors that don't adapt (purple/blue gradient in LettersListView, orange in CharacterDiscoveryView, green in SessionCompleteView)
- Theme state needs to be passed through environment or stored globally

**Priority:** 1
**Dependencies:** None

---

### 2. Implement Tab Bar Navigation with Floating Plus Button

Replace the current toolbar-based navigation with a modern tab bar. The current UX has the "Start Session" button in the middle of the home screen content and navigation scattered in the toolbar. This should become a clean tab bar with a prominent floating center button for starting sessions.

**User Story:** As a user, I want a tab bar at the bottom of the screen with a prominent plus button in the center, so I can easily start new journaling sessions and navigate between main sections.

**Acceptance Criteria:**
- Tab bar appears at the bottom of the screen with 3 main areas
- Left tab: Home (house icon) - shows the main journal home screen
- Center: Floating circular plus button that stands out above the tab bar
- Right tab: Statistics (chart icon) - shows the statistics screen
- Plus button has elevated/floating appearance (shadow, slightly raised above tab bar)
- Tapping plus button starts a new Socratic dialogue session
- Tab bar is visible on Home and Statistics screens
- Tab bar hides during dialogue sessions (full-screen experience)
- Active tab has visual indicator (filled icon, accent color, or label)
- Tab bar respects dark/light theme

**Priority:** 2
**Dependencies:** Feature 1 (App-Wide Theme Support)

---

### 3. Relocate Profile, Letters, and Wisdom Library to Toolbar/Menu

With the new tab bar handling primary navigation, secondary features need a new home. Profile (Character Discovery), My Letters, and Wisdom Library should be accessible from the top toolbar on the Home screen.

**User Story:** As a user, I want to access my profile, letters, and wisdom quotes from the home screen toolbar, so these features are still easily reachable without cluttering the tab bar.

**Acceptance Criteria:**
- Home screen has a toolbar with navigation icons
- Profile icon (person.crop.circle) in toolbar opens Character Discovery
- Letters icon (envelope with badge) in toolbar opens My Letters list
- Wisdom icon (quote.bubble) in toolbar opens Wisdom Quotes
- Settings gear icon remains in toolbar for Settings access
- Badge on letters icon shows count of ready-to-read letters
- Toolbar icons are appropriately sized and spaced
- Toolbar respects dark/light theme

**Priority:** 3
**Dependencies:** Feature 2 (Tab Bar Navigation)

---

### 4. Update Home Screen Layout for Tab Bar

The home screen needs to be restructured to work with the new tab bar. Remove the current "Start Session" button from the content area since it's now in the tab bar. Adjust spacing and layout.

**User Story:** As a user, I want the home screen to feel clean and focused on my journal history and stats, with the session start action in the tab bar.

**Acceptance Criteria:**
- Stats summary card remains at top of home screen (tappable to see full stats)
- "Start Session" button removed from main content (now in tab bar)
- Calendar view remains for filtering sessions by date
- Session history list shows below calendar
- Empty state shows encouraging message when no sessions exist
- Content has appropriate bottom padding to account for tab bar
- Pull-to-refresh still works to reload data
- Layout looks balanced without the large start button in content

**Priority:** 4
**Dependencies:** Feature 2 (Tab Bar Navigation), Feature 3 (Toolbar Relocation)

---

### 5. Ensure Consistent Navigation Flow with New Structure

All navigation flows need to work correctly with the new tab bar architecture. Full-screen covers for sessions should hide the tab bar, and returning from sessions should show it again.

**User Story:** As a user, I want navigation to feel smooth and consistent, with the tab bar appearing and disappearing appropriately as I move through the app.

**Acceptance Criteria:**
- Starting a session from plus button presents DialogueSessionView full-screen (no tab bar)
- Completing a session shows SessionCompleteView full-screen (no tab bar)
- "Write Letter" from session complete opens ComposeLetterView full-screen
- "Back to Home" from session complete returns to home with tab bar visible
- Opening Letters list from toolbar presents full-screen (no tab bar visible)
- Opening Wisdom Quotes from toolbar presents full-screen
- Opening Character Discovery from toolbar presents full-screen
- Opening Settings from toolbar presents full-screen
- All dismiss actions properly return to the tab bar view
- No duplicate navigation bars or visual glitches during transitions

**Priority:** 5
**Dependencies:** Feature 4 (Home Screen Layout)

---

## Technical Notes for Implementation

### Theme Fix Approach
The recommended approach is to:
1. Create an `@Observable` ThemeManager that stores the current theme
2. Pass theme through SwiftUI environment using `.environment()`
3. Apply `.preferredColorScheme()` to each full-screen cover's root view
4. Replace hardcoded colors with semantic alternatives or use `.opacity()` modifiers that work in both modes

### Tab Bar Implementation Approach
Consider using:
1. Custom `TabView` with `.tabViewStyle(.page)` or standard tabs
2. ZStack overlay for the floating center button
3. Custom tab bar view if standard TabView doesn't support the floating button design
4. GeometryReader for proper positioning of floating button

### Files Likely to Change
- `SocraticJournalApp.swift` - App structure, possibly switch to tab-based root
- `HomeView.swift` - Remove start button, adjust layout, update toolbar
- `DialogueSessionView.swift` - Add theme support
- `LettersListView.swift` - Add theme support, fix hardcoded colors
- `StatisticsView.swift` - Add theme support, integrate with tab bar
- `WisdomQuotesView.swift` - Add theme support
- `CharacterDiscoveryView.swift` - Add theme support, fix hardcoded colors
- `SessionCompleteView.swift` - Add theme support, fix hardcoded colors
- `SettingsView.swift` - Theme support already present, may need adjustments
- New file: `MainTabView.swift` or similar for tab bar container
- New file: `ThemeManager.swift` or similar for centralized theme state
