// AnswerInputView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Text input field for user answers
struct AnswerInputView: View {
    @Binding var text: String
    let placeholder: String

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("Your response")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Text editor
            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $text)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .frame(minHeight: 120)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color(uiColor: .separator), lineWidth: 1)
            )

            // Character hint
            Text("Take your time. There's no right or wrong answer.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            // Auto-focus the text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

#Preview {
    VStack {
        AnswerInputView(
            text: .constant(""),
            placeholder: "Share your thoughts..."
        )

        AnswerInputView(
            text: .constant("I've been thinking about my career lately..."),
            placeholder: "Share your thoughts..."
        )
    }
    .padding()
}
#endif
