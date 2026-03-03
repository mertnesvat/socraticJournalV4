// WidgetCenterHelper.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import WidgetKit

/// Helper to reload widget timelines after session data changes
public enum WidgetCenterHelper {
    /// Reload all widget timelines
    public static func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
#endif
