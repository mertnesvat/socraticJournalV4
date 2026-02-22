// LockedAnswerOverlay.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Dark overlay with lock icon shown on cards when the user hasn't recorded their own answer
public struct LockedAnswerOverlay: View {
    /// Optional message to display below the lock icon
    var message: String = "Record yours to unlock"

    public var body: some View {
        ZStack {
            // Semi-transparent dark overlay
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.95)

            // Content
            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(message)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Standalone Card With Overlay

/// A complete locked card showing a blurred friend placeholder with the lock overlay
public struct LockedAnswerCard: View {
    let friendName: String?

    /// Color for the avatar based on name
    private var avatarColor: Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let name = friendName ?? "?"
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    public var body: some View {
        ZStack {
            // Base card content (grayed out)
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(.systemGray3))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 100, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 10)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.body)
                    .foregroundStyle(Color(.systemGray4))
                    .frame(width: 36, height: 36)
            }
            .padding(12)
            .frame(minHeight: 80)
            .blur(radius: 4)

            // Overlay
            LockedAnswerOverlay()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview("Overlay") {
    LockedAnswerOverlay()
        .frame(height: 80)
        .padding()
        .background(Color.black)
}

#Preview("Locked Card") {
    VStack(spacing: 12) {
        LockedAnswerCard(friendName: "Luna")
        LockedAnswerCard(friendName: "Kai")
        LockedAnswerCard(friendName: nil)
    }
    .padding()
    .background(Color.black)
}

#endif
