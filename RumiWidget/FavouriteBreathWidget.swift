// FavouriteBreathWidget.swift
// RumiWidget
// Copyright 2024 StudioNext

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct FavouriteBreathEntry: TimelineEntry {
    let date: Date
    let pattern: WidgetBreathPattern?
}

// MARK: - Timeline Provider

struct FavouriteBreathProvider: TimelineProvider {
    private let settingsKey = "com.socraticjournal.settings"
    private let appGroupIdentifier = "group.com.StudioNext.socraticJournal"

    func placeholder(in context: Context) -> FavouriteBreathEntry {
        FavouriteBreathEntry(date: Date(), pattern: .resonance)
    }

    func getSnapshot(in context: Context, completion: @escaping (FavouriteBreathEntry) -> Void) {
        completion(FavouriteBreathEntry(date: Date(), pattern: loadFavouritePattern()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavouriteBreathEntry>) -> Void) {
        let pattern = loadFavouritePattern()
        let entry = FavouriteBreathEntry(date: Date(), pattern: pattern)
        // Refresh every 60 minutes — pattern preference rarely changes
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Private

    private func loadFavouritePattern() -> WidgetBreathPattern? {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        guard let data = defaults.data(forKey: settingsKey) else { return nil }
        // Decode only what we need — the favoritePatternId field
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let patternId = json["favoritePatternId"] as? String {
            return WidgetBreathPattern.find(id: patternId)
        }
        return nil
    }
}

// MARK: - Widget View

struct FavouriteBreathWidgetView: View {
    var entry: FavouriteBreathEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let pattern = entry.pattern {
            patternView(pattern: pattern)
        } else {
            placeholderView
        }
    }

    // MARK: - Pattern View

    private func patternView(pattern: WidgetBreathPattern) -> some View {
        ZStack {
            backgroundColor

            VStack(alignment: .leading, spacing: 0) {
                // App label
                Text("RUMI")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(accentColor(hex: pattern.tagColorHex).opacity(0.7))

                Spacer()

                // Pattern name
                Text(pattern.name)
                    .font(.system(size: family == .systemSmall ? 17 : 20, weight: .semibold, design: .serif))
                    .foregroundStyle(textPrimaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Timing
                Text(pattern.timing)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(textSecondaryColor)
                    .padding(.top, 2)

                if family == .systemMedium {
                    // Best-for (medium widget only)
                    Text(pattern.bestFor)
                        .font(.system(size: 10))
                        .foregroundStyle(textTertiaryColor)
                        .lineLimit(1)
                        .padding(.top, 3)
                }

                // Tag chip
                HStack(spacing: 4) {
                    Circle()
                        .fill(accentColor(hex: pattern.tagColorHex))
                        .frame(width: 5, height: 5)
                    Text(pattern.tag)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(accentColor(hex: pattern.tagColorHex))
                }
                .padding(.top, 5)

                Spacer()

                // Bottom CTA
                Text("Tap to breathe")
                    .font(.system(size: 9))
                    .foregroundStyle(textTertiaryColor)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    // MARK: - Placeholder View

    private var placeholderView: some View {
        ZStack {
            backgroundColor

            VStack(spacing: 8) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(textTertiaryColor)

                Text("Set a favourite in\nRumi Breathing")
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(textSecondaryColor)
            }
            .padding(12)
        }
    }

    // MARK: - Colours

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1C1710") : Color(hex: "FAF7F2")
    }

    private var textPrimaryColor: Color {
        colorScheme == .dark ? Color(hex: "FAF7F2") : Color(hex: "1C1710")
    }

    private var textSecondaryColor: Color {
        colorScheme == .dark ? Color(hex: "C8BFA8") : Color(hex: "6B5E4A")
    }

    private var textTertiaryColor: Color {
        colorScheme == .dark ? Color(hex: "8A7B68") : Color(hex: "9A8E7D")
    }

    private func accentColor(hex: String) -> Color {
        Color(hex: hex)
    }
}

// MARK: - Hex Color Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Widget Declaration

struct FavouriteBreathWidget: Widget {
    let kind = "FavouriteBreathWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavouriteBreathProvider()) { entry in
            FavouriteBreathWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
                .widgetURL(URL(string: entry.pattern.map { "rumi://breathe?patternId=\($0.id)" } ?? "rumi://breathe"))
        }
        .configurationDisplayName("Favourite Breath")
        .description("Quick-start your favourite breathing practice.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    FavouriteBreathWidget()
} timeline: {
    FavouriteBreathEntry(date: Date(), pattern: .resonance)
    FavouriteBreathEntry(date: Date(), pattern: nil)
}

#Preview(as: .systemMedium) {
    FavouriteBreathWidget()
} timeline: {
    FavouriteBreathEntry(date: Date(), pattern: .fourSevenEight)
}
