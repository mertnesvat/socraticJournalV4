// FutureLettersSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Section card for Future Letters in the Self-Discovery tab
/// Shows count of ready-to-open letters and provides quick access to letters list
public struct FutureLettersSection: View {
    let readyCount: Int
    let onTap: () -> Void

    public init(readyCount: Int, onTap: @escaping () -> Void) {
        self.readyCount = readyCount
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and badge
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: "envelope.fill")
                                .font(.title3)
                                .foregroundStyle(Color.purple)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Messages to Future Self")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("Time capsule letters")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Badge for ready letters
                    if readyCount > 0 {
                        HStack(spacing: 4) {
                            Text("\(readyCount)")
                                .font(.subheadline.weight(.bold))
                            Text("ready")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.purple)
                        )
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }

                // Description text
                Text("Write letters to your future self. Set a delivery date and receive a notification when it's time to open them.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                // Call to action
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline)
                    Text("Write New Letter")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Color.purple)
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        FutureLettersSection(readyCount: 0) {
            print("Tapped - no ready letters")
        }

        FutureLettersSection(readyCount: 3) {
            print("Tapped - 3 ready letters")
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
