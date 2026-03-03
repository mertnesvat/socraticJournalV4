// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum MainTab: Int, CaseIterable {
    case today
    case learn

    var title: String {
        switch self {
        case .today: return "Today"
        case .learn: return "Learn"
        }
    }

    var iconActive: String {
        switch self {
        case .today: return "wind"
        case .learn: return "book.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "wind"
        case .learn: return "book"
        }
    }
}

public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @Environment(ThemeManager.self) private var themeManager

    let settingsRepository: SettingsRepositoryProtocol
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        breathSessionRepository: BreathSessionRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.breathSessionRepository = breathSessionRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .today:
                    TodayDashboardView(
                        breathSessionRepository: breathSessionRepository,
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        analyticsService: analyticsService
                    )
                case .learn:
                    LearnFeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

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
