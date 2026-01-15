// CharacterCounter.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays character count status with validation feedback
public struct CharacterCounter: View {
    let status: CharacterCountStatus

    public init(status: CharacterCountStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.caption)

            Text(status.displayText)
                .font(.caption)

            Spacer()

            if case .valid(let remaining) = status {
                // Show progress-like indicator for valid state
                progressIndicator(remaining: remaining)
            }
        }
        .foregroundStyle(status.color)
    }

    private var iconName: String {
        switch status {
        case .empty:
            return "text.cursor"
        case .tooShort:
            return "exclamationmark.triangle"
        case .valid:
            return "checkmark.circle"
        case .tooLong:
            return "xmark.circle"
        }
    }

    private func progressIndicator(remaining: Int) -> some View {
        let maxChars = ComposeLetterViewModel.maxCharacters
        let minChars = ComposeLetterViewModel.minCharacters
        let current = maxChars - remaining
        let progress = Double(current - minChars) / Double(maxChars - minChars)

        return Circle()
            .trim(from: 0, to: min(1.0, progress))
            .stroke(progressColor(for: remaining), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 16, height: 16)
            .rotationEffect(.degrees(-90))
            .background(
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 2)
            )
    }

    private func progressColor(for remaining: Int) -> Color {
        if remaining < 100 {
            return .orange
        } else if remaining < 500 {
            return .yellow
        } else {
            return .green
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CharacterCounter(status: .empty)
        CharacterCounter(status: .tooShort(needed: 15))
        CharacterCounter(status: .valid(remaining: 1500))
        CharacterCounter(status: .valid(remaining: 300))
        CharacterCounter(status: .valid(remaining: 50))
        CharacterCounter(status: .tooLong(excess: 25))
    }
    .padding()
}
#endif
