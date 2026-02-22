// InviteFriendsButton.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// Share sheet trigger for inviting friends to Socratic
public struct InviteFriendsButton: View {
    @State private var showingShareSheet: Bool = false

    static let inviteText = "Join me on Socratic! Record your take on today's question. 🎙️ https://socratic.app/invite"

    public var body: some View {
        Button {
            showingShareSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Invite Friends")
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .sheet(isPresented: $showingShareSheet) {
            InviteFriendsButton.InviteActivityView()
                .presentationDetents([.medium, .large])
        }
    }

    /// UIActivityViewController wrapper for the share sheet
    struct InviteActivityView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let items: [Any] = [InviteFriendsButton.inviteText]
            let controller = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            return controller
        }

        func updateUIViewController(
            _ uiViewController: UIActivityViewController,
            context: Context
        ) {}
    }
}

#Preview {
    VStack {
        Spacer()
        InviteFriendsButton()
            .padding()
    }
}
#endif
