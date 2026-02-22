// FriendProfileView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Profile detail view for a selected friend
/// Shows avatar, stats, shared questions, and remove-friend action
public struct FriendProfileView: View {
    @Environment(\.dismiss) private var dismiss

    let friend: UserProfile
    let onRemoveFriend: () -> Void

    @State private var showRemoveAlert: Bool = false

    /// Placeholder shared questions
    private let sharedQuestions: [String] = [
        "What is one thing you would change about your morning routine?",
        "If you could have dinner with anyone, who would it be?",
        "What was the best advice you ever received?"
    ]

    public init(friend: UserProfile, onRemoveFriend: @escaping () -> Void) {
        self.friend = friend
        self.onRemoveFriend = onRemoveFriend
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                statsSection
                sharedQuestionsSection
                removeFriendButton
            }
            .padding()
        }
        .navigationTitle(friend.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove Friend", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                onRemoveFriend()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove \(friend.displayName) from your friends? This cannot be undone.")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: friend.avatarImageName ?? "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            Text(friend.displayName)
                .font(.title2)
                .fontWeight(.bold)

            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 32) {
                FriendStatItem(
                    icon: "flame.fill",
                    value: "\(friend.streakCount)",
                    label: "Streak",
                    color: .orange
                )

                FriendStatItem(
                    icon: "person.2.fill",
                    value: "\(friend.friendCount)",
                    label: "Friends",
                    color: .accentColor
                )
            }

            Text("Member since \(friend.joinedAt.formatted(.dateTime.month(.wide).year()))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Shared Questions Section

    private var sharedQuestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Questions you both answered")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(sharedQuestions, id: \.self) { question in
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .foregroundStyle(Color.accentColor)
                        .font(.subheadline)

                    Text(question)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Remove Friend Button

    private var removeFriendButton: some View {
        Button(role: .destructive) {
            showRemoveAlert = true
        } label: {
            HStack {
                Image(systemName: "person.badge.minus")
                Text("Remove Friend")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .padding(.top, 8)
    }
}

// MARK: - Stat Item

/// Reusable stat display component
struct FriendStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        FriendProfileView(
            friend: UserProfile(
                displayName: "Maya Chen",
                username: "maya_c",
                streakCount: 7,
                joinedAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                friendCount: 12
            ),
            onRemoveFriend: {}
        )
    }
}
#endif
