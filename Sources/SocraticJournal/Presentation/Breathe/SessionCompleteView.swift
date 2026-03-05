// SessionCompleteView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// Data passed from BreatheViewModel when a session completes
struct CompletedSessionData {
    let durationSeconds: TimeInterval
    let cyclesCompleted: Int
    let patternName: String
    let patternId: String
    let patternTiming: String
    let totalMinutesToday: Double
    let dailyGoalMinutes: Int
}

/// Full-screen overlay shown when a breath session completes
struct SessionCompleteView: View {
    let data: CompletedSessionData
    let onDone: () -> Void
    let onGoToToday: () -> Void

    // MARK: - Animation State

    @State private var circleProgress: CGFloat = 0
    @State private var showCheckmark = false
    @State private var showTitle = false
    @State private var showContent = false

    // MARK: - Insight State

    @State private var currentInsight: BreathInsight?
    @State private var insightOpacity: Double = 0

    private let insightService = InsightSelectionService()

    // MARK: - Computed

    private var sessionMinutes: Double {
        data.durationSeconds / 60.0
    }

    /// Total including the just-completed session
    private var totalWithSession: Double {
        data.totalMinutesToday + sessionMinutes
    }

    private var goalProgress: Double {
        guard data.dailyGoalMinutes > 0 else { return 1.0 }
        return min(totalWithSession / Double(data.dailyGoalMinutes), 1.0)
    }

    private var goalReached: Bool {
        totalWithSession >= Double(data.dailyGoalMinutes)
    }

    private var remainingMinutes: Double {
        max(Double(data.dailyGoalMinutes) - totalWithSession, 0)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            AppColors.background
                .opacity(0.98)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: AppSpacing.heroTopPadding)

                    // Animated checkmark
                    checkmarkSection
                        .padding(.bottom, AppSpacing.lg)

                    // Title
                    if showTitle {
                        Text("Session Complete")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)
                            .transition(.opacity)
                            .padding(.bottom, AppSpacing.sectionSpacing)
                    }

                    if showContent {
                        // Session summary
                        SessionSummarySection(
                            durationSeconds: data.durationSeconds,
                            cyclesCompleted: data.cyclesCompleted,
                            patternName: data.patternName,
                            patternTiming: data.patternTiming
                        )

                        // Breath insight
                        insightSection
                            .padding(.top, AppSpacing.lg)

                        // Daily progress
                        dailyProgressSection
                            .padding(.top, AppSpacing.md)

                        // Action buttons
                        actionButtons
                            .padding(.top, AppSpacing.sectionSpacing)
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.bottom, AppSpacing.xxl)
                    }
                }
            }
        }
        .onAppear {
            fireHaptic()
            startAnimations()
            loadInitialInsight()
        }
    }

    // MARK: - Checkmark

    private var checkmarkSection: some View {
        ZStack {
            // Teal circle stroke that draws in
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))

            // White checkmark inside
            if showCheckmark {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppColors.accent)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Breath Insight

    private var insightSection: some View {
        VStack(spacing: AppSpacing.xs) {
            if let insight = currentInsight {
                Text("\u{201C}\(insight.text)\u{201D}")
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(AppColors.accent)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(insightOpacity)
                    .id(insight.id)

                Button {
                    rotateInsight()
                } label: {
                    Text("tap for another")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(AppColors.textTertiary)
                        .opacity(insightOpacity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding + AppSpacing.md)
    }

    // MARK: - Daily Progress

    private var dailyProgressSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Today", showTopBorder: false)

            VStack(spacing: AppSpacing.sm) {
                // Donut ring
                GeometricRing(
                    progress: goalProgress,
                    size: 80,
                    lineWidth: 10,
                    accentColor: AppColors.accent,
                    trackColor: AppColors.border
                )

                // Progress text
                Text(String(format: "%.1f / %d min", totalWithSession, data.dailyGoalMinutes))
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)

                // Goal status
                if goalReached {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.accent)

                        Text("Daily goal reached")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.accent)
                    }
                } else {
                    Text(String(format: "%.1f min remaining", remainingMinutes))
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.md)

            HairlineDivider()
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            AccentPillButton("Done") {
                onDone()
            }

            Button {
                onGoToToday()
            } label: {
                Text("Go to Today")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Insight Helpers

    private func loadInitialInsight() {
        currentInsight = insightService.selectInsight(forPatternId: data.patternId)
    }

    private func rotateInsight() {
        guard let current = currentInsight else { return }

        // Fade out
        withAnimation(.easeOut(duration: 0.15)) {
            insightOpacity = 0
        }

        // Swap insight and fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentInsight = insightService.selectNextInsight(
                forPatternId: data.patternId,
                currentId: current.id
            )
            withAnimation(.easeIn(duration: 0.25)) {
                insightOpacity = 1.0
            }
        }
    }

    // MARK: - Helpers

    private func fireHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func startAnimations() {
        // Circle draws over 0.6s
        withAnimation(.easeInOut(duration: 0.6)) {
            circleProgress = 1.0
        }

        // Checkmark fades in at 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                showCheckmark = true
            }
        }

        // Title fades in after checkmark completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeIn(duration: 0.3)) {
                showTitle = true
            }
        }

        // Content fades in after title
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                showContent = true
            }
        }

        // Insight fades in slightly after content
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeIn(duration: 0.4)) {
                insightOpacity = 1.0
            }
        }
    }
}

#Preview {
    SessionCompleteView(
        data: CompletedSessionData(
            durationSeconds: 305,
            cyclesCompleted: 12,
            patternName: "Resonance",
            patternId: "resonance",
            patternTiming: "5.5 \u{00B7} 5.5",
            totalMinutesToday: 3.2,
            dailyGoalMinutes: 5
        ),
        onDone: {},
        onGoToToday: {}
    )
}
#endif
