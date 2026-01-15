// SocratesReactionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays Socrates' emotional reaction to the user's answer
struct SocratesReactionView: View {
    let reaction: String

    var body: some View {
        HStack(spacing: 12) {
            // Socrates icon
            Circle()
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "brain.head.profile")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

            // Reaction text
            Text(reaction)
                .font(.body)
                .italic()
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        SocratesReactionView(reaction: "Socrates nods slowly, contemplating your words...")

        SocratesReactionView(reaction: "A knowing smile crosses Socrates' face...")

        SocratesReactionView(reaction: "Socrates strokes his beard thoughtfully...")
    }
    .padding()
}
#endif
