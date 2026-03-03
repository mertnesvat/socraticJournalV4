// MainTabView.swift
// SocraticJournal
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
        case .today: return "circle.grid.2x1.fill"
        case .breathe: return "wind"
        case .learn: return "book.closed.fill"
        case .progress: return "chart.bar.fill"
        }
    }

    var iconInactive: String {
        switch self {
        case .today: return "circle.grid.2x1"
        case .breathe: return "wind"
        case .learn: return "book.closed"
        case .progress: return "chart.bar"
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
    private let sessionRepository: SessionRepositoryProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        sessionRepository: SessionRepositoryProtocol = UserDefaultsSessionRepository()
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.sessionRepository = sessionRepository
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Content area -- switches view based on selectedTab
            ZStack {
                switch selectedTab {
                case .today:
                    TodayView(
                        sessionRepository: sessionRepository,
                        settingsRepository: settingsRepository,
                        onStartBreathing: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = .breathe
                            }
                        },
                        onOpenSettings: {
                            showSettings = true
                        }
                    )
                case .breathe:
                    BreatheView(onSessionCompleted: { session in
                        Task {
                            try? await sessionRepository.saveSession(session)
                        }
                    })
                case .learn:
                    LearnView()
                case .progress:
                    placeholderView(title: "Progress", icon: "chart.bar")
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

    private func placeholderView(title: String, icon: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.accent.opacity(0.5))

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
            HairlineDivider(color: AppColors.tabBarBorder)

            // Tab buttons
            HStack(spacing: 0) {
                ForEach(MainTab.allCases, id: \.rawValue) { tab in
                    tabBarButton(for: tab)
                }
            }
            .frame(height: AppSpacing.tabBarHeight)
            .padding(.bottom, safeAreaBottom)
        }
        .background(AppColors.tabBarBackground)
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
