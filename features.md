---
base_branch: feature/firebase-production-deployment
max_retries: 2
visual_gate_enabled: true
bundle_id: com.StudioNext.socraticJournal

# Deep Quality Mode - enabled for paywall implementation (critical business logic)
deep_quality_mode: true
deep_quality_max_retries: 5
deep_quality_visual_threshold: 0.85
deep_quality_min_test_coverage: 0.8
deep_quality_review_gate: true
---

# Feature Queue: Custom Paywall & Subscription System - Socratic Journal

## Context

The app currently has **no paywall or subscription infrastructure**. There is no Superwall SDK integrated (despite initial plans). This queue implements a complete native StoreKit 2 subscription system from scratch, following the app's existing Clean Architecture patterns.

**Current State:**
- No subscription service or paywall
- No StoreKit integration (only SKStoreReviewController for app reviews)
- Feature gating is engagement-based (journal entries unlock features)
- No premium/subscription fields in UserSettings
- No In-App Purchase entitlement in app capabilities
- Settings shows theme, notifications, features, data management, about

**Target State:**
- Native StoreKit 2 subscription system
- Custom-designed paywall matching app aesthetic
- Subscription management in Settings only (no aggressive paywalls)
- Products correctly fetched from App Store
- Comprehensive unit tests for subscription business logic

**Product IDs (from App Store Connect):**
- Monthly: `com.StudioNext.socraticJournal.monthly`
- Yearly: `com.StudioNext.socraticJournal.yearly`

**Key Requirements:**
- Paywall NOT shown during onboarding
- Paywall NOT auto-shown after purchase
- Subscription accessible only from Settings
- All business logic must have unit tests

**Existing Patterns to Follow:**
- Clean Architecture: Protocol in Domain, Implementation in Data
- MVVM with `@Observable @MainActor` ViewModels
- UserDefaults for settings persistence (`UserDefaultsSettingsRepository`)
- Swift Testing framework for tests (`@Test`, `#expect`)
- UI styling: `RoundedRectangle(cornerRadius: 16)`, subtle shadows, `.systemBackground` colors

---

### 1. Create Subscription Domain Layer

Create domain entities and protocols that define subscription state and operations following Clean Architecture principles.

**User Story:** As a developer, I need domain entities and protocols for subscription management so the subscription system follows the app's established architecture patterns.

**Acceptance Criteria:**
- `SubscriptionStatus` enum: `.free`, `.premium(expiryDate: Date, productId: String)`, `.expired`
- `SubscriptionProduct` struct: `id: String`, `displayName: String`, `displayPrice: String`, `period: SubscriptionPeriod`, `priceValue: Decimal`
- `SubscriptionPeriod` enum: `.monthly`, `.yearly`
- `SubscriptionServiceProtocol` with:
  ```swift
  func fetchProducts() async throws -> [SubscriptionProduct]
  func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus
  func restorePurchases() async throws -> SubscriptionStatus
  func currentStatus() async -> SubscriptionStatus
  var statusStream: AsyncStream<SubscriptionStatus> { get }
  ```
- `SubscriptionError` enum: `.productNotFound`, `.purchaseFailed(Error)`, `.purchaseCancelled`, `.notEntitled`, `.networkError`
- All types are `Sendable`, `Codable` where appropriate, `Equatable`

**Priority:** 1
**Dependencies:** None

**Implementation Notes:**
- Place entities in `Sources/SocraticJournal/Domain/Entities/Subscription.swift`
- Place protocol in `Sources/SocraticJournal/Domain/Services/SubscriptionServiceProtocol.swift`
- Follow patterns from `PersonalityAnalysisServiceProtocol.swift`

---

### 2. Implement StoreKit 2 Subscription Service

Create the StoreKit 2 implementation that fetches products, processes purchases, and manages subscription state.

**User Story:** As a user, I want the app to correctly fetch subscription options from the App Store and process my purchases so that I can subscribe to premium features.

**Acceptance Criteria:**
- `StoreKitSubscriptionService` implementing `SubscriptionServiceProtocol`
- Uses StoreKit 2 `Product.products(for:)` to fetch products
- Handles purchase flow with `product.purchase()`
- Verifies transactions using `Transaction.currentEntitlement(for:)`
- Listens for transaction updates via `Transaction.updates`
- Persists subscription status to UserDefaults for offline access
- Handles both sandbox and production environments
- Proper error mapping to `SubscriptionError`
- Transaction listener starts on init and runs in background

**Priority:** 2
**Dependencies:** Feature 1

**Implementation Notes:**
- Place in `Sources/SocraticJournal/Data/Services/StoreKitSubscriptionService.swift`
- Use `@MainActor` for state updates
- Store last known status in UserDefaults with key `subscription_status`
- Log environment (sandbox vs production) similar to `AppEnvironment.logConfiguration()`

---

### 3. Extend UserSettings with Subscription State

Add subscription-related fields to UserSettings for persistence and backwards compatibility.

**User Story:** As a developer, I need subscription state persisted in UserSettings so the app remembers the user's subscription status across launches.

**Acceptance Criteria:**
- Add to `UserSettings`:
  - `isPremium: Bool` (computed from status, default: false)
  - `subscriptionExpiryDate: Date?` (nil for free users)
  - `activeProductId: String?` (nil for free users)
  - `lastSubscriptionCheck: Date?` (for cache invalidation)
- Backwards compatible decoding (existing users don't crash)
- New CodingKeys added with `decodeIfPresent` defaults

**Priority:** 3
**Dependencies:** Feature 1

**Implementation Notes:**
- Modify `Sources/SocraticJournal/Domain/Entities/UserSettings.swift`
- Follow existing `init(from decoder:)` pattern for migration safety
- Consider computed property `isPremium` based on `subscriptionExpiryDate`

---

### 4. Design Custom Paywall View

Create an attractive paywall screen that matches the app's design language and clearly presents subscription options.

**User Story:** As a user, I want to see a beautiful paywall that clearly shows subscription options and their value so I can make an informed purchase decision.

**Acceptance Criteria:**
- `PaywallView` with:
  - Header with app branding and value proposition
  - Feature list showing what premium unlocks
  - Product cards for monthly and yearly options
  - "Best Value" badge on yearly option showing savings percentage
  - Primary "Subscribe" button with loading state
  - Secondary "Restore Purchases" link
  - Terms of Service and Privacy Policy links
  - Close button (X) in navigation bar
- Loading state while fetching products
- Error state with retry button
- Matches app design:
  - Card style: `RoundedRectangle(cornerRadius: 16)`
  - Shadows: `.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)`
  - Accent gradient for primary CTA (like `StartSessionButton`)
  - System colors: `.systemBackground`, `.secondarySystemBackground`
- Works in both light and dark mode
- Fully accessible (VoiceOver, Dynamic Type)

**Priority:** 4
**Dependencies:** Feature 1, Feature 2

**Implementation Notes:**
- Create `Sources/SocraticJournal/Presentation/Paywall/PaywallView.swift`
- Reference `DiscoveryCard.swift` and `StartSessionButton.swift` for design patterns
- Show percentage savings for yearly (e.g., "Save 40%")

---

### 5. Create PaywallViewModel

Create the ViewModel that manages paywall state, product selection, and purchase flow.

**User Story:** As a developer, I need a ViewModel that encapsulates paywall business logic so the UI remains clean and the logic is testable.

**Acceptance Criteria:**
- `PaywallViewModel` as `@Observable @MainActor` class
- Properties:
  - `products: [SubscriptionProduct]`
  - `selectedProduct: SubscriptionProduct?` (defaults to yearly)
  - `isLoadingProducts: Bool`
  - `isPurchasing: Bool`
  - `error: SubscriptionError?`
  - `purchaseSucceeded: Bool`
- Methods:
  - `loadProducts() async`
  - `selectProduct(_ product: SubscriptionProduct)`
  - `purchase() async -> Bool`
  - `restorePurchases() async -> Bool`
- Dependency injection for `SubscriptionServiceProtocol`
- Analytics logging for paywall events

**Priority:** 5
**Dependencies:** Feature 2, Feature 4

**Implementation Notes:**
- Place in `Sources/SocraticJournal/Presentation/Paywall/PaywallViewModel.swift`
- Follow patterns from `SettingsViewModel.swift`
- Log events: `paywall_viewed`, `product_selected`, `purchase_started`, `purchase_completed`, `purchase_failed`

---

### 6. Add Subscription Section to Settings

Add a subscription management section to the Settings screen for viewing status and accessing the paywall.

**User Story:** As a user, I want to manage my subscription from Settings so I can view my status, upgrade, or restore purchases.

**Acceptance Criteria:**
- `SubscriptionSettingsView` component showing:
  - Current status: "Free" or "Premium" with badge
  - Expiry date if subscribed (formatted nicely)
  - "Upgrade to Premium" button if free (opens PaywallView as sheet)
  - "Manage Subscription" link if premium (opens App Store subscription management)
  - "Restore Purchases" button with loading state
- Section added to `SettingsView` between Notifications and Features sections
- Loading states during restore operation
- Success/error feedback

**Priority:** 6
**Dependencies:** Feature 4, Feature 5

**Implementation Notes:**
- Create `Sources/SocraticJournal/Presentation/Settings/Components/SubscriptionSettingsView.swift`
- Add to `SettingsView.swift` content
- App Store subscription URL: `https://apps.apple.com/account/subscriptions`
- Use `UIApplication.shared.open()` for external links

---

### 7. Add In-App Purchase Entitlement

Configure app entitlements and project settings to enable StoreKit functionality.

**User Story:** As a developer, I need the app configured with In-App Purchase capability so StoreKit can process transactions.

**Acceptance Criteria:**
- `SocraticJournal.entitlements` includes In-App Purchase capability
- `project.yml` updated if needed for entitlement configuration
- Project regenerates correctly with `xcodegen generate`
- Builds successfully in both Debug and Release

**Priority:** 7
**Dependencies:** None

**Implementation Notes:**
- Update `SocraticJournal.entitlements` file
- In-App Purchase capability doesn't require additional entitlement key (automatic with StoreKit import)
- Verify with `xcodegen generate && xcodebuild build`

---

### 8. Create StoreKit Configuration for Testing

Create StoreKit configuration file for local testing without App Store Connect.

**User Story:** As a developer, I need a StoreKit configuration file so I can test subscription flows locally in Xcode.

**Acceptance Criteria:**
- `Configuration.storekit` file created with:
  - Monthly subscription product (`com.StudioNext.socraticJournal.monthly`)
  - Yearly subscription product (`com.StudioNext.socraticJournal.yearly`)
  - Appropriate pricing for testing
  - Subscription group defined
- Can run subscription tests in Xcode simulator
- Can trigger purchase flows, renewals, expiration in sandbox

**Priority:** 8
**Dependencies:** None

**Implementation Notes:**
- Create in project root or Configuration folder
- Configure subscription group for upgrade/downgrade
- Set realistic test prices ($4.99/month, $29.99/year example)

---

### 9. Unit Tests for Subscription Service

Create comprehensive unit tests for the subscription domain and service layer.

**User Story:** As a developer, I need unit tests for subscription logic to ensure correctness and prevent regressions.

**Acceptance Criteria:**
- `MockSubscriptionService` implementing `SubscriptionServiceProtocol`
- `SubscriptionServiceTests.swift` testing:
  - Product fetching (success with products, empty result, network error)
  - Purchase flow (success, cancellation, failure)
  - Restore purchases (found subscription, no subscription)
  - Status transitions (free -> premium, premium -> expired)
  - Expiry date validation
- All tests use Swift Testing framework (`@Test`, `#expect`)
- Tests pass with `xcodebuild test`

**Priority:** 9
**Dependencies:** Feature 1, Feature 2

**Implementation Notes:**
- Place in `Tests/SocraticJournalTests/Subscription/`
- Create `Mocks/MockSubscriptionService.swift`
- Mock should allow configuring return values for each method

---

### 10. Unit Tests for PaywallViewModel

Create unit tests for the PaywallViewModel business logic.

**User Story:** As a developer, I need unit tests for the PaywallViewModel to verify state management and purchase flow logic.

**Acceptance Criteria:**
- `PaywallViewModelTests.swift` testing:
  - Initial state (loading false, no products, no error)
  - `loadProducts()` sets products and loading states correctly
  - `loadProducts()` handles errors and sets error state
  - `selectProduct()` updates selectedProduct
  - `purchase()` transitions states correctly (isPurchasing, purchaseSucceeded)
  - `purchase()` handles cancellation (no error shown)
  - `purchase()` handles failure (error set)
  - `restorePurchases()` success and failure cases
- All tests pass

**Priority:** 10
**Dependencies:** Feature 5, Feature 9

**Implementation Notes:**
- Place in `Tests/SocraticJournalTests/Subscription/PaywallViewModelTests.swift`
- Use MockSubscriptionService for dependency injection
- Test async state transitions

---

### 11. Unit Tests for Onboarding Flow

Create unit tests to verify onboarding business logic and confirm no paywall appears.

**User Story:** As a developer, I need unit tests for onboarding to ensure the flow works correctly and no paywall interrupts it.

**Acceptance Criteria:**
- `OnboardingTests.swift` testing:
  - `hasCompletedOnboarding` starts as false
  - Completing onboarding sets `hasCompletedOnboarding` to true
  - Analytics event logged on completion (`onboardingCompleted`)
  - Skip button completes onboarding same as Continue
  - Replay onboarding resets flag to false then shows again
- Create `MockSettingsRepository` if not exists
- Create `MockAnalyticsService` if not exists
- Verify paywall is NOT triggered during onboarding (no paywall-related calls)

**Priority:** 11
**Dependencies:** None

**Implementation Notes:**
- Place in `Tests/SocraticJournalTests/OnboardingTests.swift`
- Test business logic, not SwiftUI views
- Create mocks in `Tests/SocraticJournalTests/Mocks/`

---

### 12. Integration Test: Full Purchase Flow

Create an integration test that verifies the complete subscription flow from paywall to settings display.

**User Story:** As a developer, I need an integration test to verify the end-to-end subscription flow works correctly.

**Acceptance Criteria:**
- Test verifies:
  1. User starts as free (settings shows "Free")
  2. Products load correctly in paywall
  3. Purchase completes successfully
  4. Settings now shows "Premium" with correct expiry
  5. Relaunching app preserves premium status
- Uses mock service to avoid actual App Store calls
- Documents the expected user journey

**Priority:** 12
**Dependencies:** Feature 6, Feature 9, Feature 10

**Implementation Notes:**
- Can be a documented manual test checklist if XCUITest is complex
- Or create integration test in test target
- Focus on state persistence and UI updates

---

## Implementation Order

```
Phase 1 - Foundation (Parallel)
├── 1. Subscription Domain Layer
├── 7. In-App Purchase Entitlement
└── 8. StoreKit Configuration

Phase 2 - Service Layer
└── 2. StoreKit 2 Service (needs 1)

Phase 3 - Persistence
└── 3. UserSettings Extension (needs 1)

Phase 4 - UI (Sequential)
├── 4. Paywall View (needs 1, 2)
├── 5. PaywallViewModel (needs 2, 4)
└── 6. Settings Subscription Section (needs 4, 5)

Phase 5 - Testing (Parallel)
├── 9. Subscription Service Tests (needs 1, 2)
├── 10. PaywallViewModel Tests (needs 5, 9)
├── 11. Onboarding Tests
└── 12. Integration Test (needs 6, 9, 10)
```

## Testing Checklist

After implementation, verify:

- [ ] Products load from StoreKit configuration in simulator
- [ ] Monthly subscription purchase flow completes
- [ ] Yearly subscription purchase flow completes
- [ ] Purchase cancellation handled (no error shown to user)
- [ ] Purchase failure shows appropriate error
- [ ] Restore purchases finds existing subscription
- [ ] Restore purchases handles "no subscription" case
- [ ] Subscription status persists after app restart
- [ ] Settings shows correct status (Free/Premium)
- [ ] Settings shows correct expiry date format
- [ ] Paywall design matches app aesthetic
- [ ] Paywall works in dark mode
- [ ] Paywall is NOT shown during onboarding
- [ ] Paywall is NOT auto-shown after purchase
- [ ] "Manage Subscription" opens App Store
- [ ] All unit tests pass
- [ ] VoiceOver works on paywall

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

- **Deep Quality Mode is ON** - This is business-critical payment functionality
- Follow existing Clean Architecture patterns strictly
- Use StoreKit 2 APIs only (not StoreKit 1)
- Handle ALL error cases gracefully - payment code must be robust
- Never show technical errors to users - map to friendly messages
- Test with StoreKit configuration file before considering complete
- Subscription status must persist offline
- No aggressive paywall tactics - user accesses from Settings only
- All new code must have unit tests
- Premium features to gate can be determined later - focus on infrastructure first
