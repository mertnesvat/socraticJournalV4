// FriendsListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main friends screen — structured editorial grid with cream background and hairline borders
public struct FriendsListView: View {
    @State private var viewModel: FriendsListViewModel
    @State private var showingInviteSheet: Bool = false
    @State private var selectedFriend: User?
    @State private var searchTask: Task<Void, Never>?

    public init(viewModel: FriendsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .background(AppColors.background)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.loadData() }
                .searchable(
                    text: $viewModel.searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search by username"
                )
                .onChange(of: viewModel.searchQuery) { _, newValue in
                    searchTask?.cancel()
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        guard !Task.isCancelled else { return }
                        await viewModel.searchUsers()
                    }
                }
                .sheet(item: $selectedFriend) { friend in
                    FriendProfileSheet(
                        friend: friend,
                        onRemoveFriend: {
                            Task {
                                await viewModel.removeFriend(id: friend.id)
                                selectedFriend = nil
                            }
                        }
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showingInviteSheet) {
                    InviteFriendsButton.InviteActivityView()
                        .presentationDetents([.medium, .large])
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearching {
            FriendSearchView(
                searchResults: viewModel.searchResults,
                searchQuery: viewModel.searchQuery,
                onSendRequest: { userId in
                    Task { await viewModel.sendFriendRequest(userId: userId) }
                }
            )
        } else if viewModel.isLoading && viewModel.friends.isEmpty {
            loadingView
        } else if let error = viewModel.errorMessage, viewModel.friends.isEmpty {
            errorView(error)
        } else if viewModel.friends.isEmpty && viewModel.incomingRequests.isEmpty {
            emptyStateView
        } else {
            friendsList
        }
    }

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading friends...")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Friends Yet",
            systemImage: "person.2.slash",
            description: Text("Search for friends by username or invite them to join Socratic.")
        )
    }

    private var friendsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Page header
                SectionHeaderView("Friends", showTopBorder: false)

                // Friends Gate (if fewer than 3 friends)
                if viewModel.shouldShowFriendsGate {
                    FriendsGateView(
                        currentFriendCount: viewModel.friends.count,
                        requiredCount: 3
                    )
                }

                // Pending Requests Section
                if !viewModel.incomingRequests.isEmpty {
                    SectionHeaderView("Pending Requests")

                    ForEach(viewModel.incomingRequests) { request in
                        let requestUser = userForRequest(request)
                        FriendRequestRow(
                            user: requestUser,
                            onAccept: {
                                Task { await viewModel.acceptRequest(id: request.id) }
                            },
                            onDecline: {
                                Task { await viewModel.declineRequest(id: request.id) }
                            }
                        )
                    }
                }

                // Your Friends Section
                SectionHeaderView("Your Friends")

                ForEach(viewModel.friends) { friend in
                    FriendRow(user: friend)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFriend = friend
                        }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingInviteSheet = true
            } label: {
                Image(systemName: "person.badge.plus")
                    .foregroundStyle(AppColors.accent)
            }
        }
    }

    // MARK: - Helpers

    /// Finds the user associated with a friend request
    private func userForRequest(_ request: Friendship) -> User {
        // The request comes from userId wanting to befriend friendId (current user)
        // So we need to display the sender (userId)
        if let matchedUser = MockDataProvider.allUsers.first(where: { $0.id == request.userId }) {
            return matchedUser
        }
        // Fallback user if not found in mock data
        return User(
            id: request.userId,
            displayName: "Unknown User",
            username: "unknown",
            createdAt: Date(),
            streakCount: 0,
            friendCount: 0
        )
    }
}

#Preview {
    FriendsListView(
        viewModel: FriendsListViewModel(
            friendService: MockFriendService()
        )
    )
}
#endif
