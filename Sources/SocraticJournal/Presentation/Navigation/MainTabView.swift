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

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("💬")
                    .font(.system(size: 80))

                Text("Circle")
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
        settingsRepository: UserDefaultsSettingsRepository()
    )
    .environment(ThemeManager.shared)
}
#endif
