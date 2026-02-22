// SocraticTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for the new Socratic Journal navigation
public enum SocraticTab: Int, CaseIterable {
    case today
    case friends
    case profile
}

/// Main tab container for the pivoted Socratic Journal app
/// Provides 3-tab navigation: Today, Friends, Profile
public struct SocraticTabView: View {
    @State private var selectedTab: SocraticTab = .today
    @State private var pendingRequestCount: Int = 0

    // MARK: - Repository Dependencies

    private let questionRepository: QuestionRepositoryProtocol
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    private let friendshipRepository: FriendshipRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol
    private let reactionRepository: ReactionRepositoryProtocol

    public init(
        questionRepository: QuestionRepositoryProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        friendshipRepository: FriendshipRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        reactionRepository: ReactionRepositoryProtocol
    ) {
        self.questionRepository = questionRepository
        self.voiceAnswerRepository = voiceAnswerRepository
        self.friendshipRepository = friendshipRepository
        self.userProfileRepository = userProfileRepository
        self.streakRepository = streakRepository
        self.reactionRepository = reactionRepository
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            TodayPlaceholderView()
                .tabItem {
                    Label("Today", systemImage: "mic.circle.fill")
                }
                .tag(SocraticTab.today)

            FriendsPlaceholderView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(SocraticTab.friends)
                .badge(pendingRequestCount)

            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(SocraticTab.profile)
        }
        .tint(.accentColor)
        .task {
            await loadPendingRequestCount()
        }
    }

    // MARK: - Private Helpers

    private func loadPendingRequestCount() async {
        let pendingRequests = await friendshipRepository.getPendingRequests()
        pendingRequestCount = pendingRequests.count
    }
}
#endif
