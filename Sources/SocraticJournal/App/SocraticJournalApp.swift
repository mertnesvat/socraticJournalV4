// SocraticJournalApp.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import FirebaseCore

/// Main entry point for the Circle app
@main
public struct SocraticJournalApp: App {
    // Infrastructure (kept from Socratic Journal)
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let subscriptionService: SubscriptionServiceProtocol = StoreKitSubscriptionService()
    @State private var themeManager = ThemeManager.shared

    // Circle services (all mock/local — Firebase swapped later)
    private let authService = MockAuthService()
    private let userProfileRepository: UserProfileRepositoryProtocol = InMemoryUserProfileRepository()
    private let circleRepository: CircleRepositoryProtocol = InMemoryCircleRepository()
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol = InMemoryVoiceNoteRepository()
    private let promptRepository: PromptRepositoryProtocol = InMemoryPromptRepository()
    private let audioService = AudioService()
    private let audioStorageService: AudioStorageServiceProtocol = LocalAudioStorageService()
    private let promptService: PromptGenerationServiceProtocol = LocalPromptGenerationService()

    public init() {
        AppEnvironment.logConfiguration()
        FirebaseApp.configure()
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    public var body: some Scene {
        WindowGroup {
            CircleRootView(
                circleRepository: circleRepository,
                authService: authService,
                promptRepository: promptRepository,
                promptService: promptService,
                voiceNoteRepository: voiceNoteRepository,
                audioService: audioService,
                audioStorageService: audioStorageService,
                userProfileRepository: userProfileRepository,
                currentUserId: MockAuthService.mockUsers[0].id
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .task {
                await themeManager.loadTheme()
                await authService.autoSignInIfNeeded()
            }
        }
    }
}
#endif
