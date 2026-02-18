// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root view for the Circle app — routes to circle list or placeholder
struct CircleRootView: View {
    let circleRepository: CircleRepositoryProtocol
    let authService: AuthServiceProtocol
    let currentUserId: String

    var body: some View {
        NavigationStack {
            CircleListView(
                viewModel: CircleListViewModel(
                    circleRepository: circleRepository,
                    authService: authService,
                    currentUserId: currentUserId
                )
            )
        }
    }
}
#endif
