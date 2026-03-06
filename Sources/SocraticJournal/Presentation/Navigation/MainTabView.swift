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
                analyticsService: analyticsService
            )
            .tag(MainTab.today)
            .tabItem {
                Label(MainTab.today.title, systemImage: MainTab.today.icon)
            }

            BreatheView(
                sessionRepository: sessionRepository,
                settingsRepository: settingsRepository,
                analyticsService: analyticsService,
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
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    // MARK: - Deep Link Handling

    /// Handles `rumi://breathe?patternId=<id>` deep links from the widget.
    private func handleDeepLink(_ url: URL) {
        guard url.scheme?.lowercased() == "rumi" else { return }
        guard let host = url.host?.lowercased(), host == "breathe" else {
            // Unknown host — just open the Breathe tab
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = .breathe }
            return
        }

        // Extract optional patternId query parameter
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let patternId = components?.queryItems?.first(where: { $0.name == "patternId" })?.value

        // Set pending pattern before switching tab so BreatheView picks it up
        if let patternId, !patternId.isEmpty {
            pendingPatternId = patternId
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = .breathe
        }
    }
}

#endif
