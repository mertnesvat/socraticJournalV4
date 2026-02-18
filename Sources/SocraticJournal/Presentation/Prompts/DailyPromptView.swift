// DailyPromptView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays today's daily prompt for a circle.
/// Supports both compact mode (for feed headers) and expanded mode (standalone).
struct DailyPromptView: View {
    @State private var viewModel: DailyPromptViewModel
    let isCompact: Bool
    var onRecordTapped: (() -> Void)?

    init(
        viewModel: DailyPromptViewModel,
        isCompact: Bool = false,
        onRecordTapped: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.isCompact = isCompact
        self.onRecordTapped = onRecordTapped
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.prompt == nil {
                loadingView
            } else if let prompt = viewModel.prompt {
                if isCompact {
                    compactPromptCard(prompt)
                } else {
                    expandedPromptCard(prompt)
                }
            } else if let error = viewModel.error {
                errorView(error)
            }
        }
        .task {
            await viewModel.loadTodaysPrompt()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(CircleTheme.warmAmber)
            Text("Loading today's prompt...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 16 : 32)
    }

    // MARK: - Error

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(CircleTheme.warmOrange)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await viewModel.loadTodaysPrompt() }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(CircleTheme.warmAmber)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Compact Card

    private func compactPromptCard(_ prompt: Prompt) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category label
            categoryLabel(prompt)

            // Prompt text
            Text(prompt.text)
                .font(.body.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)
                .lineLimit(2)

            // Record CTA
            if let onRecordTapped {
                Button {
                    onRecordTapped()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "mic.fill")
                            .font(.caption)
                        Text("Record your response")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(CircleTheme.primaryGradient, in: Capsule())
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CircleTheme.cream)
        )
        .onAppear {
            Task { await viewModel.markSeen() }
        }
    }

    // MARK: - Expanded Card

    private func expandedPromptCard(_ prompt: Prompt) -> some View {
        VStack(spacing: 24) {
            // Category icon
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.warmAmber.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: prompt.category.iconName)
                    .font(.system(size: 26))
                    .foregroundStyle(CircleTheme.warmAmber)
            }

            // Category label
            categoryLabel(prompt)

            // Prompt text
            Text(prompt.text)
                .font(.title3.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Depth indicator
            depthIndicator(prompt.depth)

            // Record CTA
            if let onRecordTapped {
                Button {
                    onRecordTapped()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.body)
                        Text("Record your response")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(CircleTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(CircleTheme.cream)
        )
        .onAppear {
            Task { await viewModel.markSeen() }
        }
    }

    // MARK: - Shared Components

    private func categoryLabel(_ prompt: Prompt) -> some View {
        HStack(spacing: 6) {
            Image(systemName: prompt.category.iconName)
                .font(.caption2)
            Text(prompt.category.displayName)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(CircleTheme.warmAmber)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            CircleTheme.warmAmber.opacity(0.12),
            in: Capsule()
        )
    }

    private func depthIndicator(_ depth: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { level in
                SwiftUI.Circle()
                    .fill(level <= depth ? CircleTheme.warmAmber : CircleTheme.warmAmber.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Preview

#Preview("Compact") {
    DailyPromptView(
        viewModel: DailyPromptViewModel(
            promptService: MockPromptService(),
            circleId: UUID()
        ),
        isCompact: true,
        onRecordTapped: {}
    )
    .padding()
}

#Preview("Expanded") {
    DailyPromptView(
        viewModel: DailyPromptViewModel(
            promptService: MockPromptService(),
            circleId: UUID()
        ),
        isCompact: false,
        onRecordTapped: {}
    )
    .padding()
}
#endif
