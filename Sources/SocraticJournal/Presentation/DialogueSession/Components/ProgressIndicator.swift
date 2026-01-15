// ProgressIndicator.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Progress indicator showing "Question X of Y"
struct ProgressIndicator: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            // Text indicator
            Text("Question \(currentQuestion) of \(totalQuestions)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(uiColor: .systemFill))

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        ProgressIndicator(currentQuestion: 1, totalQuestions: 3, progress: 0.0)

        ProgressIndicator(currentQuestion: 2, totalQuestions: 3, progress: 0.333)

        ProgressIndicator(currentQuestion: 3, totalQuestions: 3, progress: 0.666)
    }
    .padding()
}
#endif
