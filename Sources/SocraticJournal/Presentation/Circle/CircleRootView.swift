// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root view for the Circle app — placeholder until feed is built
struct CircleRootView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)

                Text("Circle")
                    .font(.largeTitle.bold())

                Text("Hear the voices of people who matter")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    CircleRootView()
}
#endif
