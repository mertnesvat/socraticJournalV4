// BreatheView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full Breathe tab screen with pattern selector, wave animation, and pacing controls
public struct BreatheView: View {
    @State private var viewModel: BreatheViewModel
    @Binding var selectedTab: MainTab
    @Binding var pendingPatternId: String?
    @Binding var pendingDurationMinutes: Int?

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        selectedTab: Binding<MainTab> = .constant(.breathe),
        pendingPatternId: Binding<String?> = .constant(nil),
        pendingDurationMinutes: Binding<Int?> = .constant(nil)
    ) {
        _selectedTab = selectedTab
        _pendingPatternId = pendingPatternId
        _pendingDurationMinutes = pendingDurationMinutes
        _viewModel = State(initialValue: BreatheViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository,
            analyticsService: analyticsService
        ))
    }

    private var showSessionComplete: Bool {
        viewModel.completedSessionData != nil
    }

    public var body: some View {
        ZStack {
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
                            onSelect: { viewModel.selectPattern($0) },
                            recommendedPatternId: viewModel.recommendedPatternId,
                            showRecommendedBadge: !viewModel.userDidOverrideSelection
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

            // Session complete overlay
            if let data = viewModel.completedSessionData {
                SessionCompleteView(
                    data: data,
                    onDone: {
                        viewModel.dismissCompletion()
                    },
                    onGoToToday: {
                        viewModel.dismissCompletion()
                        selectedTab = .today
                    }
                )
                .transition(.opacity)
            }
        }
        .task {
            viewModel.applyRecommendedDefault()
            await viewModel.loadSettings()
        }
        .onChange(of: pendingPatternId) { _, newValue in
            if let patternId = newValue, let duration = pendingDurationMinutes {
                viewModel.applyPendingSelection(patternId: patternId, durationMinutes: duration)
                pendingPatternId = nil
                pendingDurationMinutes = nil
            }
        }
        .onChange(of: viewModel.engine.sessionFinished) { _, finished in
            if finished {
                viewModel.handleSessionFinished()
            }
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
        sessionRepository: UserDefaultsBreathSessionRepository(),
        selectedTab: .constant(.breathe)
    )
}
#endif
