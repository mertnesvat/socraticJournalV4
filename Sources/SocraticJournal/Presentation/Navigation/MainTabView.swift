// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main tab view for the Circle app
/// Home Feed is the primary tab — the first thing users see after onboarding
public struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager

    private let settingsRepository: SettingsRepositoryProtocol
    private let subscriptionService: SubscriptionServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    private let circleRepository: CircleRepositoryProtocol
    private let promptRepository: PromptRepositoryProtocol
    private let promptGenerationService: PromptGenerationServiceProtocol
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol
    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private let playbackService: AudioPlaybackServiceProtocol
    @Bindable private var authState: AuthState

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        circleRepository: CircleRepositoryProtocol,
        promptRepository: PromptRepositoryProtocol,
        promptGenerationService: PromptGenerationServiceProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        voiceRecordingService: VoiceRecordingServiceProtocol,
        playbackService: AudioPlaybackServiceProtocol,
        authState: AuthState
    ) {
        self.settingsRepository = settingsRepository
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
        self.circleRepository = circleRepository
        self.promptRepository = promptRepository
        self.promptGenerationService = promptGenerationService
        self.voiceNoteRepository = voiceNoteRepository
        self.voiceRecordingService = voiceRecordingService
        self.playbackService = playbackService
        self.authState = authState
    }

    public var body: some View {
        TabView {
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            circlesTab
                .tabItem {
                    Label("Circles", systemImage: "person.2.circle.fill")
                }
        }
    }

    @ViewBuilder
    private var homeTab: some View {
        if let userId = authState.currentUser?.id {
            HomeView(
                viewModel: HomeViewModel(
                    circleRepository: circleRepository,
                    promptRepository: promptRepository,
                    promptGenerationService: promptGenerationService,
                    voiceNoteRepository: voiceNoteRepository,
                    voiceRecordingService: voiceRecordingService,
                    playbackService: playbackService,
                    currentUserId: userId,
                    analyticsService: analyticsService
                ),
                voiceRecordingService: voiceRecordingService,
                playbackService: playbackService,
                voiceNoteRepository: voiceNoteRepository,
                circleRepository: circleRepository,
                settingsRepository: settingsRepository,
                subscriptionService: subscriptionService,
                analyticsService: analyticsService,
                authState: authState
            )
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    private var circlesTab: some View {
        if let userId = authState.currentUser?.id {
            CircleListView(
                viewModel: CirclesViewModel(
                    repository: circleRepository,
                    currentUserId: userId,
                    analyticsService: analyticsService
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
        promptRepository: LocalPromptRepository(),
        promptGenerationService: LocalPromptGenerationService(),
        voiceNoteRepository: LocalVoiceNoteRepository(),
        voiceRecordingService: LocalVoiceRecordingService(),
        playbackService: LocalAudioPlaybackService(),
        authState: AuthState(service: LocalAuthService())
    )
    .environment(ThemeManager.shared)
}
#endif
