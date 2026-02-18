// EmojiPickerView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A simple grid emoji picker for selecting circle icons.
/// Displays a curated set of emojis relevant to relationships and groups.
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String

    /// Curated emoji options for circle icons.
    private let emojis: [String] = [
        // People & relationships
        "heart", "heart.fill", "person.2.fill", "person.3.fill",
        "house.fill", "star.fill", "sun.max.fill", "moon.fill",
        // Activities
        "sportscourt.fill", "gamecontroller.fill", "music.note",
        "book.fill", "graduationcap.fill", "briefcase.fill",
        // Nature & travel
        "leaf.fill", "pawprint.fill", "airplane",
        "cup.and.saucer.fill", "fork.knife", "gift.fill",
        // Symbols
        "sparkles", "flame.fill", "bolt.fill", "hands.sparkles.fill"
    ]

    /// Emoji display names for SF Symbol to readable label mapping.
    private static let emojiDisplay: [String: String] = [
        "heart": "Heart",
        "heart.fill": "Heart",
        "person.2.fill": "Duo",
        "person.3.fill": "Group",
        "house.fill": "Home",
        "star.fill": "Star",
        "sun.max.fill": "Sun",
        "moon.fill": "Moon",
        "sportscourt.fill": "Sports",
        "gamecontroller.fill": "Gaming",
        "music.note": "Music",
        "book.fill": "Book",
        "graduationcap.fill": "School",
        "briefcase.fill": "Work",
        "leaf.fill": "Nature",
        "pawprint.fill": "Pets",
        "airplane": "Travel",
        "cup.and.saucer.fill": "Coffee",
        "fork.knife": "Food",
        "gift.fill": "Gift",
        "sparkles": "Sparkles",
        "flame.fill": "Fire",
        "bolt.fill": "Energy",
        "hands.sparkles.fill": "Magic"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose an Icon")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedEmoji == emoji
                                    ? CircleTheme.warmAmber.opacity(0.2)
                                    : Color(uiColor: .tertiarySystemFill))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedEmoji == emoji
                                                ? CircleTheme.warmAmber
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )

                            Image(systemName: emoji)
                                .font(.title3)
                                .foregroundStyle(
                                    selectedEmoji == emoji
                                        ? CircleTheme.warmAmber
                                        : .secondary
                                )
                        }
                        .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Self.emojiDisplay[emoji] ?? emoji)
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("heart.fill"))
        .padding()
}
#endif
