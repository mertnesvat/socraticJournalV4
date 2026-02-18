// CircleDetailView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Detail view for a single circle.
/// Shows circle info, member list, and management actions (edit, add member, delete).
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

            // Members section
            membersSection

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
            addMemberSheet
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

                    Text("\(viewModel.circle.memberCount) member\(viewModel.circle.memberCount == 1 ? "" : "s")")
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
        Section("Members") {
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
        }
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

    // MARK: - Add Member Sheet

    private var addMemberSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Member Name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CircleTheme.warmBrown)

                    TextField("e.g. Mom, Alex", text: $viewModel.newMemberName)
                        .autocorrectionDisabled()
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: .separator), lineWidth: 1)
                        )
                }

                Button {
                    Task { await viewModel.addMember() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Add to Circle")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: !viewModel.newMemberName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? [CircleTheme.warmAmber, CircleTheme.warmOrange]
                                : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(viewModel.newMemberName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { viewModel.showAddMember = false }
                }
            }
        }
        .presentationDetents([.medium])
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
