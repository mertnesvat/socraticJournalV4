// BreathPacingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// Main breath pacing screen — dark background, animated circle, phase labels
struct BreathPacingView: View {
    let technique: BreathTechnique
    let durationMinutes: Int
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol
    let onDismiss: () -> Void

    @State private var engine: BreathPacingEngine
    @State private var showCountdown = true
    @State private var showComplete = false
    @State private var completedSession: BreathSession?
    @Environment(\.scenePhase) private var scenePhase

    init(
        technique: BreathTechnique,
        durationMinutes: Int,
        breathSessionRepository: BreathSessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.technique = technique
        self.durationMinutes = durationMinutes
        self.breathSessionRepository = breathSessionRepository
        self.analyticsService = analyticsService
        self.onDismiss = onDismiss
        self._engine = State(initialValue: BreathPacingEngine(
            technique: technique,
            durationMinutes: durationMinutes
        ))
    }

    var body: some View {
        ZStack {
            // Dark background
            AppColors.backgroundDark.ignoresSafeArea()

            if showCountdown {
                CountdownOverlay {
                    showCountdown = false
                    engine.start()
                }
            } else if showComplete, let session = completedSession {
                BreathSessionCompleteView(
                    session: session,
                    technique: technique,
                    breathSessionRepository: breathSessionRepository,
                    onDismiss: onDismiss
                )
            } else {
                pacingContent
            }
        }
        .onChange(of: engine.isComplete) { _, isComplete in
            if isComplete {
                let session = engine.stop()
                completedSession = session
                Task {
                    try? await breathSessionRepository.saveSession(session)
                }
                withAnimation(.easeInOut(duration: 0.5)) {
                    showComplete = true
                }
            }
        }
        .statusBarHidden(true)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background, engine.isRunning, !engine.isPaused {
                engine.pause()
            }
        }
    }

    private var pacingContent: some View {
        VStack {
            // Top stats bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatElapsed(engine.totalElapsedTime))
                        .font(AppTypography.timer)
                        .foregroundStyle(.white.opacity(0.6))
                    Text("elapsed")
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(engine.cyclesCompleted)")
                        .font(AppTypography.timer)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(engine.cyclesCompleted == 1 ? "cycle" : "cycles")
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.xl)

            Spacer()

            // Breathing circle
            BreathCircleView(
                scale: engine.circleScale,
                phaseLabel: engine.currentPhase.name,
                timeRemaining: engine.phaseTimeRemaining
            )
            .accessibilityLabel(engine.currentPhase.name)
            .accessibilityValue(String(format: "%.0f seconds remaining", engine.phaseTimeRemaining))
            .onChange(of: engine.currentPhaseIndex) { _, _ in
                UIAccessibility.post(
                    notification: .announcement,
                    argument: engine.currentPhase.name
                )
            }

            Spacer()

            // Bottom controls
            HStack(spacing: AppSpacing.xxl) {
                // Pause/Resume
                Button {
                    if engine.isPaused {
                        engine.resume()
                    } else {
                        engine.pause()
                    }
                } label: {
                    Image(systemName: engine.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle().fill(Color.white.opacity(0.15))
                        )
                }

                // Stop
                Button {
                    let session = engine.stop()
                    completedSession = session
                    Task {
                        try? await breathSessionRepository.saveSession(session)
                    }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showComplete = true
                    }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle().fill(Color.white.opacity(0.1))
                        )
                }
            }
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    private func formatElapsed(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
#endif
