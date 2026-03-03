// BreatheView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The main Breathe tab: pattern selection, countdown, active session, and summary
public struct BreatheView: View {
    @State private var viewModel = BreatheViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Callback when session completes (passes the completed session to parent)
    public var onSessionCompleted: ((BreathSession) -> Void)?

    public init(onSessionCompleted: ((BreathSession) -> Void)? = nil) {
        self.onSessionCompleted = onSessionCompleted
    }

    public var body: some View {
        ZStack {
            // Dynamic background with colour arc
            backgroundGradient
                .ignoresSafeArea()

            switch viewModel.screenState {
            case .selection:
                PatternSelectionView(
                    selectedPattern: $viewModel.selectedPattern,
                    selectedDuration: $viewModel.selectedDuration,
                    onBegin: {
                        viewModel.beginSession()
                    }
                )

            case .countdown:
                CountdownView(value: viewModel.countdownValue)

            case .active:
                activeSessionView

            case .summary:
                // Placeholder summary -- replaced in Feature 4
                sessionCompletePlaceholder
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Auto-pause when app goes to background
            if newPhase != .active && viewModel.engine.state == .active {
                viewModel.engine.pause()
            }
        }
        .alert("End Session?", isPresented: $viewModel.showEndConfirmation) {
            Button("Continue", role: .cancel) {}
            Button("End", role: .destructive) {
                viewModel.confirmEndSession()
            }
        } message: {
            Text("Your progress will still be saved.")
        }
    }

    // MARK: - Background Gradient

    private var backgroundGradient: some View {
        let progress = viewModel.engine.sessionProgress

        return LinearGradient(
            colors: [
                AppColors.arcStart,
                Color(
                    red: lerp(10.0/255, 27.0/255, progress),
                    green: lerp(22.0/255, 75.0/255, progress),
                    blue: lerp(40.0/255, 90.0/255, progress)
                )
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 2), value: progress)
    }

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }

    // MARK: - Active Session View

    private var activeSessionView: some View {
        ZStack {
            // Tap to pause/resume
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.togglePause()
                }
                .gesture(
                    // Double-tap to request end session
                    TapGesture(count: 2).onEnded {
                        viewModel.requestEndSession()
                    }
                )

            VStack(spacing: 0) {
                // Top bar: progress arc
                HStack {
                    Spacer()
                    SessionProgressArc(progress: viewModel.engine.sessionProgress, size: 36)
                        .padding(.trailing, AppSpacing.screenPadding)
                        .padding(.top, AppSpacing.lg)
                }

                Spacer()

                // Mountain wave animation
                MountainWaveView(engine: viewModel.engine, reduceMotion: reduceMotion)
                    .frame(height: 200)
                    .padding(.horizontal, AppSpacing.md)

                Spacer()

                // Phase label
                phaseLabel
                    .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onChange(of: viewModel.engine.currentPhase) { _, _ in
            viewModel.checkPhaseHaptic()
        }
        .onChange(of: viewModel.engine.state) { _, _ in
            viewModel.checkPhaseHaptic()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.isPaused ? "Session paused" : viewModel.engine.currentPhase.displayName)
    }

    // MARK: - Phase Label

    private var phaseLabel: some View {
        Group {
            if viewModel.isPaused {
                Text("paused")
                    .font(AppTypography.phaseLabel)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
            } else {
                Text(viewModel.engine.currentPhase.displayName)
                    .font(AppTypography.phaseLabel)
                    .foregroundStyle(viewModel.engine.currentPhase.color)
            }
        }
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: viewModel.engine.currentPhase)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isPaused)
    }

    // MARK: - Session Complete Placeholder

    private var sessionCompletePlaceholder: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.accent)

            if let session = viewModel.engine.completedSession {
                Text(session.formattedDuration)
                    .font(AppTypography.stat)
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(session.breathsCompleted) breaths")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text("Well done.")
                .font(AppTypography.phaseLabelSmall)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            AccentPillButton("Done") {
                if let session = viewModel.engine.completedSession {
                    onSessionCompleted?(session)
                }
                viewModel.returnToSelection()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
    }
}

#Preview {
    BreatheView()
        .environment(ThemeManager.shared)
}
#endif
