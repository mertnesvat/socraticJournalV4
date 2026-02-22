// DisagreementMeter.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Visual meter showing the opinion split on a question with a proportional bar and response count
public struct DisagreementMeter: View {
    let disagreementRatio: Double
    let responseCount: Int

    public init(disagreementRatio: Double, responseCount: Int) {
        self.disagreementRatio = disagreementRatio
        self.responseCount = responseCount
    }

    public var body: some View {
        VStack(spacing: 10) {
            // Percentage headline
            Text(headlineText)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(.white)

            // Split bar
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    // Agree side (left)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * agreeRatio)

                    // Disagree side (right)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.42)) // Hot coral
                        .frame(width: geometry.size.width * disagreementRatio)
                }
            }
            .frame(height: 8)

            // Response count
            Text(formattedResponseCount)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.4))
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private var agreeRatio: Double {
        max(0, 1.0 - disagreementRatio)
    }

    private var headlineText: String {
        let percentage = Int(disagreementRatio * 100)
        return "\(percentage)% disagree on this one"
    }

    private var formattedResponseCount: String {
        if responseCount >= 1000 {
            let thousands = Double(responseCount) / 1000.0
            return String(format: "%.1fK people answered", thousands)
        } else {
            return "\(responseCount) people answered"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 32) {
            DisagreementMeter(
                disagreementRatio: 0.81,
                responseCount: 1203
            )

            DisagreementMeter(
                disagreementRatio: 0.45,
                responseCount: 12400
            )
        }
    }
}
#endif
