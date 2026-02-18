// InitialsAvatarView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reusable avatar view that displays user initials in a warm circle
/// or an image if avatar data is provided.
public struct InitialsAvatarView: View {
    let initials: String
    let avatarImageData: Data?
    let size: CGFloat

    /// Creates an initials avatar view.
    /// - Parameters:
    ///   - initials: The initials to display (e.g. "JD").
    ///   - avatarImageData: Optional image data to display instead of initials.
    ///   - size: The diameter of the avatar circle. Defaults to 60.
    public init(
        initials: String,
        avatarImageData: Data? = nil,
        size: CGFloat = 60
    ) {
        self.initials = initials
        self.avatarImageData = avatarImageData
        self.size = size
    }

    public var body: some View {
        Group {
            if let data = avatarImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    CircleTheme.warmAmber
                    Text(initials)
                        .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(SwiftUI.Circle())
    }
}

// MARK: - Convenience Init from User

extension InitialsAvatarView {
    /// Creates an avatar view from a User entity.
    /// - Parameters:
    ///   - user: The user whose avatar to display.
    ///   - size: The diameter of the avatar circle. Defaults to 60.
    public init(user: User, size: CGFloat = 60) {
        self.initials = user.initials
        self.avatarImageData = user.avatarImageData
        self.size = size
    }
}

#Preview("Initials") {
    InitialsAvatarView(initials: "JD", size: 80)
}

#Preview("Single Name") {
    InitialsAvatarView(initials: "J", size: 80)
}
#endif
