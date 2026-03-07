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
    @State private var pendingDuration: Int?
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Services

    let settingsRepository: SettingsRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    let sessionRepository: BreathSessionRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol
    let healthKitService: HealthKitServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        sessionRepository: BreathSessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        healthKitService: HealthKitServiceProtocol = HealthKitService()
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.sessionRepository = sessionRepository
        self.analyticsService = analyticsService
        self.healthKitService = healthKitService
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(
                sessionRepository: sessionRepository,
                settingsRepository: settingsRepository,
                notificationService: notificationService,
                analyticsService: analyticsService,
                healthKitService: healthKitService
            )
            .tag(MainTab.today)
            .tabItem {
                Label(MainTab.today.title, systemImage: MainTab.today.icon)
            }

            BreatheView(
                sessionRepository: sessionRepository,
                settingsRepository: settingsRepository,
                analyticsService: analyticsService,
                healthKitService: healthKitService,
                pendingPatternId: $pendingPatternId,
                pendingDuration: $pendingDuration
            )
            .tag(MainTab.breathe)
            .tabItem {
                Label(MainTab.breathe.title, systemImage: MainTab.breathe.icon)
            }

            LearnView(
                settingsRepository: settingsRepository,
                onStartProgramPattern: { patternId, duration in
                    pendingPatternId = patternId
                    pendingDuration = duration
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .breathe
                    }
                }
            )
            .tag(MainTab.learn)
            .tabItem {
                Label(MainTab.learn.title, systemImage: MainTab.learn.icon)
            }
        }
        .tint(AppColors.accent)
        .preferredColorScheme(themeManager.colorScheme)
        .toolbarBackground(AppColors.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#endif
