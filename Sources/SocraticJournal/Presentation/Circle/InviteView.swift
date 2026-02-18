// InviteView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View for sharing a circle's invite code
struct InviteShareView: View {
    let circle: Circle
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text(circle.emoji)
                    .font(.system(size: 60))

                Text("Invite to \(circle.name)")
                    .font(.title2.bold())

                VStack(spacing: 8) {
                    Text("Share this code")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(circle.inviteCode)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .tracking(8)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(spacing: 12) {
                    ShareLink(
                        item: "Join my circle \"\(circle.name)\" on Circle! Use code: \(circle.inviteCode)",
                        subject: Text("Join my Circle"),
                        message: Text("I'd love to hear your voice every day")
                    ) {
                        Label("Share Invite", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        UIPasteboard.general.string = circle.inviteCode
                    } label: {
                        Label("Copy Code", systemImage: "doc.on.doc")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Join Circle View

struct JoinCircleView: View {
    let circleRepository: CircleRepositoryProtocol
    let currentUserId: String
    let onJoined: () -> Void

    @State private var inviteCode = ""
    @State private var isJoining = false
    @State private var error: String?
    @State private var joinedCircle: Circle?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "person.2.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Join a Circle")
                    .font(.title2.bold())

                Text("Enter the invite code shared\nby a circle member")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Invite Code", text: $inviteCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 40)

                if let error {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                if let circle = joinedCircle {
                    VStack(spacing: 8) {
                        Text("\(circle.emoji) \(circle.name)")
                            .font(.headline)
                        Text("You're in!")
                            .font(.title3.bold())
                            .foregroundStyle(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Button {
                    Task { await joinCircle() }
                } label: {
                    Group {
                        if isJoining {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Join Circle")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(inviteCode.count >= 6 ? .blue : .gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(inviteCode.count < 6 || isJoining)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func joinCircle() async {
        isJoining = true
        error = nil

        do {
            guard let circle = try await circleRepository.findCircle(byInviteCode: inviteCode.trimmingCharacters(in: .whitespaces)) else {
                error = "No circle found with that code"
                isJoining = false
                return
            }

            if circle.isFull {
                error = "This circle is full (max \(Circle.maxMembers) members)"
                isJoining = false
                return
            }

            if circle.memberIds.contains(currentUserId) {
                error = "You're already in this circle"
                isJoining = false
                return
            }

            let member = CircleMember(userId: currentUserId, displayName: "You")
            try await circleRepository.addMember(member, to: circle.id)

            withAnimation {
                joinedCircle = circle
            }

            try? await Task.sleep(for: .seconds(1.5))
            onJoined()
            dismiss()
        } catch {
            self.error = "Failed to join circle"
        }

        isJoining = false
    }
}
#endif
