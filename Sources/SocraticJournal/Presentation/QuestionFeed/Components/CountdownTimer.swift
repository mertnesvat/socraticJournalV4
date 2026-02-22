// CountdownTimer.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a live countdown timer until the next daily question arrives (midnight)
/// Minimal right-aligned caption style
public struct CountdownTimer: View {
    let targetInterval: TimeInterval

    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?

    public init(timeUntilNext: TimeInterval) {
        self.targetInterval = timeUntilNext
    }

    public var body: some View {
        Text("Next in \(formattedTime)")
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.textTertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onAppear {
                remainingSeconds = max(0, Int(targetInterval))
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }

    // MARK: - Formatting

    private var formattedTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            let seconds = remainingSeconds % 60
            return "\(minutes)m \(seconds)s"
        }
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    CountdownTimer(timeUntilNext: 43200) // 12 hours
        .padding(.horizontal, AppSpacing.screenPadding)
        .background(AppColors.background)
}
#endif
