// AddFriendSheet.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Sheet view for adding new friends via search, share link, or contacts
public struct AddFriendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: FriendsListViewModel
    @State private var showShareSheet: Bool = false

    public init(viewModel: FriendsListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            List {
                // Search section
                searchSection

                // Invite options
                inviteSection

                // Search results
                if !viewModel.searchQuery.isEmpty {
                    searchResultsSection
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        viewModel.clearSearch()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(
                    activityItems: [URL(string: "https://socraticjournal.app/invite?ref=share")!]
                )
            }
        }
    }

    // MARK: - Search Section

    private var searchSection: some View {
        Section {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search by username", text: $viewModel.searchQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchQuery) { _, newValue in
                        Task {
                            await viewModel.searchUsers(query: newValue)
                        }
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Invite Section

    private var inviteSection: some View {
        Section {
            Button {
                showShareSheet = true
            } label: {
                Label {
                    Text("Invite via Link")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "link")
                        .foregroundStyle(Color.accentColor)
                }
            }

            Label {
                HStack {
                    Text("Add from Contacts")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5), in: Capsule())
                }
            } icon: {
                Image(systemName: "person.crop.circle.badge.plus")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Search Results Section

    @ViewBuilder
    private var searchResultsSection: some View {
        Section {
            if viewModel.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if viewModel.searchResults.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.slash")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No users found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    Spacer()
                }
            } else {
                ForEach(viewModel.searchResults) { user in
                    HStack(spacing: 12) {
                        Image(systemName: user.avatarImageName ?? "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.accentColor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("@\(user.username)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            Task {
                                await viewModel.addFriend(userId: user.id)
                            }
                        } label: {
                            Text("Add")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Text("Search Results")
        }
    }
}

// MARK: - Share Sheet (UIActivityViewController wrapper)

/// UIKit wrapper for presenting the system share sheet
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AddFriendSheet(
        viewModel: FriendsListViewModel(
            friendshipRepository: MockFriendshipRepository(),
            userProfileRepository: MockUserProfileRepository(),
            voiceAnswerRepository: MockVoiceAnswerRepository()
        )
    )
}
#endif
