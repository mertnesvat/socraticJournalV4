// CountdownTimer.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a live countdown timer until the next daily question arrives (midnight)
public struct CountdownTimer: View {
    let targetInterval: TimeInterval

    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?

    public init(timeUntilNext: TimeInterval) {
        self.targetInterval = timeUntilNext
    }

    public var body: some View {
        VStack(spacing: 4) {
            Text("Next question in")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(Color.white.opacity(0.4))

            Text(formattedTime)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.5))
        }
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
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
    ZStack {
        Color.black.ignoresSafeArea()

        CountdownTimer(timeUntilNext: 43200) // 12 hours
    }
}
#endif
