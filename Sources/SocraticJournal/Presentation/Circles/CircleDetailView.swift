// CircleDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Detailed view for a single circle showing members, invite code, and actions
public struct CircleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var circle: CircleGroup
    @State private var viewModel: CirclesViewModel
    @State private var members: [CircleMember] = []
    @State private var showingAddMember = false
    @State private var showingLeaveAlert = false
    @State private var newMemberName = ""
    @State private var inviteCode: String?
    @State private var isLoadingCode = false
    @State private var isLoadingMembers = false

    public init(circle: CircleGroup, viewModel: CirclesViewModel) {
        _circle = State(initialValue: circle)
        _viewModel = State(initialValue: viewModel)
        _inviteCode = State(initialValue: circle.inviteCode)
    }

    private var isAtMaxMembers: Bool {
        circle.memberIds.count >= CircleGroup.maxMembers
    }

    public var body: some View {
        List {
            circleHeaderSection
            membersSection
            inviteSection
            dangerSection
        }
        .navigationTitle(circle.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddMember) {
            addMemberSheet
        }
        .alert("Leave Circle", isPresented: $showingLeaveAlert) {
            Button("Leave", role: .destructive) {
                leaveCircle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave \"\(circle.name)\"? You will need a new invite code to rejoin.")
        }
        .task {
            await loadMembers()
        }
        .onChange(of: viewModel.circles) { _, newCircles in
            if let updated = newCircles.first(where: { $0.id == circle.id }) {
                circle = updated
                Task { await loadMembers() }
            }
        }
    }

    // MARK: - Sections

    private var circleHeaderSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(circle.emoji)
                        .font(.system(size: 64))

                    Text(circle.name)
                        .font(.title2.bold())

                    Text("Week \(circle.weekNumber)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    private var membersSection: some View {
        Section {
            if isLoadingMembers {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(members) { member in
                    MemberRowView(member: member)
                }
            }

            if !isAtMaxMembers {
                Button {
                    showingAddMember = true
                } label: {
                    Label("Add Member", systemImage: "person.badge.plus")
                }
            }
        } header: {
            Text("Members (\(circle.memberIds.count)/\(CircleGroup.maxMembers))")
        } footer: {
            if isAtMaxMembers {
                Text("This circle is full. Maximum \(CircleGroup.maxMembers) members allowed.")
                    .font(.caption)
            }
        }
    }

    private var inviteSection: some View {
        Section("Invite Code") {
            if let code = inviteCode {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(code)
                            .font(.system(.title2, design: .monospaced).bold())
                            .tracking(4)

                        Text("Share this code to invite someone")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        UIPasteboard.general.string = code
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            } else {
                Button {
                    generateCode()
                } label: {
                    if isLoadingCode {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 4)
                            Text("Generating...")
                        }
                    } else {
                        Label("Generate Invite Code", systemImage: "key.fill")
                    }
                }
                .disabled(isLoadingCode)
            }
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showingLeaveAlert = true
            } label: {
                Label("Leave Circle", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }

    // MARK: - Add Member Sheet

    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section("Member Name") {
                    TextField("Enter their name", text: $newMemberName)
                        .submitLabel(.done)
                }

                Section {
                    Text("You are adding a simulated member for now. When your friend joins the app, they can connect with an invite code.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newMemberName = ""
                        showingAddMember = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                    }
                    .fontWeight(.semibold)
                    .disabled(newMemberName.trimmingCharacters(in: .whitespaces).count < 2)
                }
            }
        }
    }

    // MARK: - Actions

    private func loadMembers() async {
        isLoadingMembers = true
        members = await viewModel.fetchMembers(for: circle)
        isLoadingMembers = false
    }

    private func addMember() {
        let name = newMemberName.trimmingCharacters(in: .whitespaces)
        guard name.count >= 2 else { return }

        showingAddMember = false
        newMemberName = ""

        Task {
            await viewModel.addMember(name: name, to: circle)
        }
    }

    private func generateCode() {
        isLoadingCode = true
        Task {
            inviteCode = await viewModel.generateInviteCode(for: circle)
            isLoadingCode = false
        }
    }

    private func leaveCircle() {
        Task {
            await viewModel.removeMember(userId: viewModel.currentUserId, from: circle)
            await viewModel.deleteCircle(id: circle.id)
            dismiss()
        }
    }
}

// MARK: - Member Row

private struct MemberRowView: View {
    let member: CircleMember

    private var initials: String {
        let words = member.displayName.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(member.displayName.prefix(2)).uppercased()
    }

    private var roleLabel: String {
        switch member.role {
        case .creator: return "Creator"
        case .member: return member.isSimulated ? "Simulated" : "Member"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar circle with initials
            Text(initials)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(avatarColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.body)

                Text(roleLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if member.role == .creator {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
    }

    private var avatarColor: Color {
        // Deterministic color based on userId
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo]
        let index = abs(member.userId.hashValue) % colors.count
        return colors[index]
    }
}


#Preview {
    let userId = UUID()
    let circle = CircleGroup(
        name: "Family",
        emoji: "👨‍👩‍👧",
        creatorId: userId,
        memberIds: [userId]
    )
    return NavigationStack {
        CircleDetailView(
            circle: circle,
            viewModel: CirclesViewModel(
                repository: LocalCircleRepository(),
                currentUserId: userId
            )
        )
    }
    .environment(ThemeManager.shared)
}
#endif
