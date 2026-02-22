// FriendsListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main friends list view for the Friends tab
/// Shows pending requests, 3-friends gate, and the accepted friends list
public struct FriendsListView: View {
    @State private var viewModel: FriendsListViewModel

    public init(viewModel: FriendsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Friends")
                .toolbar { toolbarContent }
                .sheet(isPresented: $viewModel.showingAddFriend) {
                    AddFriendSheet(viewModel: viewModel)
                }
                .confirmationDialog(
                    "Remove Friend",
                    isPresented: $viewModel.showRemoveConfirmation,
                    presenting: viewModel.friendToRemove
                ) { friend in
                    Button("Remove \(friend.displayName)", role: .destructive) {
                        Task {
                            await viewModel.removeFriend(id: friend.id)
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        viewModel.friendToRemove = nil
                    }
                } message: { friend in
                    Text("Are you sure you want to remove \(friend.displayName) from your friends?")
                }
                .task {
                    await viewModel.loadFriends()
                }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.friends.isEmpty && viewModel.pendingRequests.isEmpty {
            ProgressView("Loading friends...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.friends.isEmpty && viewModel.pendingRequests.isEmpty {
            emptyState
        } else {
            friendsList
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("No Friends Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Add your first friend to get started")
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                viewModel.showingAddFriend = true
            } label: {
                Label("Add Friend", systemImage: "person.badge.plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Friends List

    private var friendsList: some View {
        List {
            // Pending requests section
            if !viewModel.pendingRequests.isEmpty {
                pendingRequestsSection
            }

            // 3-friends gate card
            if viewModel.friendCount < 3 {
                friendsGateSection
            }

            // Main friends list
            if !viewModel.friends.isEmpty {
                friendsSection
            }
        }
        .refreshable {
            await viewModel.loadFriends()
        }
    }

    // MARK: - Pending Requests Section

    private var pendingRequestsSection: some View {
        Section {
            ForEach(viewModel.pendingRequests) { request in
                PendingRequestRow(
                    request: request,
                    onAccept: {
                        Task {
                            await viewModel.acceptRequest(id: request.id)
                        }
                    },
                    onDecline: {
                        Task {
                            await viewModel.declineRequest(id: request.id)
                        }
                    }
                )
            }
        } header: {
            HStack(spacing: 6) {
                Text("Friend Requests")
                Text("(\(viewModel.pendingRequests.count))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.yellow, in: Capsule())
            }
        }
    }

    // MARK: - Friends Gate Section

    private var friendsGateSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.orange)
                    Text("Invite 3 friends to unlock answers")
                        .font(.headline)
                }

                // Progress bar
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index < viewModel.friendCount ? Color.accentColor : Color(.systemGray4))
                            .frame(height: 8)
                    }
                }

                Text("\(viewModel.friendCount) of 3 friends added")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    viewModel.showingAddFriend = true
                } label: {
                    Text("Invite")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Friends Section

    private var friendsSection: some View {
        Section {
            ForEach(viewModel.friends) { friend in
                NavigationLink(value: friend) {
                    FriendRow(
                        friend: friend,
                        hasAnswered: viewModel.answerStatuses[friend.id] ?? false
                    )
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    let friend = viewModel.friends[index]
                    viewModel.friendToRemove = friend
                    viewModel.showRemoveConfirmation = true
                }
            }
        } header: {
            Text("Your Friends (\(viewModel.friendCount))")
        }
        .navigationDestination(for: UserProfile.self) { friend in
            FriendProfileView(
                friend: friend,
                onRemoveFriend: {
                    Task {
                        await viewModel.removeFriend(id: friend.id)
                    }
                }
            )
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.showingAddFriend = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Pending Request Row

/// A row displaying a pending friend request with accept/decline actions
struct PendingRequestRow: View {
    let request: Friendship
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(request.userId)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text("wants to be friends")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    onAccept()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)

                Button {
                    onDecline()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Friend Row

/// A row displaying a friend with their answer status
struct FriendRow: View {
    let friend: UserProfile
    let hasAnswered: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: friend.avatarImageName ?? "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text("@\(friend.username)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(hasAnswered ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)

                Text(hasAnswered ? "Answered" : "Waiting")
                    .font(.caption2)
                    .foregroundStyle(hasAnswered ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FriendsListView(
        viewModel: FriendsListViewModel(
            friendshipRepository: MockFriendshipRepository(),
            userProfileRepository: MockUserProfileRepository(),
            voiceAnswerRepository: MockVoiceAnswerRepository()
        )
    )
}
#endif
