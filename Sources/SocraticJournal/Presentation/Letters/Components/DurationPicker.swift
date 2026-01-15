// DurationPicker.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented control for selecting letter delivery duration
public struct DurationPicker: View {
    @Binding var selection: LetterDuration

    public init(selection: Binding<LetterDuration>) {
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(LetterDuration.allCases) { duration in
                durationButton(duration)
            }
        }
    }

    private func durationButton(_ duration: LetterDuration) -> some View {
        let isSelected = selection == duration

        return Button {
            selection = duration
        } label: {
            VStack(spacing: 4) {
                Text(duration.shortLabel)
                    .font(.headline)

                Text(durationSubtitle(duration))
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor : Color(uiColor: .tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func durationSubtitle(_ duration: LetterDuration) -> String {
        switch duration {
        case .oneWeek: return "Week"
        case .oneMonth: return "Month"
        case .threeMonths: return "Months"
        case .oneYear: return "Year"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selection: LetterDuration = .oneMonth

        var body: some View {
            VStack(spacing: 20) {
                DurationPicker(selection: $selection)
                    .padding()

                Text("Selected: \(selection.rawValue)")
                    .foregroundStyle(.secondary)

                Text("Delivery: \(selection.deliveryDate().formatted(date: .long, time: .omitted))")
                    .foregroundStyle(.secondary)
            }
        }
    }

    return PreviewWrapper()
}
#endif
