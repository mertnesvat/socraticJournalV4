// OnboardingVoicePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 3: "Voice hits different" page.
/// Displays a decorative animated waveform to convey the energy of voice messages.
public struct OnboardingVoicePage: View {
    // MARK: - Animation State

    @State private var waveformActive: Bool = false

    // MARK: - Body

    public var body: some View {
        OnboardingPageView(
            title: "Voice hits different",
            subtitle: "Text is dead. Voice captures the hesitation, the laughter, the passion."
        ) {
            decorativeWaveform
                .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                waveformActive = true
            }
        }
    }

    // MARK: - Decorative Waveform

    private var decorativeWaveform: some View {
        VStack(spacing: 24) {
            // Main large waveform
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<30, id: \.self) { index in
                    DecorativeBar(
                        index: index,
                        isAnimating: waveformActive,
                        accentColor: barColor(for: index)
                    )
                }
            }
            .frame(height: 80)
            .opacity(waveformActive ? 1 : 0.3)

            // Decorative smaller waveform below
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<40, id: \.self) { index in
                    DecorativeBar(
                        index: index,
                        isAnimating: waveformActive,
                        accentColor: .gray.opacity(0.4),
                        maxHeight: 24,
                        minHeight: 2,
                        barWidth: 2
                    )
                }
            }
            .frame(height: 24)
            .opacity(waveformActive ? 0.6 : 0.1)
        }
    }

    // MARK: - Bar Color

    private func barColor(for index: Int) -> Color {
        let progress = Double(index) / 30.0
        if progress < 0.33 {
            return Color.purple.opacity(0.8)
        } else if progress < 0.66 {
            return Color.blue.opacity(0.9)
        } else {
            return Color.cyan.opacity(0.8)
        }
    }
}

// MARK: - Decorative Bar

private struct DecorativeBar: View {
    let index: Int
    let isAnimating: Bool
    var accentColor: Color = .blue
    var maxHeight: CGFloat = 80
    var minHeight: CGFloat = 6
    var barWidth: CGFloat = 4

    @State private var currentHeight: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: barWidth / 2)
            .fill(accentColor)
            .frame(width: barWidth, height: currentHeight)
            .onAppear {
                guard isAnimating else { return }
                startPulsing()
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    startPulsing()
                }
            }
    }

    private func startPulsing() {
        let randomDelay = Double(index) * 0.05
        let randomDuration = Double.random(in: 0.4...0.8)
        withAnimation(
            .easeInOut(duration: randomDuration)
            .repeatForever(autoreverses: true)
            .delay(randomDelay)
        ) {
            currentHeight = CGFloat.random(in: minHeight...maxHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingVoicePage()
    }
}
#endif
