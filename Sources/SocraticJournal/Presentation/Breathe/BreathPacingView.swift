// BreathPacingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen immersive breath pacing experience with mountain wave animation
struct BreathPacingView: View {
    let technique: BreathTechnique
    let durationMinutes: Int
    let sessionRepository: BreathSessionRepositoryProtocol
    var onDismiss: () -> Void

    @State private var engine: BreathPacingEngine?
    @State private var countdownValue: Int = 3
    @State private var showCountdown: Bool = true
    @State private var showComplete: Bool = false
    @State private var completedSession: BreathSession?
    @Environment(\.scenePhase) private var scenePhase

    // Background colour arc: deep navy → warmer blue-teal
    private var backgroundGradient: Color {
        let progress = (engine?.totalElapsedTime ?? 0) / Double(durationMinutes * 60)
        let clampedProgress = min(progress, 1.0)
        // Interpolate from deep navy to blue-teal
        return Color(
            red: 0.04 + clampedProgress * 0.02,
            green: 0.04 + clampedProgress * 0.06,
            blue: 0.08 + clampedProgress * 0.04
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            if showCountdown {
                countdownOverlay
            } else if let engine, showComplete, let session = completedSession {
                sessionCompleteOverlay(session: session)
            } else if let engine {
                pacingContent(engine: engine)
            }
        }
        .onAppear {
            engine = BreathPacingEngine(technique: technique, durationMinutes: durationMinutes)
            startCountdown()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                engine?.pause()
            } else if newPhase == .active, engine?.isPaused == true, !showCountdown, !showComplete {
                engine?.resume()
            }
        }
        .onChange(of: engine?.isComplete ?? false) { _, isComplete in
            if isComplete {
                if let session = engine?.stop() {
                    completedSession = session
                    Task {
                        try? await sessionRepository.saveSession(session)
                    }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showComplete = true
                    }
                }
            }
        }
        .statusBarHidden()
    }

    // MARK: - Countdown Overlay

    private var countdownOverlay: some View {
        Text("\(countdownValue)")
            .font(.system(size: 80, weight: .light, design: .serif))
            .foregroundStyle(.white.opacity(0.8))
            .transition(.opacity)
    }

    private func startCountdown() {
        countdownValue = 3

        func tick() {
            guard countdownValue > 1 else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCountdown = false
                }
                engine?.start()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    countdownValue -= 1
                }
                tick()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                countdownValue -= 1
            }
            tick()
        }
    }

    // MARK: - Pacing Content

    @ViewBuilder
    private func pacingContent(engine: BreathPacingEngine) -> some View {
        VStack(spacing: 0) {
            // Top bar: elapsed time + cycles
            HStack {
                Text(formatTime(engine.totalElapsedTime))
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Text("\(engine.cyclesCompleted) cycles")
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.lg)

            // Progress arc at top
            GeometryReader { geo in
                let progress = engine.totalElapsedTime / engine.sessionDurationTarget
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(height: 2)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(.white.opacity(0.4))
                            .frame(width: geo.size.width * min(progress, 1.0))
                    }
            }
            .frame(height: 2)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.sm)

            Spacer()

            // Mountain wave animation
            MountainWaveView(
                cycleProgress: engine.cycleProgress,
                currentPhase: engine.currentPhase.phaseType,
                phaseProgress: engine.phaseProgress,
                color: AppColors.cardTeal
            )
            .frame(height: 200)
            .padding(.horizontal, AppSpacing.xl)

            Spacer()

            // Phase label — lowercase serif
            VStack(spacing: AppSpacing.xs) {
                Text(engine.currentPhase.name)
                    .font(.system(size: 34, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: engine.currentPhaseIndex)

                Text(String(format: "%.1f", engine.phaseTimeRemaining))
                    .font(AppTypography.timer)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
            }

            Spacer()

            // Tap to pause hint
            if engine.isPaused {
                VStack(spacing: AppSpacing.md) {
                    Text("Paused")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(.white.opacity(0.7))

                    HStack(spacing: AppSpacing.md) {
                        Button {
                            engine.resume()
                        } label: {
                            Text("Resume")
                                .font(AppTypography.bodyBold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.xl)
                                .padding(.vertical, AppSpacing.md)
                                .background(Capsule().fill(.white.opacity(0.2)))
                        }

                        Button {
                            let session = engine.stop()
                            completedSession = session
                            Task {
                                try? await sessionRepository.saveSession(session)
                            }
                            showComplete = true
                        } label: {
                            Text("End")
                                .font(AppTypography.bodyBold)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, AppSpacing.xl)
                                .padding(.vertical, AppSpacing.md)
                                .background(Capsule().stroke(.white.opacity(0.3)))
                        }
                    }
                }
                .padding(.bottom, AppSpacing.xxl)
            } else {
                Text("tap to pause")
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.bottom, AppSpacing.xxl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if engine.isPaused {
                engine.resume()
            } else {
                engine.pause()
            }
        }
    }

    // MARK: - Session Complete

    @ViewBuilder
    private func sessionCompleteOverlay(session: BreathSession) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.success)

            Text("Well done")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(.white)

            VStack(spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.xl) {
                    VStack(spacing: 4) {
                        Text(session.formattedDuration)
                            .font(AppTypography.headlineMedium)
                            .foregroundStyle(.white)
                        Text("duration")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    VStack(spacing: 4) {
                        Text("\(session.cyclesCompleted)")
                            .font(AppTypography.headlineMedium)
                            .foregroundStyle(.white)
                        Text("cycles")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(.top, AppSpacing.md)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule().fill(.white)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
#endif
