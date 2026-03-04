// MainTabView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection for main navigation
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
        case .today: return "wind"
        case .breathe: return "lungs.fill"
        case .learn: return "book.fill"
        case .progress: return "chart.bar.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "wind"
        case .breathe: return "lungs"
        case .learn: return "book"
        case .progress: return "chart.bar"
        }
    }
}

/// Main tab container with clean minimal bottom bar
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Services

    let settingsRepository: SettingsRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol
    let sessionRepository: BreathSessionRepositoryProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        sessionRepository: BreathSessionRepositoryProtocol = UserDefaultsBreathSessionRepository()
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.sessionRepository = sessionRepository
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .today:
                    placeholderTab("Today", icon: "wind")
                case .breathe:
                    placeholderTab("Breathe", icon: "lungs.fill")
                case .learn:
                    LearnFeedView(
                        contentService: StaticLearningContentService(),
                        analyticsService: analyticsService
                    )
                case .progress:
                    BreathProgressView(repository: sessionRepository)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Placeholder

    private func placeholderTab(_ title: String, icon: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary)
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
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

#Preview {
    MainTabView(
        settingsRepository: UserDefaultsSettingsRepository(),
        analyticsService: FirebaseAnalyticsService.shared
    )
    .environment(ThemeManager.shared)
}
#endif
