// PhaseLabel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Lowercase serif label showing the current breath phase.
/// Crossfades with animation on phase change.
struct PhaseLabel: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 28, weight: .regular, design: .serif))
            .foregroundStyle(Color.white.opacity(0.9))
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: label)
    }
}

#Preview {
    ZStack {
        Color(hex: "0B1426").ignoresSafeArea()
        VStack(spacing: 40) {
            PhaseLabel(label: "inhale")
            PhaseLabel(label: "hold")
            PhaseLabel(label: "exhale")
        }
    }
}
#endif
