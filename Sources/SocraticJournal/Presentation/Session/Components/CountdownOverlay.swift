// CountdownOverlay.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// 3-2-1 countdown overlay before session starts
struct CountdownOverlay: View {
    @State private var count: Int = 3
    @State private var opacity: Double = 1.0
    @State private var countdownTask: Task<Void, Never>?
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()

            Text("\(count)")
                .font(.system(size: 120, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .opacity(opacity)
        }
        .onAppear {
            countdownTask = Task { @MainActor in
                await startCountdown()
            }
        }
        .onDisappear {
            countdownTask?.cancel()
        }
    }

    @MainActor
    private func startCountdown() async {
        animateNumber()

        try? await Task.sleep(for: .seconds(1))
        guard !Task.isCancelled else { return }
        count = 2
        animateNumber()

        try? await Task.sleep(for: .seconds(1))
        guard !Task.isCancelled else { return }
        count = 1
        animateNumber()

        try? await Task.sleep(for: .seconds(1))
        guard !Task.isCancelled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onComplete()
    }

    private func animateNumber() {
        opacity = 1.0
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 0.3
        }
    }
}
#endif
