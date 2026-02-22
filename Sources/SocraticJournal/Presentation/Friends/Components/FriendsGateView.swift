// FriendsGateView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Progress indicator for the "3 Friends Gate" showing how close the user is to unlocking all answers
public struct FriendsGateView: View {
    let currentFriendCount: Int
    let requiredCount: Int

    private var progress: Double {
        Double(currentFriendCount) / Double(requiredCount)
    }

    private var remaining: Int {
        max(0, requiredCount - currentFriendCount)
    }

    private var motivationalText: String {
        switch remaining {
        case 0:
            return "You did it! All answers are unlocked."
        case 1:
            return "Almost there! Add 1 more friend to unlock all answers."
        default:
            return "Add \(remaining) more friends to unlock all answers."
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "lock.open.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)

                Text("Unlock All Answers")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(currentFriendCount)/\(requiredCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * min(progress, 1.0),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            // Motivational text
            Text(motivationalText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Friend circles preview
            HStack(spacing: -8) {
                ForEach(0..<requiredCount, id: \.self) { index in
                    Circle()
                        .fill(index < currentFriendCount ? Color.blue.opacity(0.3) : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Group {
                                if index < currentFriendCount {
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "plus")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        FriendsGateView(currentFriendCount: 0, requiredCount: 3)
        FriendsGateView(currentFriendCount: 1, requiredCount: 3)
        FriendsGateView(currentFriendCount: 2, requiredCount: 3)
    }
    .padding()
}
#endif
