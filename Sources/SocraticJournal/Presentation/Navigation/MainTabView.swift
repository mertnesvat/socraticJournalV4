// MainTabView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for main navigation
public enum MainTab: Int, CaseIterable {
    case today
    case breathe
    case learn
    case progress

    var title: String {
        switch self {
        case .today: return "Today"
        case .breathe: return "Breathe"
        case .learn: return "Learn"
        case .progress: return "Progress"
        }
    }

    var iconActive: String {
        switch self {
        case .today: return "sun.max.fill"
        case .breathe: return "wind"
        case .learn: return "book.fill"
        case .progress: return "chart.bar.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "sun.max"
        case .breathe: return "wind"
        case .learn: return "book"
        case .progress: return "chart.bar"
        }
    }
}

/// Main 4-tab container for the Breath Pacer app
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Dependencies

    let settingsRepository: SettingsRepositoryProtocol
    let sessionRepository: BreathSessionRepositoryProtocol
    let contentService: BreathContentServiceProtocol
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        sessionRepository: BreathSessionRepositoryProtocol,
        contentService: BreathContentServiceProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.sessionRepository = sessionRepository
        self.contentService = contentService
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .today:
                    TodayDashboardView(
                        viewModel: TodayDashboardViewModel(
                            sessionRepository: sessionRepository,
                            contentService: contentService,
                            settingsRepository: settingsRepository
                        ),
                        onStartSession: { selectedTab = .breathe }
                    )

                case .breathe:
                    BreatheTabView(
                        sessionRepository: sessionRepository
                    )

                case .learn:
                    LearnFeedView(
                        viewModel: LearnFeedViewModel(contentService: contentService)
                    )

                case .progress:
                    ProgressDashboardView(
                        viewModel: ProgressDashboardViewModel(sessionRepository: sessionRepository)
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Bar

    private var customTabBar: some View {
        VStack(spacing: 0) {
            HairlineDivider()

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
                Image(systemName: isSelected ? tab.iconActive : tab.iconInactive)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textTertiary)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var safeAreaBottom: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
#endif
