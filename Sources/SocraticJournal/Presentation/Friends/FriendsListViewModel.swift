// FriendsListViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// ViewModel driving the Friends tab
/// Coordinates friend list, pending requests, search, and friend management actions
@Observable
@MainActor
public final class FriendsListViewModel {
    // MARK: - Published State

    /// Accepted friends list
    public private(set) var friends: [UserProfile] = []

    /// Incoming pending friend requests
    public private(set) var pendingRequests: [Friendship] = []

    /// Search results for add-friend flow
    public private(set) var searchResults: [UserProfile] = []

    /// Current search query text
    public var searchQuery: String = ""

    /// Whether a search operation is in progress
    public private(set) var isSearching: Bool = false

    /// Total accepted friend count
    public private(set) var friendCount: Int = 0

    /// Controls presentation of the add-friend sheet
    public var showingAddFriend: Bool = false

    /// Loading state for initial data load
    public private(set) var isLoading: Bool = false

    /// Error state
    public private(set) var error: Error?

    /// Currently selected friend for navigation
    public var selectedFriend: UserProfile?

    /// Controls presentation of the remove-friend confirmation dialog
    public var showRemoveConfirmation: Bool = false

    /// The friend targeted for removal
    public var friendToRemove: UserProfile?

    /// Mock answer status keyed by friend ID (true = answered)
    public private(set) var answerStatuses: [String: Bool] = [:]

    // MARK: - Dependencies

    private let friendshipRepository: FriendshipRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol

    // MARK: - Initialization

    public init(
        friendshipRepository: FriendshipRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    ) {
        self.friendshipRepository = friendshipRepository
        self.userProfileRepository = userProfileRepository
        self.voiceAnswerRepository = voiceAnswerRepository
    }

    // MARK: - Actions

    /// Loads the full friends list, pending requests, and friend count
    public func loadFriends() async {
        isLoading = true
        error = nil

        friends = await friendshipRepository.getFriends()
        pendingRequests = await friendshipRepository.getPendingRequests()
        friendCount = await friendshipRepository.getFriendCount()

        // Generate mock answer statuses for each friend
        for friend in friends {
            answerStatuses[friend.id] = Bool.random()
        }

        isLoading = false
    }

    /// Accepts an incoming friend request by friendship ID
    public func acceptRequest(id: String) async {
        do {
            try await friendshipRepository.acceptRequest(friendshipId: id)
            // Reload to reflect changes
            await loadFriends()
        } catch {
            self.error = error
        }
    }

    /// Declines an incoming friend request by removing the friendship
    public func declineRequest(id: String) async {
        // For mock, remove from local pending list
        pendingRequests.removeAll { $0.id == id }
    }

    /// Removes an accepted friend by user ID
    public func removeFriend(id: String) async {
        do {
            try await friendshipRepository.removeFriend(userId: id)
            friends.removeAll { $0.id == id }
            answerStatuses.removeValue(forKey: id)
            friendCount = max(0, friendCount - 1)
        } catch {
            self.error = error
        }
    }

    /// Searches for users matching the given query
    public func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        let results = await friendshipRepository.searchUsers(query: query)

        // Filter out users who are already friends or have pending requests
        let friendIds = Set(friends.map { $0.id })
        let pendingIds = Set(pendingRequests.map { $0.userId })
        searchResults = results.filter { !friendIds.contains($0.id) && !pendingIds.contains($0.id) }

        isSearching = false
    }

    /// Sends a friend request to the given user ID
    public func addFriend(userId: String) async {
        do {
            try await friendshipRepository.addFriend(userId: userId)
            // Remove from search results after adding
            searchResults.removeAll { $0.id == userId }
        } catch {
            self.error = error
        }
    }

    /// Clears the current search state
    public func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
    }
}
