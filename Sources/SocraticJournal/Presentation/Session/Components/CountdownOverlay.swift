// CountdownOverlay.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen 3-2-1 countdown before a breath session begins
struct CountdownOverlay: View {
    let onComplete: () -> Void

    @State private var currentNumber: Int = 3
    @State private var opacity: Double = 1.0
    @State private var scale: Double = 0.8

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            Text("\(currentNumber)")
                .font(.system(size: 96, weight: .bold, design: .serif))
                .foregroundStyle(Color.white)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        animateNumber()
    }

    private func animateNumber() {
        // Reset for new number
        opacity = 0.0
        scale = 0.8

        // Fade in and scale up
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 1.0
            scale = 1.0
        }

        // Fade out after holding
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 0.0
                scale = 1.1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if currentNumber > 1 {
                    currentNumber -= 1
                    animateNumber()
                } else {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    CountdownOverlay(onComplete: {})
}
#endif
