// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for main navigation
public enum MainTab: Int, CaseIterable {
    case today
    case friends
    case profile

    var title: String {
        switch self {
        case .today: return "Today"
        case .friends: return "Friends"
        case .profile: return "Profile"
        }
    }

    var iconActive: String {
        switch self {
        case .today: return "mic.fill"
        case .friends: return "person.2.fill"
        case .profile: return "person.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "mic"
        case .friends: return "person.2"
        case .profile: return "person"
        }
    }
}

/// Main tab container with custom floating pill tab bar
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @State private var showRecording: Bool = false
    @State private var pendingRequestCount: Int = 2
    @State private var hasNewAnswers: Bool = true
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Services

    private let questionFeedService: QuestionFeedServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
    private let friendService: FriendServiceProtocol
    private let answerRevealService: AnswerRevealServiceProtocol
    private let voiceRecordingService: VoiceRecordingService
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService

        // Initialize mock services for the pivot
        self.questionFeedService = MockQuestionFeedService()
        self.userProfileService = MockUserProfileService()
        self.friendService = MockFriendService()
        self.answerRevealService = MockAnswerRevealService()
        self.voiceRecordingService = VoiceRecordingService()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Content area -- fills entire screen behind the floating tab bar
            TabView(selection: $selectedTab) {
                // Today Tab
                QuestionFeedView(viewModel: QuestionFeedViewModel(
                    questionFeedService: questionFeedService,
                    userProfileService: userProfileService
                ))
                .tag(MainTab.today)

                // Friends Tab
                FriendsListView(viewModel: FriendsListViewModel(
                    friendService: friendService
                ))
                .tag(MainTab.friends)

                // Profile Tab (placeholder until Feature 8)
                profilePlaceholder
                    .tag(MainTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom floating tab bar
            customTabBar
        }
    }

    // MARK: - Custom Floating Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                tabBarButton(for: tab)
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .fill(Color.black.opacity(0.3))
                )
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabBarButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? tab.iconActive : tab.iconInactive)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.7))

                    // Badge overlays
                    if tab == .friends && pendingRequestCount > 0 {
                        friendsBadge
                    }

                    if tab == .today && hasNewAnswers {
                        newAnswersDot
                    }
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badge Views

    private var friendsBadge: some View {
        Text("\(pendingRequestCount)")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .frame(minWidth: 14, minHeight: 14)
            .padding(.horizontal, 2)
            .background(Color.red)
            .clipShape(Circle())
            .offset(x: 8, y: -6)
    }

    private var newAnswersDot: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 8, height: 8)
            .offset(x: 8, y: -4)
    }

    // MARK: - Profile Placeholder

    private var profilePlaceholder: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("Profile")
                    .font(.title2.bold())
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView(
        settingsRepository: UserDefaultsSettingsRepository(),
        notificationService: LocalNotificationService(),
        subscriptionService: StoreKitSubscriptionService(),
        analyticsService: FirebaseAnalyticsService.shared
    )
    .environment(ThemeManager.shared)
}
#endif
