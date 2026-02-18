// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root view for the Circle app — circle list with navigation to feed
struct CircleRootView: View {
    let circleRepository: CircleRepositoryProtocol
    let authService: AuthServiceProtocol
    let promptRepository: PromptRepositoryProtocol
    let promptService: PromptGenerationServiceProtocol
    let voiceNoteRepository: VoiceNoteRepositoryProtocol
    let audioService: AudioServiceProtocol
    let audioStorageService: AudioStorageServiceProtocol
    let userProfileRepository: UserProfileRepositoryProtocol
    let currentUserId: String

    var body: some View {
        NavigationStack {
            CircleListView(
                viewModel: CircleListViewModel(
                    circleRepository: circleRepository,
                    authService: authService,
                    currentUserId: currentUserId
                ),
                feedDestination: { circle in
                    CircleFeedView(
                        viewModel: CircleFeedViewModel(
                            circleId: circle.id,
                            currentUserId: currentUserId,
                            circleRepository: circleRepository,
                            promptRepository: promptRepository,
                            promptService: promptService,
                            voiceNoteRepository: voiceNoteRepository,
                            audioService: audioService,
                            audioStorageService: audioStorageService,
                            userProfileRepository: userProfileRepository
                        )
                    )
                }
            )
        }
    }
}
#endif
