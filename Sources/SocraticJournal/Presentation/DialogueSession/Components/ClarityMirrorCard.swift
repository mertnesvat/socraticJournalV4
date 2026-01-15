// ClarityMirrorCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the AI-generated clarity mirror reflection
struct ClarityMirrorCard: View {
    let reflection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.orange)

                Text("Clarity Mirror")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            // Reflection text
            Text(reflection)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        ClarityMirrorCard(
            reflection: "Your words reveal a search for meaning beyond the surface. There's wisdom in questioning what we take for granted."
        )

        ClarityMirrorCard(
            reflection: "I sense a desire for authenticity in your reflection. The examined life requires such courage."
        )
    }
    .padding()
}
#endif
