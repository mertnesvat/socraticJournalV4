// StartSessionButton.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Prominent button to start a new journal session
public struct StartSessionButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Session")
                        .font(.headline)

                    Text("Begin a Socratic dialogue")
                        .font(.caption)
                        .opacity(0.9)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.title3)
            }
            .foregroundStyle(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        StartSessionButton {
            print("Start session tapped")
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
