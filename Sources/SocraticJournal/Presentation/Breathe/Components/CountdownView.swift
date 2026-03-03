// CountdownView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 3-2-1 countdown displayed before a session begins
public struct CountdownView: View {
    let value: Int

    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Text("\(value)")
                .font(AppTypography.phaseLabel)
                .foregroundStyle(AppColors.accent)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)
                .accessibilityLabel("Starting in \(value)")
        }
    }
}

#Preview {
    CountdownView(value: 3)
}
#endif
