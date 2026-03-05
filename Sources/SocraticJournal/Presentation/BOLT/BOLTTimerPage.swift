// BOLTTimerPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit
import Combine

/// Page 2 of BOLT test: active timer counting up
public struct BOLTTimerPage: View {
    let onComplete: (TimeInterval) -> Void

    @State private var elapsed: TimeInterval = 0
    @State private var isRunning = false
    @State private var timer: AnyCancellable?
    @State private var startTime: Date?
    @State private var autoStopped = false

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Timer display
            Text(String(format: "%.1f", elapsed))
                .font(.system(size: 56, weight: .bold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(AppColors.textPrimary)

            Text("Hold after a normal exhale")
                .font(.system(size: 15, design: .serif))
                .italic()
                .foregroundStyle(AppColors.accent)
                .padding(.top, 8)

            // Pulsing dot
            Circle()
                .fill(AppColors.accent)
                .frame(width: 8, height: 8)
                .scaleEffect(isRunning ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isRunning)
                .padding(.top, AppSpacing.md)

            if autoStopped {
                Text("Most people stop well before this. If you reached 120s, your CO₂ tolerance is exceptional.")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.md)
            }

            Spacer()

            // Stop button
            Button {
                stopTimer()
            } label: {
                Text("STOP")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .tracking(1)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "C4502A"))
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startTimer() }
        .onDisappear { timer?.cancel() }
    }

    private func startTimer() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isRunning = true
        startTime = Date()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard let start = startTime else { return }
                elapsed = Date().timeIntervalSince(start)
                if elapsed >= 120 {
                    autoStopped = true
                    stopTimer()
                }
            }
    }

    private func stopTimer() {
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.impactOccurred()

        timer?.cancel()
        isRunning = false
        onComplete(elapsed)
    }
}
#endif
