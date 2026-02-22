// ShareCardSheet.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Sheet for selecting a card variant and sharing a rendered opinion card
public struct ShareCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShareCardViewModel
    @State private var showShareSheet: Bool = false

    public init(viewModel: ShareCardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Card preview
                    cardPreview
                        .padding(.top, 16)

                    // Variant selector
                    variantSelector

                    // Share button
                    shareButton
                        .padding(.horizontal, 24)

                    Spacer(minLength: 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share Your Take")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = viewModel.generatedImage {
                    ShareCardActivitySheet(
                        activityItems: [
                            image,
                            "Check out this question on Socratic https://socratic.app" as String
                        ]
                    )
                }
            }
        }
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        ShareCardView(
            variant: viewModel.selectedVariant,
            questionText: viewModel.questionText,
            userName: viewModel.userName,
            friendName: viewModel.friendName,
            category: viewModel.category
        )
        .frame(width: 1080, height: 1920)
        .scaleEffect(300.0 / 1080.0)
        .frame(width: 300, height: 300.0 / 1080.0 * 1920.0)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
    }

    // MARK: - Variant Selector

    private var variantSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ShareCardVariant.allCases) { variant in
                    variantThumbnail(variant)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func variantThumbnail(_ variant: ShareCardVariant) -> some View {
        let isSelected = viewModel.selectedVariant == variant

        return Button {
            viewModel.selectedVariant = variant
        } label: {
            VStack(spacing: 8) {
                // Mini card preview
                ZStack {
                    LinearGradient(
                        colors: variant.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.4))
                            .frame(width: 40, height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.3))
                            .frame(width: 30, height: 4)
                    }
                }
                .frame(width: 64, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: 2.5
                        )
                )

                // Variant label
                Text(variant.displayLabel)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            viewModel.generateCard()
            showShareSheet = true
        } label: {
            HStack(spacing: 8) {
                if viewModel.isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(viewModel.isGenerating ? "Generating..." : "Share")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor)
            )
        }
        .disabled(viewModel.isGenerating)
    }
}

// MARK: - Share Card Activity Sheet

/// UIKit wrapper for presenting the system share sheet with card image
struct ShareCardActivitySheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    ShareCardSheet(
        viewModel: ShareCardViewModel(
            questionText: "Is social media making us more or less connected?",
            userName: "Alex",
            friendName: "Jordan",
            category: .debateTrigger
        )
    )
}
#endif
