// BOLTTestView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Container view for the BOLT test flow with NavigationStack
public struct BOLTTestView: View {
    @State private var path = NavigationPath()
    let sessionRepository: BreathSessionRepositoryProtocol
    let latestScore: BOLTScore?
    let onDismiss: () -> Void

    @Environment(ThemeManager.self) private var themeManager

    public var body: some View {
        NavigationStack(path: $path) {
            BOLTInstructionsPage(
                onStartTest: { path.append(BOLTPage.timer) }
            )
            .navigationDestination(for: BOLTPage.self) { page in
                switch page {
                case .timer:
                    BOLTTimerPage(
                        onComplete: { score in
                            path.append(BOLTPage.result(score))
                        }
                    )
                case .result(let score):
                    BOLTResultPage(
                        score: score,
                        previousScore: latestScore,
                        sessionRepository: sessionRepository,
                        onSave: onDismiss,
                        onRetake: {
                            path.removeLast(path.count)
                            path.append(BOLTPage.timer)
                        }
                    )
                }
            }
        }
        .applyTheme(from: themeManager)
    }

    enum BOLTPage: Hashable {
        case timer
        case result(TimeInterval)
    }
}
#endif
