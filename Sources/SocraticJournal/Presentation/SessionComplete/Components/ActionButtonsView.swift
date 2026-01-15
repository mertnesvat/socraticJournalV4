// ActionButtonsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Action buttons for the session complete screen
public struct ActionButtonsView: View {
    let onWriteLetter: () -> Void
    let onBackToHome: () -> Void

    public init(
        onWriteLetter: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        self.onWriteLetter = onWriteLetter
        self.onBackToHome = onBackToHome
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Write Letter button (primary action)
            Button {
                onWriteLetter()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.badge.person.crop")
                        .font(.body.weight(.medium))

                    Text("Write Letter to Future Self")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Back to Home button (secondary action)
            Button {
                onBackToHome()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house")
                        .font(.body.weight(.medium))

                    Text("Back to Home")
                        .font(.body.weight(.medium))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()

        ActionButtonsView(
            onWriteLetter: { print("Write letter tapped") },
            onBackToHome: { print("Back to home tapped") }
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
