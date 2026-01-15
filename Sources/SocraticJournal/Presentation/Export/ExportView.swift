// ExportView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View for exporting journal data
public struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExportViewModel
    @State private var showingShareSheet: Bool = false

    public init(viewModel: ExportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Export Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { await viewModel.loadPreview() }
                .sheet(isPresented: $showingShareSheet, onDismiss: {
                    viewModel.resetState()
                }) {
                    if let url = viewModel.exportURL {
                        ExportShareSheet(activityItems: [url])
                    }
                }
                .onChange(of: viewModel.exportURL) { _, newURL in
                    if newURL != nil {
                        showingShareSheet = true
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                exportHeaderView

                // Preview Section
                if viewModel.isLoadingPreview {
                    ProgressView("Loading preview...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if let data = viewModel.exportData {
                    exportPreviewSection(data: data)
                }

                // Export Button
                exportButtonSection

                // Error Display
                if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var exportHeaderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Export Your Journal")
                .font(.title2.weight(.semibold))

            Text("Create a backup of all your sessions, letters, and settings in JSON format.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    private func exportPreviewSection(data: JournalExport) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Preview")
                .font(.headline)

            VStack(spacing: 12) {
                previewRow(
                    icon: "bubble.left.and.bubble.right",
                    title: "Journal Sessions",
                    value: "\(data.summary.sessionCount)",
                    detail: "\(data.summary.completedSessions) completed"
                )

                Divider()

                previewRow(
                    icon: "envelope",
                    title: "Future Letters",
                    value: "\(data.summary.letterCount)",
                    detail: nil
                )

                Divider()

                previewRow(
                    icon: "text.quote",
                    title: "Total Exchanges",
                    value: "\(data.summary.totalExchanges)",
                    detail: nil
                )

                Divider()

                previewRow(
                    icon: "gearshape",
                    title: "Settings",
                    value: "Included",
                    detail: nil
                )
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Version info
            HStack {
                Text("Version: \(data.version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private func previewRow(icon: String, title: String, value: String, detail: String?) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var exportButtonSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.exportData()
                }
            } label: {
                HStack {
                    if viewModel.isExporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text(viewModel.isExporting ? "Exporting..." : "Export to JSON")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isExporting ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isExporting)

            Text("The export file will be saved to your device and you can share it via AirDrop, email, or save to Files.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("Export Failed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.clearError()
            }
            .font(.subheadline.weight(.medium))
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") {
                dismiss()
            }
        }
    }
}

/// Share sheet wrapper for export
struct ExportShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView(
        viewModel: ExportViewModel(
            exportService: JSONDataExportService(
                journalRepository: InMemoryJournalRepository(),
                settingsRepository: UserDefaultsSettingsRepository()
            )
        )
    )
}
#endif
