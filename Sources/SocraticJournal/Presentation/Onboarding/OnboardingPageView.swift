// OnboardingPageView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reusable page template for onboarding screens.
/// Provides a consistent layout with bold headline, muted subtitle, and centered content area.
public struct OnboardingPageView<Content: View>: View {
    // MARK: - Properties

    let title: String
    let subtitle: String
    let content: () -> Content

    // MARK: - Init

    public init(
        title: String,
        subtitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Content area (illustrations, animations)
            content()
                .frame(height: 240)
                .padding(.bottom, 40)

            // Title
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPageView(
            title: "Sample Title",
            subtitle: "This is a sample subtitle for the onboarding page."
        ) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.purple.opacity(0.3))
                .frame(height: 200)
                .padding(.horizontal, 40)
        }
    }
}
#endif
