// ResponseCardView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A compact card showing a member's response status in the feed.
/// For members who have responded: shows avatar, name, waveform, and unheard indicator.
/// For members who have not responded: shows a greyed-out pending state.
struct ResponseCardView: View {
    let item: MemberResponseItem
    let playbackService: VoicePlaybackServiceProtocol
    var onHeard: (() -> Void)?

    var body: some View {
        if item.hasResponded {
            respondedCard
        } else {
            pendingCard
        }
    }

    // MARK: - Responded Card

    private var respondedCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Unheard indicator row
            HStack {
                if !item.isHeard && !item.member.isCurrentUser {
                    HStack(spacing: 4) {
                        SwiftUI.Circle()
                            .fill(CircleTheme.warmAmber)
                            .frame(width: 8, height: 8)

                        Text("New")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(CircleTheme.warmAmber)
                    }
                }

                Spacer()

                if let response = item.response {
                    Text(response.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 4)

            // Voice player with inline playback
            if let voiceNote = item.voiceNote {
                VoiceNotePlayerView(
                    viewModel: VoiceNotePlayerViewModel(
                        playbackService: playbackService,
                        voiceNote: voiceNote
                    ),
                    speakerName: item.member.displayName,
                    speakerInitials: item.member.initials,
                    avatarImageData: item.member.avatarImageData
                )
                .onAppear {
                    if !item.isHeard && !item.member.isCurrentUser {
                        onHeard?()
                    }
                }
            } else {
                // Response exists but VoiceNote not loaded yet -- show a simulated player
                simulatedPlayerCard
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    !item.isHeard && !item.member.isCurrentUser
                        ? CircleTheme.warmAmber.opacity(0.3)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    /// Simulated player card when VoiceNote data is not available for preview.
    /// Shows the member info with a placeholder waveform.
    private var simulatedPlayerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                InitialsAvatarView(
                    initials: item.member.initials,
                    avatarImageData: item.member.avatarImageData,
                    size: 32
                )

                Text(item.member.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CircleTheme.warmBrown)

                Spacer()

                if item.member.isCurrentUser {
                    Text("You")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CircleTheme.warmAmber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(CircleTheme.warmAmber.opacity(0.15), in: Capsule())
                }
            }

            // Placeholder waveform
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(CircleTheme.primaryGradient)
                    .clipShape(SwiftUI.Circle())

                WaveformView(
                    amplitudes: MockVoiceRecordingService.sampleWaveformData,
                    isLive: false,
                    barCount: 30,
                    barSpacing: 1.5
                )
                .frame(height: 32)
                .opacity(0.6)
            }
        }
        .padding(12)
    }

    // MARK: - Pending Card

    private var pendingCard: some View {
        HStack(spacing: 12) {
            InitialsAvatarView(
                initials: item.member.initials,
                avatarImageData: item.member.avatarImageData,
                size: 40
            )
            .opacity(0.5)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.member.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text("Hasn't responded yet")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "clock")
                .font(.body)
                .foregroundStyle(CircleTheme.waiting)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.6))
        )
    }
}

// MARK: - Previews

#Preview("Responded - Unheard") {
    let member = CircleMember(displayName: "Jordan Davis")
    let response = VoiceResponse(
        voiceNoteId: UUID(),
        promptId: UUID(),
        memberId: member.id,
        circleId: UUID(),
        isHeard: false
    )
    let voiceNote = VoiceNote(
        filePath: "VoiceNotes/mock/preview.m4a",
        duration: 14.5,
        waveformData: MockVoiceRecordingService.sampleWaveformData
    )
    let item = MemberResponseItem(
        id: member.id,
        member: member,
        response: response,
        voiceNote: voiceNote
    )

    ResponseCardView(
        item: item,
        playbackService: MockVoicePlaybackService()
    )
    .padding()
}

#Preview("Pending") {
    let member = CircleMember(displayName: "Alex Kim")
    let item = MemberResponseItem(
        id: member.id,
        member: member,
        response: nil,
        voiceNote: nil
    )

    ResponseCardView(
        item: item,
        playbackService: MockVoicePlaybackService()
    )
    .padding()
}
#endif
