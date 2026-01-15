// QuestionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the current Socratic question
struct QuestionView: View {
    let question: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Socrates indicator
            HStack(spacing: 8) {
                Image(systemName: "person.fill.questionmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Socrates asks:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Question text
            Text(question)
                .font(.title2.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        QuestionView(question: "What's on your mind today?")

        QuestionView(question: "What makes this important to you? Why does it occupy your thoughts at this moment?")
    }
    .padding()
}
#endif
