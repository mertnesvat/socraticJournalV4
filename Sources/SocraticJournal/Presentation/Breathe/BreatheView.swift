// BreatheView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct BreatheView: View {
    @State private var engine = BreathPacingEngine()
    @State private var selectedPatternId: String = "resonance"
    let sessionRepository: BreathSessionRepositoryProtocol

    private var selectedPattern: BreathPattern {
        BreathPattern.allPatterns.first { $0.id == selectedPatternId } ?? .resonance
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Pattern selector
                PatternSelectorBar(
                    patterns: BreathPattern.allPatterns,
                    selectedId: $selectedPatternId
                )

                HairlineDivider()

                // Mountain wave animator
                VStack(spacing: 24) {
                    MountainWaveView(
                        phase: engine.currentPhase.phaseType,
                        progress: engine.phaseProgress
                    )
                    .padding(.top, 36)

                    // Phase label
                    VStack(spacing: 6) {
                        Text(engine.currentPhase.name.lowercased())
                            .font(AppTypography.phaseLabel)
                            .italic()
                            .foregroundStyle(phaseColor)
                            .animation(.easeInOut(duration: 0.4), value: engine.currentPhaseIndex)

                        Text(engine.isRunning ? "\(Int(engine.phaseTimeRemaining))s" : selectedPattern.timing)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AppColors.textQuaternary)
                    }

                    // Begin / Pause button
                    Button {
                        if engine.isRunning {
                            engine.pause()
                        } else if engine.totalElapsedTime > 0 {
                            engine.resume()
                        } else {
                            engine.start()
                        }
                    } label: {
                        Text(engine.isRunning ? "PAUSE" : "BEGIN")
                            .font(AppTypography.patternPill)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(engine.isRunning ? AppColors.textTertiary : AppColors.surface)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(engine.isRunning ? Color.clear : AppColors.textPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(engine.isRunning ? AppColors.border : AppColors.textPrimary, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 24)
                }

                HairlineDivider()

                // Pattern info
                PatternInfoSection(pattern: selectedPattern)
            }
        }
        .onChange(of: selectedPatternId) { _, newId in
            if let pattern = BreathPattern.allPatterns.first(where: { $0.id == newId }) {
                engine.selectPattern(pattern)
            }
        }
    }

    private var phaseColor: Color {
        switch engine.currentPhase.phaseType {
        case .inhale: return AppColors.phaseInhale
        case .hold: return AppColors.phaseHold
        case .exhale: return AppColors.phaseExhale
        }
    }
}
#endif
