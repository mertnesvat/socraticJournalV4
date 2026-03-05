// BreatheView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full Breathe tab screen with pattern selector, wave animation, and pacing controls
public struct BreatheView: View {
    @State private var viewModel: BreatheViewModel
    @State private var completedSession: BreathSession?
    @State private var completedPattern: BreathPattern?
    @Binding var pendingPatternId: String?
    @Binding var pendingDuration: Int?

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        pendingPatternId: Binding<String?> = .constant(nil),
        pendingDuration: Binding<Int?> = .constant(nil)
    ) {
        _viewModel = State(initialValue: BreatheViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository,
            analyticsService: analyticsService
        ))
        _pendingPatternId = pendingPatternId
        _pendingDuration = pendingDuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with duration chips
            headerBar
            HairlineDivider()

            ScrollView {
                VStack(spacing: 0) {
                    // Pattern selector
                    PatternSelectorBar(
                        patterns: BreathPattern.allPatterns,
                        selectedId: viewModel.selectedPattern.id,
                        onSelect: { viewModel.selectPattern($0) }
                    )
                    .padding(.vertical, AppSpacing.md)
                    .allowsHitTesting(!viewModel.engine.isRunning)
                    .opacity(viewModel.engine.isRunning ? 0.5 : 1)

                    HairlineDivider()

                    // Wave animator section
                    waveSection
                        .padding(.vertical, 36)

                    HairlineDivider()

                    // Pattern info
                    PatternInfoSection(pattern: viewModel.selectedPattern)
                }
            }
        }
        .background(AppColors.background)
        .task { await viewModel.loadSettings() }
        .onChange(of: pendingPatternId) { _, patternId in
            if let patternId {
                viewModel.preSelectForProgram(
                    patternId: patternId,
                    durationMinutes: pendingDuration ?? 5
                )
                pendingPatternId = nil
                pendingDuration = nil
            }
        }
        .onChange(of: viewModel.engine.sessionFinished) { _, finished in
            if finished {
                completedPattern = viewModel.selectedPattern
                viewModel.handleSessionFinished()
            }
        }
        .onChange(of: viewModel.lastCompletedSession?.id) { _, _ in
            if let session = viewModel.lastCompletedSession {
                completedSession = session
                completedPattern = completedPattern ?? viewModel.selectedPattern
            }
        }
        .fullScreenCover(item: $completedSession) { session in
            SessionCompleteOverlay(
                session: session,
                pattern: completedPattern ?? viewModel.selectedPattern,
                previousDailyTotal: viewModel.previousDailyTotal,
                dailyGoalMinutes: viewModel.dailyGoalMinutes,
                onDismiss: {
                    completedSession = nil
                    completedPattern = nil
                }
            )
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Text("BREATHE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.accent)

            Spacer()

            DurationChipBar(
                durations: BreatheViewModel.SessionDuration.allCases,
                selected: viewModel.selectedDuration,
                onSelect: { viewModel.selectedDuration = $0 }
            )
            .allowsHitTesting(!viewModel.engine.isRunning)
            .opacity(viewModel.engine.isRunning ? 0.5 : 1)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Wave Section

    private var waveSection: some View {
        VStack(spacing: 24) {
            BreathWaveView(
                phase: viewModel.engine.currentPhase?.phaseType ?? .inhale,
                progress: viewModel.engine.phaseProgress,
                phaseColorHex: viewModel.engine.phaseColor
            )
            .padding(.horizontal, AppSpacing.screenPadding)

            PhaseLabelView(
                phaseName: viewModel.engine.currentPhase?.name ?? "Inhale",
                countdown: viewModel.engine.countdown,
                timing: viewModel.selectedPattern.timing,
                isRunning: viewModel.engine.isRunning,
                phaseColorHex: viewModel.engine.phaseColor
            )

            if viewModel.engine.isRunning {
                // Elapsed timer
                Text(viewModel.elapsedFormatted)
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
                    .monospacedDigit()
            }

            // Action buttons
            HStack(spacing: 12) {
                if viewModel.showStopButton {
                    Button {
                        viewModel.stopSession()
                    } label: {
                        Text("Stop")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    viewModel.toggleSession()
                } label: {
                    Text(viewModel.actionButtonLabel.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1)
                        .foregroundStyle(
                            viewModel.engine.isRunning ? AppColors.textSecondary : AppColors.surface
                        )
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(viewModel.engine.isRunning ? Color.clear : AppColors.textPrimary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    viewModel.engine.isRunning ? AppColors.border : AppColors.textPrimary,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    BreatheView(
        sessionRepository: UserDefaultsBreathSessionRepository()
    )
}
#endif
