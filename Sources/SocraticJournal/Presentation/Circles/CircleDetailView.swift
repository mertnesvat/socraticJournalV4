// CircleDetailView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Detail view for a single circle.
/// Shows circle info, member list with count indicator, share invite,
/// and management actions (edit, add member, delete).
struct CircleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CircleDetailViewModel
    private let circleService: CircleServiceProtocol

    init(viewModel: CircleDetailViewModel, circleService: CircleServiceProtocol) {
        _viewModel = State(initialValue: viewModel)
        self.circleService = circleService
    }

    var body: some View {
        List {
            // Circle header
            circleHeaderSection

            // Streak section
            if viewModel.currentStreak > 0 || viewModel.longestStreak > 0 {
                Section {
                    CircleStreakView(
                        currentStreak: viewModel.currentStreak,
                        longestStreak: viewModel.longestStreak,
                        isCompact: false
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }

            // Members section
            membersSection

            // Share invite section
            shareInviteSection

            // Danger zone
            dangerSection
        }
        .navigationTitle(viewModel.circle.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.isEditing {
                    Button("Done") {
                        Task { await viewModel.saveEdits() }
                    }
                    .disabled(viewModel.isLoading)
                } else {
                    Button("Edit") {
                        viewModel.startEditing()
                    }
                }
            }
        }
        .onAppear {
            viewModel.onDeleted = { dismiss() }
        }
        .sheet(isPresented: $viewModel.showAddMember) {
            AddMemberView(
                viewModel: AddMemberViewModel(
                    circle: viewModel.circle,
                    circleService: circleService
                ),
                onMemberAdded: {
                    Task { await viewModel.refresh() }
                }
            )
        }
        .alert(
            "Delete Circle?",
            isPresented: $viewModel.showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteCircle() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(viewModel.circle.name)\" and remove all members. This cannot be undone.")
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .task { await viewModel.refresh() }
    }

    // MARK: - Header Section

    private var circleHeaderSection: some View {
        Section {
            VStack(spacing: 16) {
                // Circle icon
                ZStack {
                    SwiftUI.Circle()
                        .fill(CircleTheme.warmAmber.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: viewModel.circle.emojiIcon)
                        .font(.system(size: 32))
                        .foregroundStyle(CircleTheme.warmAmber)
                }

                if viewModel.isEditing {
                    // Editable name
                    TextField("Circle Name", text: $viewModel.editName)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(uiColor: .tertiarySystemFill))
                        )

                    // Emoji picker for editing
                    EmojiPickerView(selectedEmoji: $viewModel.editIcon)
                } else {
                    Text(viewModel.circle.name)
                        .font(.title3.weight(.semibold))

                    Text("\(viewModel.circle.memberCount) of \(LocalCircleService.maxMembersPerCircle) members")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Members Section

    private var membersSection: some View {
        Section {
            ForEach(viewModel.sortedMembers) { member in
                MemberRowView(member: member)
                    .swipeActions(edge: .trailing) {
                        if !member.isCurrentUser {
                            Button("Remove", role: .destructive) {
                                Task { await viewModel.removeMember(member) }
                            }
                        }
                    }
            }

            // Add member button
            if !viewModel.isAtMaxMembers {
                Button {
                    viewModel.showAddMember = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            SwiftUI.Circle()
                                .strokeBorder(CircleTheme.warmAmber, style: StrokeStyle(lineWidth: 2, dash: [4]))
                                .frame(width: 40, height: 40)

                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(CircleTheme.warmAmber)
                        }

                        Text("Add Member")
                            .font(.body)
                            .foregroundStyle(CircleTheme.warmAmber)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("Maximum of \(LocalCircleService.maxMembersPerCircle) members reached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack {
                Text("Members")
                Spacer()
                Text("\(viewModel.circle.memberCount) of \(LocalCircleService.maxMembersPerCircle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Share Invite Section

    private var shareInviteSection: some View {
        Section {
            ShareLink(
                item: shareInviteText,
                subject: Text("Join my Circle!"),
                message: Text("Join my Circle!")
            ) {
                HStack(spacing: 12) {
                    ZStack {
                        SwiftUI.Circle()
                            .fill(CircleTheme.warmAmber.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(CircleTheme.warmAmber)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Share Invite")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)

                        Text("Invite friends to download Circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    /// The prepopulated share invite text.
    private var shareInviteText: String {
        "Join my Circle \"\(viewModel.circle.name)\"! Download Circle to stay connected through daily voice prompts. [App Store link placeholder]"
    }

    // MARK: - Danger Section

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Circle")
                        .font(.body.weight(.medium))
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Member Row

/// A single row displaying a circle member's avatar and name.
private struct MemberRowView: View {
    let member: CircleMember

    var body: some View {
        HStack(spacing: 12) {
            InitialsAvatarView(
                initials: member.initials,
                avatarImageData: member.avatarImageData,
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(member.displayName)
                        .font(.body.weight(.medium))

                    if member.isCurrentUser {
                        Text("You")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(CircleTheme.warmAmber)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                CircleTheme.warmAmber.opacity(0.15),
                                in: Capsule()
                            )
                    }
                }

                Text("Joined \(member.joinedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CircleDetailView(
            viewModel: {
                let service = MockCircleService()
                let circle = service.circles.first!
                return CircleDetailViewModel(circle: circle, circleService: service)
            }(),
            circleService: MockCircleService()
        )
    }
}
#endif
