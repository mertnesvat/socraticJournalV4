// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main entry point for the Socratic Journal app
/// Note: @main is used only when building the iOS app directly
public struct SocraticJournalApp: App {
    @State private var repository: JournalRepositoryProtocol = InMemoryJournalRepository()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(repository: repository))
        }
    }
}
#endif
