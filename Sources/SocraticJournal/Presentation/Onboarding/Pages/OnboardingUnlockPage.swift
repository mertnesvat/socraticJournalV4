// OnboardingUnlockPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 2: "Answer to Unlock" page.
/// Shows an animated lock-to-unlock transition and mock friend avatars with waveform bars.
public struct OnboardingUnlockPage: View {
    // MARK: - Animation State

    @State private var isUnlocked: Bool = false
    @State private var waveformVisible: Bool = false

    // MARK: - Body

    public var body: some View {
        OnboardingPageView(
            title: "Answer to Unlock",
            subtitle: "You can't hear their answer until you record yours."
        ) {
            VStack(spacing: 32) {
                lockIcon
                friendAvatars
            }
        }
        .onAppear {
            // Trigger unlock animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    isUnlocked = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    waveformVisible = true
                }
            }
        }
    }

    // MARK: - Lock Icon

    private var lockIcon: some View {
        Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
            .font(.system(size: 80, weight: .light))
            .foregroundStyle(isUnlocked ? Color.accentColor : Color.gray)
            .scaleEffect(isUnlocked ? 1.1 : 1.0)
            .rotationEffect(.degrees(isUnlocked ? -15 : 0))
    }

    // MARK: - Friend Avatars with Waveforms

    private var friendAvatars: some View {
        HStack(spacing: 20) {
            friendAvatar(initials: "JK", color: .purple)
            friendAvatar(initials: "AM", color: .blue)
            friendAvatar(initials: "TS", color: .pink)
        }
        .opacity(waveformVisible ? 1 : 0)
    }

    private func friendAvatar(initials: String, color: Color) -> some View {
        VStack(spacing: 8) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 48, height: 48)

                Text(initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }

            // Mini waveform bars
            miniWaveform(color: color)
        }
    }

    private func miniWaveform(color: Color) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                MiniWaveformBar(
                    color: color,
                    index: index,
                    isAnimating: waveformVisible
                )
            }
        }
        .frame(height: 16)
    }
}

// MARK: - Mini Waveform Bar

private struct MiniWaveformBar: View {
    let color: Color
    let index: Int
    let isAnimating: Bool

    @State private var barHeight: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(color.opacity(0.7))
            .frame(width: 3, height: barHeight)
            .onAppear {
                guard isAnimating else { return }
                startAnimation()
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    startAnimation()
                }
            }
    }

    private func startAnimation() {
        let delay = Double(index) * 0.1
        withAnimation(
            .easeInOut(duration: 0.4)
            .repeatForever(autoreverses: true)
            .delay(delay)
        ) {
            barHeight = CGFloat.random(in: 6...16)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingUnlockPage()
    }
}
#endif
