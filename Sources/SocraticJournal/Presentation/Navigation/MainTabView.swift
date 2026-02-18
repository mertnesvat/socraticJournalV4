// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Placeholder main view for Circle app
/// This will be replaced with the real home feed in Feature 6
public struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager

    private let settingsRepository: SettingsRepositoryProtocol
    private let subscriptionService: SubscriptionServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    @Bindable private var authState: AuthState

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        authState: AuthState
    ) {
        self.settingsRepository = settingsRepository
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
        self.authState = authState
    }

    private var greeting: String {
        if let name = authState.currentUser?.displayName {
            return "Hey, \(name)"
        }
        return "Circle"
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("💬")
                    .font(.system(size: 80))

                Text(greeting)
                    .font(.largeTitle.bold())

                Text("Voice-first connection\nwith the people who matter")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Text("Building something beautiful...")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    MainTabView(
        settingsRepository: UserDefaultsSettingsRepository(),
        authState: AuthState(service: LocalAuthService())
    )
    .environment(ThemeManager.shared)
}
#endif
