// CountdownOverlay.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 3-2-1 countdown overlay before session starts
struct CountdownOverlay: View {
    @State private var count: Int = 3
    @State private var opacity: Double = 1.0
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
            startCountdown()
        }
    }

    private func startCountdown() {
        animateNumber()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            count = 2
            animateNumber()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            count = 1
            animateNumber()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onComplete()
        }
    }

    private func animateNumber() {
        opacity = 1.0
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 0.3
        }
    }
}
#endif
