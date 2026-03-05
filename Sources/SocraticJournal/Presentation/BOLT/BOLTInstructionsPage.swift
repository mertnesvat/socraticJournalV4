// BOLTInstructionsPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 1 of BOLT test: instructions and explanation
public struct BOLTInstructionsPage: View {
    let onStartTest: () -> Void
    @State private var showExplanation = false

    private let steps = [
        "Sit comfortably and breathe normally for 2 minutes",
        "Take a normal breath in, then a normal breath out",
        "Pinch your nose closed after the exhale",
        "Time how long until you feel the first urge to breathe — not until you can't breathe, just the first desire",
    ]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("BOLT Score")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Body Oxygen Level Test")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.bottom, AppSpacing.md)

                HairlineDivider()
                    .padding(.bottom, AppSpacing.lg)

                // Steps
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(AppColors.accent, lineWidth: 1)
                                    .frame(width: 20, height: 20)
                                Text("\(index + 1)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.accent)
                            }

                            Text(step)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(.bottom, AppSpacing.lg)

                // Warning note
                HStack(alignment: .top, spacing: 8) {
                    Text("⚠")
                        .font(.system(size: 14))
                    Text("This is NOT a maximum breath-hold test. Stop timing at the first involuntary swallow, the first diaphragm contraction, or the first urge to inhale. Your next breath after the test should be calm — if you gasp, you held too long.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "C4502A").opacity(0.9))
                        .lineSpacing(4)
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "C4502A").opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "C4502A").opacity(0.12), lineWidth: 1)
                )
                .padding(.bottom, AppSpacing.lg)

                // Start button
                Button(action: onStartTest) {
                    Text("START TEST")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1)
                        .foregroundStyle(AppColors.surface)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "1C1710"))
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, AppSpacing.md)

                // Explanation disclosure
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showExplanation.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("What is BOLT?")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.accent)
                        Image(systemName: showExplanation ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.accent)
                    }
                }
                .buttonStyle(.plain)

                if showExplanation {
                    Text("The BOLT score was developed by Patrick McKeown as part of the Buteyko breathing method. It measures your body's tolerance to carbon dioxide — the real driver of the urge to breathe. James Nestor tested his own BOLT score throughout his research for 'Breath' and documented how it improved with practice. A higher BOLT score correlates with lower anxiety, better exercise tolerance, improved sleep quality, and stronger parasympathetic tone.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "3D3328"))
                        .lineSpacing(13 * 0.75)
                        .padding(.top, AppSpacing.sm)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
