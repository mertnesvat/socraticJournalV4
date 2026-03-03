// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for main navigation
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
        case .today: return "circle.grid.2x1.fill"
        case .learn: return "book.closed.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "circle.grid.2x1"
        case .learn: return "book.closed"
        }
    }
}

/// Main tab container with clean minimal bottom bar
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @State private var showSettings: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Services

    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Content area -- switches view based on selectedTab
            ZStack {
                switch selectedTab {
                case .today:
                    placeholderView(title: "Today")
                case .learn:
                    placeholderView(title: "Learn")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Clean minimal bottom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showSettings) {
            SettingsView(
                viewModel: SettingsViewModel(
                    settingsRepository: settingsRepository,
                    notificationService: notificationService,
                    analyticsService: analyticsService
                )
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    // MARK: - Placeholder View

    private func placeholderView(title: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Button {
                showSettings = true
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
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
        analyticsService: FirebaseAnalyticsService.shared
    )
    .environment(ThemeManager.shared)
}
#endif
