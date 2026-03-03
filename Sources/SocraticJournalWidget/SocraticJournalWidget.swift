// SocraticJournalWidget.swift
// SocraticJournalWidget
// Copyright 2024 StudioNext

import WidgetKit
import SwiftUI

// MARK: - Shared Data Types (duplicated for widget target)

/// App Group identifier
private enum WidgetAppGroup {
    static let group = "group.com.StudioNext.socraticJournal"
    static let streakKey = "com.socraticjournal.streak.shared"
}

/// Streak data readable by the widget
private struct WidgetStreakData: Codable {
    let currentStreak: Int
    let lastSessionDate: Date?
    let isAtRisk: Bool
    let totalMinutes: Int
    let lastUpdated: Date
}

// MARK: - Timeline Entry

struct BreathWidgetEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let isAtRisk: Bool
    let totalMinutes: Int
}

// MARK: - Timeline Provider

struct BreathWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BreathWidgetEntry {
        BreathWidgetEntry(date: Date(), currentStreak: 7, isAtRisk: false, totalMinutes: 120)
    }

    func getSnapshot(in context: Context, completion: @escaping (BreathWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BreathWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 30 minutes or when the app reloads timelines
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> BreathWidgetEntry {
        guard let defaults = UserDefaults(suiteName: WidgetAppGroup.group),
              let data = defaults.data(forKey: WidgetAppGroup.streakKey),
              let decoded = try? JSONDecoder().decode(WidgetStreakData.self, from: data) else {
            return BreathWidgetEntry(date: Date(), currentStreak: 0, isAtRisk: false, totalMinutes: 0)
        }
        return BreathWidgetEntry(
            date: Date(),
            currentStreak: decoded.currentStreak,
            isAtRisk: decoded.isAtRisk,
            totalMinutes: decoded.totalMinutes
        )
    }
}

// MARK: - Widget Colors (standalone for widget target)

private enum WidgetColors {
    static let background = Color(red: 10/255, green: 22/255, blue: 40/255)
    static let accent = Color(red: 100/255, green: 255/255, blue: 218/255)
    static let warning = Color(red: 255/255, green: 159/255, blue: 10/255)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 136/255, green: 146/255, blue: 176/255)
    static let surface = Color(red: 17/255, green: 34/255, blue: 64/255)
}

// MARK: - Home Screen Widget View (Small)

struct HomeScreenWidgetView: View {
    let entry: BreathWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            // Streak ring
            ZStack {
                Circle()
                    .stroke(WidgetColors.surface, lineWidth: 6)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: min(Double(entry.currentStreak) / 7.0, 1.0))
                    .stroke(
                        entry.isAtRisk ? WidgetColors.warning : WidgetColors.accent,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Text("\(entry.currentStreak)")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundStyle(WidgetColors.textPrimary)
            }

            // Label
            Text(entry.currentStreak == 1 ? "day streak" : "day streak")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WidgetColors.textSecondary)

            // CTA
            Text("Breathe")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WidgetColors.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(WidgetColors.background, for: .widget)
    }
}

// MARK: - Lock Screen Widget View (Accessory Circular)

struct LockScreenCircularView: View {
    let entry: BreathWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: "wind")
                    .font(.system(size: 12))

                Text("\(entry.currentStreak)")
                    .font(.system(size: 18, weight: .bold))
            }
        }
    }
}

// MARK: - Lock Screen Widget View (Accessory Rectangular)

struct LockScreenRectangularView: View {
    let entry: BreathWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wind")
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.currentStreak) day streak")
                    .font(.system(size: 14, weight: .semibold))

                Text("\(entry.totalMinutes) total min")
                    .font(.system(size: 12))
                    .opacity(0.7)
            }
        }
    }
}

// MARK: - Widget Definitions

struct BreathHomeWidget: Widget {
    let kind: String = "BreathHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BreathWidgetProvider()) { entry in
            HomeScreenWidgetView(entry: entry)
                .widgetURL(URL(string: "breathe://start"))
        }
        .configurationDisplayName("Breath Streak")
        .description("See your current streak and tap to start breathing.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Lock Screen Adaptive View

struct LockScreenAdaptiveView: View {
    let entry: BreathWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        default:
            LockScreenCircularView(entry: entry)
        }
    }
}

struct BreathLockScreenWidget: Widget {
    let kind: String = "BreathLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BreathWidgetProvider()) { entry in
            LockScreenAdaptiveView(entry: entry)
        }
        .configurationDisplayName("Breath Streak")
        .description("Your streak at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Widget Bundle

@main
struct SocraticJournalWidgetBundle: WidgetBundle {
    var body: some Widget {
        BreathHomeWidget()
        BreathLockScreenWidget()
    }
}
