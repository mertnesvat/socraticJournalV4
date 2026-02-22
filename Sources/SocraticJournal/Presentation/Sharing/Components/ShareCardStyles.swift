// ShareCardStyles.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Available visual styles for share cards.
/// Each style provides a distinct gradient background for the shareable card image.
public enum ShareCardStyle: String, CaseIterable, Identifiable, Sendable {
    case electricBlue
    case hotCoral
    case midnightPurple

    public var id: String { rawValue }

    /// Display name for the style picker
    public var name: String {
        switch self {
        case .electricBlue: return "Electric Blue"
        case .hotCoral: return "Hot Coral"
        case .midnightPurple: return "Midnight Purple"
        }
    }

    /// The gradient used as the card background
    public var gradient: LinearGradient {
        switch self {
        case .electricBlue:
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.25),
                    Color(red: 0.10, green: 0.30, blue: 0.85),
                    Color(red: 0.20, green: 0.55, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hotCoral:
            return LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.20, blue: 0.25),
                    Color(red: 0.95, green: 0.45, blue: 0.25),
                    Color(red: 1.0, green: 0.60, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .midnightPurple:
            return LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.05, blue: 0.25),
                    Color(red: 0.45, green: 0.10, blue: 0.55),
                    Color(red: 0.85, green: 0.25, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// A subtle secondary color for accents within the card
    public var accentColor: Color {
        switch self {
        case .electricBlue: return Color(red: 0.40, green: 0.70, blue: 1.0)
        case .hotCoral: return Color(red: 1.0, green: 0.75, blue: 0.50)
        case .midnightPurple: return Color(red: 0.90, green: 0.50, blue: 0.70)
        }
    }
}

#Preview("All Styles") {
    VStack(spacing: 16) {
        ForEach(ShareCardStyle.allCases) { style in
            RoundedRectangle(cornerRadius: 16)
                .fill(style.gradient)
                .frame(height: 80)
                .overlay(
                    Text(style.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                )
        }
    }
    .padding()
    .background(Color.black)
}
#endif
