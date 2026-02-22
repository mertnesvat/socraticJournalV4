// EmojiReactionBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact horizontal row of emoji reaction buttons shown below a playing friend answer card
public struct EmojiReactionBar: View {
    /// The currently selected emoji (nil if none)
    let selectedEmoji: String?

    /// Callback when an emoji is tapped
    let onSelect: (String) -> Void

    /// Available reaction emojis
    private let emojis: [String] = ["🔥", "😂", "😱", "💀", "❤️"]

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(emojis, id: \.self) { emoji in
                emojiButton(emoji)
            }
        }
    }

    private func emojiButton(_ emoji: String) -> some View {
        let isSelected = selectedEmoji == emoji

        return Button {
            onSelect(emoji)
        } label: {
            Text(emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5).opacity(0.5))
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview

#Preview("No Selection") {
    EmojiReactionBar(
        selectedEmoji: nil,
        onSelect: { _ in }
    )
    .padding()
    .background(Color.black)
}

#Preview("Selected") {
    EmojiReactionBar(
        selectedEmoji: "🔥",
        onSelect: { _ in }
    )
    .padding()
    .background(Color.black)
}

#endif
