// ThemeFilterView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scrollable filter for quote themes
public struct ThemeFilterView: View {
    @Binding var selectedTheme: QuoteTheme?
    let quoteCountByTheme: [QuoteTheme: Int]

    public init(selectedTheme: Binding<QuoteTheme?>, quoteCountByTheme: [QuoteTheme: Int]) {
        self._selectedTheme = selectedTheme
        self.quoteCountByTheme = quoteCountByTheme
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All themes button
                allThemesButton

                // Individual theme buttons
                ForEach(QuoteTheme.allCases, id: \.self) { theme in
                    themeButton(for: theme)
                }
            }
            .padding(.horizontal)
        }
    }

    private var allThemesButton: some View {
        Button {
            selectedTheme = nil
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.2x2")
                    .font(.caption)
                Text("All")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(selectedTheme == nil ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                selectedTheme == nil
                    ? AnyShapeStyle(Color.accentColor)
                    : AnyShapeStyle(Color(uiColor: .secondarySystemBackground))
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func themeButton(for theme: QuoteTheme) -> some View {
        let isSelected = selectedTheme == theme
        let count = quoteCountByTheme[theme] ?? 0

        return Button {
            selectedTheme = isSelected ? nil : theme
        } label: {
            HStack(spacing: 6) {
                Image(systemName: theme.iconName)
                    .font(.caption)
                Text(theme.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? AnyShapeStyle(themeColor(for: theme))
                    : AnyShapeStyle(Color(uiColor: .secondarySystemBackground))
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func themeColor(for theme: QuoteTheme) -> Color {
        switch theme {
        case .change:
            return .blue
        case .struggle:
            return .orange
        case .acceptance:
            return .green
        case .relationships:
            return .pink
        case .purpose:
            return .purple
        case .selfKnowledge:
            return .indigo
        case .time:
            return .cyan
        case .fear:
            return .red
        case .loss:
            return .gray
        case .gratitude:
            return .yellow
        case .creativity:
            return .mint
        case .universal:
            return .secondary
        }
    }
}

#Preview {
    VStack {
        ThemeFilterView(
            selectedTheme: .constant(nil),
            quoteCountByTheme: [
                .change: 5,
                .struggle: 4,
                .acceptance: 4,
                .relationships: 4,
                .purpose: 4,
                .selfKnowledge: 5,
                .time: 4,
                .fear: 4,
                .loss: 4,
                .gratitude: 4,
                .creativity: 4,
                .universal: 5
            ]
        )

        Divider()
            .padding(.vertical)

        ThemeFilterView(
            selectedTheme: .constant(.selfKnowledge),
            quoteCountByTheme: [
                .change: 5,
                .selfKnowledge: 5
            ]
        )
    }
    .padding(.vertical)
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
