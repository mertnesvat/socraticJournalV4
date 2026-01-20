---
base_branch: master
max_retries: 2
continue_on_failure: true
visual_gate_enabled: true
visual_gate_threshold: 0.7
bundle_id: com.mertnesvat.SocraticJournal
action_logging: true
---

# Feature Queue: v1.1 Bug Fixes & Polish

Address user-reported bugs and UI polish issues to improve app stability and visual consistency.

---

### 1. Update Home Screen Title

Change the home screen title from "Socratic Journal" to just "Socratic" for a cleaner, more minimal look.

**User Story:** As a user, I want the home screen to show "Socratic" as the title, so the interface feels more minimal and elegant.

**Acceptance Criteria:**
- User sees "Socratic" as the title on the home screen
- Title no longer shows "Socratic Journal"
- Title styling remains consistent with current design

**Priority:** 1
**Dependencies:** None

---

### 2. Update Privacy Policy URL

Update the privacy policy URL to point to the correct location.

**User Story:** As a user, I want the privacy policy link to work correctly, so I can review the app's privacy practices.

**Acceptance Criteria:**
- Privacy URL is set to https://studionext.co.uk/socratic-privacy.html
- User can access the privacy policy from Settings or wherever it's linked
- URL opens correctly in the system browser or in-app web view

**Priority:** 1
**Dependencies:** None

---

### 3. Fix Calendar Row Height Inconsistency

Fix the visual issue where calendar rows have inconsistent heights when some days have events and others don't.

**User Story:** As a user, I want all calendar rows to have consistent heights, so the calendar looks visually balanced and professional.

**Acceptance Criteria:**
- User sees all calendar rows at the same height regardless of event count
- Days with no events have the same row height as days with events
- Calendar maintains consistent visual appearance across all rows
- The fix doesn't affect the visibility of event indicators on days that have them

**Priority:** 2
**Dependencies:** None

---

### 4. Fix Session Completion Crash on Skipped Questions

Fix the crash that occurs when completing a session after skipping all three questions.

**User Story:** As a user, I want to complete a session even if I skipped all questions, so the app doesn't crash and I can still end my session gracefully.

**Acceptance Criteria:**
- User can skip all three questions in a session without crashing
- User can tap the complete session button after skipping all questions
- Session completes successfully and saves appropriately
- App handles the edge case of all questions being skipped gracefully
- No data loss or corruption occurs

**Priority:** 1
**Dependencies:** None

---

### 5. Fix Sample Sessions Re-Adding After Clear All

Fix the issue where sample sessions are re-added after the user clears all sessions, or fix the clear all functionality if it's not working correctly.

**User Story:** As a user, I want my "clear all sessions" action to be permanent, so sample sessions don't reappear after I've deleted them.

**Acceptance Criteria:**
- User can clear all sessions successfully
- Sample sessions do not reappear after being cleared
- App remembers that sample data has been dismissed/cleared
- First-time users still see sample sessions on initial launch
- Returning users who cleared samples don't see them again
- Clear all functionality removes all sessions from storage

**Priority:** 1
**Dependencies:** None

---

## Testing Notes

**Critical Paths to Verify:**
- Launch app fresh → see sample sessions → clear all → relaunch → samples should NOT reappear
- Start session → skip question 1 → skip question 2 → skip question 3 → complete → should NOT crash
- Check home screen title shows "Socratic" only
- Check privacy URL opens correctly
- View calendar with mixed event days → all rows should be same height

