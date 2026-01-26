// LettersCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card component for Letters to Future Self feature
public struct LettersCard: View {
    let sealedCount: Int
    let readyCount: Int
    let onTap: () -> Void

    public init(sealedCount: Int, readyCount: Int, onTap: @escaping () -> Void) {
        self.sealedCount = sealedCount
        self.readyCount = readyCount
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "envelope.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Letters to Future Self")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if readyCount > 0 {
                            // Ready to open badge
                            HStack(spacing: 4) {
                                Image(systemName: "sparkle")
                                    .font(.caption2)
                                Text("\(readyCount) ready")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green)
                            .clipShape(Capsule())
                        }
                    }

                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var statusText: String {
        if sealedCount == 0 && readyCount == 0 {
            return "Write a message to your future self"
        } else if sealedCount > 0 && readyCount == 0 {
            return "\(sealedCount) sealed letter\(sealedCount == 1 ? "" : "s") waiting"
        } else if sealedCount == 0 && readyCount > 0 {
            return "\(readyCount) letter\(readyCount == 1 ? "" : "s") ready to open"
        } else {
            return "\(sealedCount) sealed, \(readyCount) ready to open"
        }
    }
}

#Preview("No Letters") {
    LettersCard(sealedCount: 0, readyCount: 0, onTap: {})
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Has Sealed") {
    LettersCard(sealedCount: 3, readyCount: 0, onTap: {})
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Ready to Open") {
    LettersCard(sealedCount: 2, readyCount: 1, onTap: {})
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
