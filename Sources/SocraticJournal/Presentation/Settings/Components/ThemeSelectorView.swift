// ThemeSelectorView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented control for theme selection
struct ThemeSelectorView: View {
    @Binding var selectedTheme: ThemeMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    ThemeOptionButton(
                        mode: mode,
                        isSelected: selectedTheme == mode,
                        action: { selectedTheme = mode }
                    )
                }
            }

            Text("Changes apply immediately")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Individual theme option button
private struct ThemeOptionButton: View {
    let mode: ThemeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.iconName)
                    .font(.title2)
                Text(mode.displayName)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ThemeSelectorView(selectedTheme: .constant(.system))
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
