// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main tab view for the Circle app
public struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager

    private let settingsRepository: SettingsRepositoryProtocol
    private let subscriptionService: SubscriptionServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    private let circleRepository: CircleRepositoryProtocol
    @Bindable private var authState: AuthState

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        circleRepository: CircleRepositoryProtocol,
        authState: AuthState
    ) {
        self.settingsRepository = settingsRepository
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
        self.circleRepository = circleRepository
        self.authState = authState
    }

    public var body: some View {
        TabView {
            circlesTab
                .tabItem {
                    Label("Circles", systemImage: "person.2.circle.fill")
                }
        }
    }

    @ViewBuilder
    private var circlesTab: some View {
        if let userId = authState.currentUser?.id {
            CircleListView(
                viewModel: CirclesViewModel(
                    repository: circleRepository,
                    currentUserId: userId
                )
            )
        } else {
            ProgressView()
        }
    }
}

#Preview {
    MainTabView(
        settingsRepository: UserDefaultsSettingsRepository(),
        circleRepository: LocalCircleRepository(),
        authState: AuthState(service: LocalAuthService())
    )
    .environment(ThemeManager.shared)
}
#endif
