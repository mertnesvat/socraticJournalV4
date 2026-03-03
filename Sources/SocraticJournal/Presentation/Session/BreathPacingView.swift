// BreathPacingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen immersive breath pacing session view.
///
/// Features:
/// - Deep navy background transitioning over session progress
/// - MountainWaveView centrepiece animation
/// - PhaseLabel below the wave
/// - Subtle progress arc at the top
/// - Tap to pause overlay with resume/end options
struct BreathPacingView: View {
    let technique: BreathTechnique
    let duration: TimeInterval
    let onSessionEnd: (BreathSession) -> Void

    @State private var engine = BreathPacingEngine()
    @State private var isPaused = false

    // Background color interpolation
    private let backgroundStart = Color(hex: "0B1426")
    private let backgroundEnd = Color(hex: "0F2B3C")

    var body: some View {
        ZStack {
            // Animated background
            backgroundGradient
                .ignoresSafeArea()

            // Session content
            sessionContent

            // Progress arc at top
            progressArc

            // Pause overlay
            if isPaused {
                pauseOverlay
            }
        }
        .statusBarHidden(true)
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            engine.startSession(technique: technique, duration: duration)
        }
        .onChange(of: engine.isComplete) { _, isComplete in
            if isComplete {
                let session = engine.stop()
                onSessionEnd(session)
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        // Interpolate background color based on session progress
        let progress = engine.sessionProgress
        let interpolatedColor = interpolateColor(from: backgroundStart, to: backgroundEnd, progress: progress)

        return Rectangle()
            .fill(interpolatedColor)
    }

    private func interpolateColor(from: Color, to: Color, progress: Double) -> Color {
        // Use a simple linear gradient approach
        // The from/to colors will blend based on progress
        let clamped = min(max(progress, 0), 1)
        return Color(
            red: lerp(from: 11.0/255.0, to: 15.0/255.0, t: clamped),
            green: lerp(from: 20.0/255.0, to: 43.0/255.0, t: clamped),
            blue: lerp(from: 38.0/255.0, to: 60.0/255.0, t: clamped)
        )
    }

    private func lerp(from: Double, to: Double, t: Double) -> Double {
        from + (to - from) * t
    }

    // MARK: - Session Content

    private var sessionContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mountain wave animation
            MountainWaveView(
                breathPosition: engine.breathPosition,
                phaseType: engine.currentPhase.phaseType,
                phaseProgress: engine.phaseProgress,
                cyclesCompleted: engine.cyclesCompleted
            )
            .frame(height: 280)

            // Phase label
            PhaseLabel(label: engine.currentPhase.displayLabel)
                .padding(.top, AppSpacing.lg)

            Spacer()

            // Elapsed time
            Text(formatTime(engine.elapsedTime))
                .font(AppTypography.caption)
                .foregroundStyle(Color.white.opacity(0.4))
                .padding(.bottom, AppSpacing.xxl)
        }
    }

    // MARK: - Progress Arc

    private var progressArc: some View {
        VStack {
            GeometryReader { geometry in
                let width = geometry.size.width - AppSpacing.screenPadding * 2

                Path { path in
                    path.addArc(
                        center: CGPoint(x: geometry.size.width / 2, y: 40),
                        radius: width / 2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .stroke(Color.white.opacity(0.08), lineWidth: 1)

                Path { path in
                    path.addArc(
                        center: CGPoint(x: geometry.size.width / 2, y: 40),
                        radius: width / 2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(180 + 180 * engine.sessionProgress),
                        clockwise: false
                    )
                }
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .frame(height: 50)

            Spacer()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Pause Overlay

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent tap-through
                }

            VStack(spacing: AppSpacing.xl) {
                Text("paused")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.9))

                AccentPillButton("Resume") {
                    resumeSession()
                }
                .padding(.horizontal, AppSpacing.xxl)

                Button {
                    endSession()
                } label: {
                    Text("End Session")
                        .font(AppTypography.body)
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func handleTap() {
        guard !isPaused else { return }
        pauseSession()
    }

    private func pauseSession() {
        engine.pause()
        withAnimation(.easeInOut(duration: 0.3)) {
            isPaused = true
        }
    }

    private func resumeSession() {
        engine.resume()
        withAnimation(.easeInOut(duration: 0.3)) {
            isPaused = false
        }
    }

    private func endSession() {
        let session = engine.stop()
        withAnimation(.easeInOut(duration: 0.3)) {
            isPaused = false
        }
        onSessionEnd(session)
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    BreathPacingView(
        technique: .resonance,
        duration: 300,
        onSessionEnd: { _ in }
    )
}
#endif
