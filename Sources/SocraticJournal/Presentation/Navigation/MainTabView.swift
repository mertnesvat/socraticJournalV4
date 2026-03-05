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
    @State private var pendingPatternId: String?
    @State private var pendingDurationMinutes: Int?
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
        TabView(selection: $selectedTab) {
            TodayView(
                sessionRepository: sessionRepository,
                settingsRepository: settingsRepository,
                notificationService: notificationService,
                analyticsService: analyticsService,
                onNavigateToBreathe: { patternId, durationMinutes in
                    pendingPatternId = patternId
                    pendingDurationMinutes = durationMinutes
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .breathe
                    }
                }
            )
            .tabItem {
                Label("Today", systemImage: "circle.grid.2x1")
            }
            .tag(MainTab.today)

            BreatheView(
                sessionRepository: sessionRepository,
                settingsRepository: settingsRepository,
                analyticsService: analyticsService,
                selectedTab: $selectedTab,
                pendingPatternId: $pendingPatternId,
                pendingDurationMinutes: $pendingDurationMinutes
            )
            .tabItem {
                Label("Breathe", systemImage: "wind")
            }
            .tag(MainTab.breathe)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(MainTab.learn)
        }
        .tint(AppColors.accent)
    }
}

#endif
