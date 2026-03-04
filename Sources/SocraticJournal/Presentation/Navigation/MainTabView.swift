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

    var title: String {
        switch self {
        case .today: return "Today"
        case .breathe: return "Breathe"
        case .learn: return "Learn"
        }
    }

    var icon: String {
        switch self {
        case .today: return "circle.grid.2x1"
        case .breathe: return "wind"
        case .learn: return "book"
        }
    }
}

/// Main tab container with editorial bottom bar
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Services

    let settingsRepository: SettingsRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    let sessionRepository: BreathSessionRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        sessionRepository: BreathSessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.sessionRepository = sessionRepository
        self.analyticsService = analyticsService
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Content area
            ZStack {
                switch selectedTab {
                case .today:
                    TodayView(
                        sessionRepository: sessionRepository,
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        analyticsService: analyticsService
                    )
                case .breathe:
                    BreatheView(
                        sessionRepository: sessionRepository,
                        settingsRepository: settingsRepository,
                        analyticsService: analyticsService
                    )
                case .learn:
                    LearnView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Editorial Tab Bar

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
            VStack(spacing: 4) {
                // Dot indicator above label
                Circle()
                    .fill(isSelected ? AppColors.accent : Color.clear)
                    .frame(width: 5, height: 5)

                Text(tab.title.uppercased())
                    .font(.system(size: 11, weight: isSelected ? .bold : .regular, design: .serif))
                    .tracking(0.8)
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
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

#endif
