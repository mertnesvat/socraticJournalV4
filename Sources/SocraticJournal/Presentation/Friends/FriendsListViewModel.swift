// FriendsListViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Friends List screen managing friend data, requests, and search
@Observable
@MainActor
public final class FriendsListViewModel {
    // MARK: - State

    public private(set) var friends: [User] = []
    public private(set) var incomingRequests: [Friendship] = []
    public private(set) var sentRequests: [Friendship] = []
    public private(set) var searchResults: [User] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    public var searchQuery: String = ""

    /// Whether the user is actively searching
    public var isSearching: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Number of friends remaining to unlock the 3-friends gate
    public var friendsRemainingForGate: Int {
        max(0, 3 - friends.count)
    }

    /// Whether the friends gate should be shown
    public var shouldShowFriendsGate: Bool {
        friends.count < 3
    }

    // MARK: - Dependencies

    private let friendService: FriendServiceProtocol

    // MARK: - Init

    public init(friendService: FriendServiceProtocol) {
        self.friendService = friendService
    }

    // MARK: - Actions

    /// Loads friends, incoming requests, and sent requests
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let friendsResult = friendService.getFriends()
            async let incomingResult = friendService.getIncomingRequests()
            async let sentResult = friendService.getSentRequests()

            friends = try await friendsResult
            incomingRequests = try await incomingResult
            sentRequests = try await sentResult
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Searches for users matching the current query
    public func searchUsers() async {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        do {
            let results = try await friendService.searchUsers(query: query)
            // Filter out users who are already friends
            let friendIds = Set(friends.map(\.id))
            searchResults = results.filter { !friendIds.contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Sends a friend request to the specified user
    public func sendFriendRequest(userId: String) async {
        do {
            try await friendService.sendFriendRequest(userId: userId)
            // Remove from search results to indicate request sent
            searchResults.removeAll { $0.id == userId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Accepts an incoming friend request
    public func acceptRequest(id: String) async {
        do {
            try await friendService.acceptFriendRequest(id: id)
            // Remove from incoming requests
            incomingRequests.removeAll { $0.id == id }
            // Reload friends to reflect the change
            if let updatedFriends = try? await friendService.getFriends() {
                friends = updatedFriends
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Declines an incoming friend request (uses remove for now)
    public func declineRequest(id: String) async {
        do {
            try await friendService.removeFriend(id: id)
            incomingRequests.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Removes a friend connection
    public func removeFriend(id: String) async {
        do {
            try await friendService.removeFriend(id: id)
            friends.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
