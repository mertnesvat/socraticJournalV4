// ThemeSelectorView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented control for theme selection
struct ThemeSelectorView: View {
    @Binding var selectedTheme: ThemeMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appearance")
                .font(.headline)

            Picker("Theme", selection: $selectedTheme) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    HStack {
                        Image(systemName: mode.iconName)
                        Text(mode.displayName)
                    }
                    .tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text("Changes apply immediately")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ThemeSelectorView(selectedTheme: .constant(.system))
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
