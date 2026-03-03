// SessionProgressArc.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Thin circular arc showing overall session progress (0% to 100%)
/// Positioned in a corner during active session
public struct SessionProgressArc: View {
    let progress: Double
    let size: CGFloat

    public init(progress: Double, size: CGFloat = 40) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
    }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(AppColors.accent.opacity(0.15), lineWidth: 2)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppColors.accent.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            SessionProgressArc(progress: 0.0)
            SessionProgressArc(progress: 0.5)
            SessionProgressArc(progress: 1.0)
        }
    }
}
#endif
