// LettersBadge.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Badge showing count of ready-to-read letters
public struct LettersBadge: View {
    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "envelope.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            if count > 0 {
                Text(count > 99 ? "99+" : "\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: 8, y: -8)
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        LettersBadge(count: 0)
        LettersBadge(count: 3)
        LettersBadge(count: 99)
        LettersBadge(count: 150)
    }
    .padding()
}
#endif
