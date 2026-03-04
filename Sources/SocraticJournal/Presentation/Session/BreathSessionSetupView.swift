// BreathSessionSetupView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The session flow state machine
enum BreathSessionFlowState: Equatable {
    case setup
    case countdown
    case active
    case complete(BreathSession)

    static func == (lhs: BreathSessionFlowState, rhs: BreathSessionFlowState) -> Bool {
        switch (lhs, rhs) {
        case (.setup, .setup): return true
        case (.countdown, .countdown): return true
        case (.active, .active): return true
        case (.complete(let a), .complete(let b)): return a.id == b.id
        default: return false
        }
    }
}

/// Setup screen for configuring and starting a breath session.
/// Manages the full flow: setup -> countdown -> active session -> completion.
struct BreathSessionSetupView: View {
    let repository: BreathSessionRepositoryProtocol
    var initialTechnique: BreathTechnique?
    var onFlowStateChange: ((BreathSessionFlowState) -> Void)?
    var onDone: (() -> Void)?

    @State private var selectedTechnique: BreathTechnique = .resonance
    @State private var selectedDuration: TimeInterval = 300
    @State private var flowState: BreathSessionFlowState = .setup

    var body: some View {
        ZStack {
            switch flowState {
            case .setup:
                setupContent

            case .countdown:
                Color(hex: "0B1426")
                    .ignoresSafeArea()

                CountdownOverlay {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        flowState = .active
                    }
                }

            case .active:
                BreathPacingView(
                    technique: selectedTechnique,
                    duration: selectedDuration,
                    onSessionEnd: { session in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            flowState = .complete(session)
                        }
                    }
                )

            case .complete(let session):
                BreathSessionCompleteView(
                    session: session,
                    repository: repository,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowState = .setup
                        }
                        onDone?()
                    }
                )
            }
        }
        .onChange(of: flowState) { _, newState in
            onFlowStateChange?(newState)
        }
        .onAppear {
            if let technique = initialTechnique {
                selectedTechnique = technique
            }
        }
    }

    // MARK: - Setup Content

    private var setupContent: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Header
                VStack(spacing: AppSpacing.xs) {
                    Text("Breathe")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Choose your technique")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.bottom, AppSpacing.sectionGap)

                // Technique selector
                SectionHeaderView("Technique", showTopBorder: false)

                TechniqueSelector(selectedTechnique: $selectedTechnique)
                    .padding(.bottom, AppSpacing.lg)

                // Science note for selected technique
                Text(selectedTechnique.scienceNote)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sectionGap)
                    .animation(.easeInOut(duration: 0.2), value: selectedTechnique.id)

                // Duration picker
                SectionHeaderView("Duration")

                DurationPicker(selectedDuration: $selectedDuration)
                    .padding(.horizontal, AppSpacing.screenPadding)

                Spacer()

                // Begin button
                AccentPillButton("Begin") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        flowState = .countdown
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }
}

#Preview {
    BreathSessionSetupView(
        repository: UserDefaultsBreathSessionRepository()
    )
}
#endif
