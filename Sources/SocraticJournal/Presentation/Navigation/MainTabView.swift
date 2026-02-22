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

/// Main tab container with clean minimal bottom bar
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
        VStack(spacing: 0) {
            // Content area — switches view based on selectedTab
            ZStack {
                switch selectedTab {
                case .today:
                    QuestionFeedView(viewModel: QuestionFeedViewModel(
                        questionFeedService: questionFeedService,
                        userProfileService: userProfileService
                    ))

                case .friends:
                    FriendsListView(viewModel: FriendsListViewModel(
                        friendService: friendService
                    ))

                case .profile:
                    ProfileView(
                        viewModel: ProfileViewModel(userProfileService: userProfileService),
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        subscriptionService: subscriptionService,
                        analyticsService: analyticsService
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Clean minimal bottom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Clean Minimal Tab Bar

    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Hairline top border
            HairlineDivider()

            // Tab buttons
            HStack(spacing: 0) {
                ForEach(MainTab.allCases, id: \.rawValue) { tab in
                    tabBarButton(for: tab)
                }
            }
            .frame(height: AppSpacing.tabBarHeight)
            .padding(.bottom, safeAreaBottom)
        }
        .background(AppColors.background)
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
                        .foregroundStyle(isSelected ? AppColors.accent : AppColors.textTertiary)

                    // Badge overlays — small coral-red dots
                    if tab == .friends && pendingRequestCount > 0 {
                        friendsBadge
                    }

                    if tab == .today && hasNewAnswers {
                        newAnswersDot
                    }
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badge Views

    private var friendsBadge: some View {
        Circle()
            .fill(AppColors.accent)
            .frame(width: 8, height: 8)
            .offset(x: 8, y: -4)
    }

    private var newAnswersDot: some View {
        Circle()
            .fill(AppColors.accent)
            .frame(width: 8, height: 8)
            .offset(x: 8, y: -4)
    }

    // MARK: - Helpers

    private var safeAreaBottom: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
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
