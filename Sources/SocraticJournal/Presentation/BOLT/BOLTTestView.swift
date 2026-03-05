// BOLTTestView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Container view for the BOLT test flow with NavigationStack
public struct BOLTTestView: View {
    @State private var path = NavigationPath()
    @State private var testScore: TimeInterval?
    let sessionRepository: BreathSessionRepositoryProtocol
    let latestScore: BOLTScore?
    let onDismiss: () -> Void

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
                            testScore = score
                            path.append(BOLTPage.result)
                        }
                    )
                case .result:
                    if let score = testScore {
                        BOLTResultPage(
                            score: score,
                            previousScore: latestScore,
                            sessionRepository: sessionRepository,
                            onSave: onDismiss,
                            onRetake: {
                                testScore = nil
                                path.removeLast(path.count)
                                path.append(BOLTPage.timer)
                            }
                        )
                    }
                }
            }
        }
    }

    enum BOLTPage: Hashable {
        case timer, result
    }
}
#endif
