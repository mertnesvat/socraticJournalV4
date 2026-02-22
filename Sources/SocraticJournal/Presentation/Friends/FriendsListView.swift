// FriendsListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main friends screen showing friend list, pending requests, and search
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
                .navigationTitle("Friends")
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
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading friends...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        List {
            // Friends Gate (if fewer than 3 friends)
            if viewModel.shouldShowFriendsGate {
                Section {
                    FriendsGateView(
                        currentFriendCount: viewModel.friends.count,
                        requiredCount: 3
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }

            // Pending Requests Section
            if !viewModel.incomingRequests.isEmpty {
                Section {
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
                } header: {
                    Label("Pending Requests", systemImage: "person.badge.clock")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                        .textCase(nil)
                }
            }

            // Friends Section
            Section {
                ForEach(viewModel.friends) { friend in
                    FriendRow(user: friend)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFriend = friend
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let friend = viewModel.friends[index]
                        Task { await viewModel.removeFriend(id: friend.id) }
                    }
                }
            } header: {
                HStack {
                    Text("Your Friends")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(viewModel.friends.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingInviteSheet = true
            } label: {
                Image(systemName: "person.badge.plus")
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
