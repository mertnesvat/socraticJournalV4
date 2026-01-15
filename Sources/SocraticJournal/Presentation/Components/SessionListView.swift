// SessionListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a list of journal sessions
public struct SessionListView: View {
    let sessions: [JournalSession]
    let onDelete: (JournalSession) -> Void
    let onSelect: (JournalSession) -> Void

    public init(
        sessions: [JournalSession],
        onDelete: @escaping (JournalSession) -> Void,
        onSelect: @escaping (JournalSession) -> Void
    ) {
        self.sessions = sessions
        self.onDelete = onDelete
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if sessions.isEmpty {
                EmptySessionsView()
            } else {
                ForEach(sessions.prefix(5)) { session in
                    SessionRowView(session: session)
                        .onTapGesture {
                            onSelect(session)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

struct SessionRowView: View {
    let session: JournalSession

    var body: some View {
        HStack(spacing: 12) {
            // Clarity score indicator
            ZStack {
                Circle()
                    .fill(scoreColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                if let score = session.clarityScore {
                    Text("\(score.total)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(scoreColor)
                } else {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(session.formattedDate, systemImage: "clock")

                    if session.isComplete {
                        Label(session.estimatedDuration, systemImage: "timer")
                    } else {
                        Label("In Progress", systemImage: "pencil")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        .padding(.horizontal)
    }

    private var scoreColor: Color {
        guard let score = session.clarityScore else {
            return .gray
        }
        switch score.quality {
        case .quick: return .orange
        case .moderate: return .blue
        case .high: return .green
        }
    }
}

struct EmptySessionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No sessions yet")
                .font(.headline)

            Text("Start your first Socratic dialogue\nand begin your journey of self-discovery.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

#Preview {
    ScrollView {
        SessionListView(
            sessions: [
                JournalSession(
                    exchanges: [
                        Exchange(
                            question: "What's on your mind?",
                            answer: "I've been thinking about my career direction and whether I'm making the right choices for my future."
                        )
                    ],
                    clarityScore: ClarityScore(
                        total: 75,
                        completion: 100,
                        depth: 70,
                        emotional: 60,
                        label: "Deep Dive",
                        message: "A thoughtful session."
                    ),
                    isComplete: true
                ),
                JournalSession(
                    exchanges: [
                        Exchange(
                            question: "What brought you here?",
                            answer: "Just reflecting on the day."
                        )
                    ],
                    clarityScore: ClarityScore(
                        total: 50,
                        completion: 100,
                        depth: 40,
                        emotional: 35,
                        label: "Thoughtful Reflection",
                        message: "A good moment."
                    ),
                    isComplete: true
                )
            ],
            onDelete: { _ in },
            onSelect: { _ in }
        )
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
