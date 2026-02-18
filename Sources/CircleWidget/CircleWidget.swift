// CircleWidget.swift
// CircleWidget
// Copyright 2024 StudioNext

import SwiftUI
import WidgetKit

/// The Circle home screen widget displaying today's prompt and latest voice responses.
struct CircleWidget: Widget {
    let kind: String = "CircleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CircleWidgetProvider()) { entry in
            CircleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Circle")
        .description("See today's prompt and hear from your people.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

/// The widget bundle entry point for the Circle widget extension.
@main
struct CircleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CircleWidget()
    }
}
