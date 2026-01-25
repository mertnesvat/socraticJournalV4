// OfflineSyncHandler.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Handles updating journal sessions when offline-queued AI enhancements are synced
/// Listens for sync completions and updates the relevant sessions with enhanced content
public final class OfflineSyncHandler: @unchecked Sendable {
    /// Shared instance
    public static let shared = OfflineSyncHandler()

    /// Repository for updating sessions
    private var repository: JournalRepositoryProtocol?

    /// Callback to notify UI when sessions are enhanced
    public var onSessionEnhanced: ((String) -> Void)?

    private init() {}

    /// Configure the handler with a repository
    /// Should be called at app launch after repository is available
    public func configure(repository: JournalRepositoryProtocol) {
        self.repository = repository

        // Set up the sync callback
        OfflineSyncQueue.shared.onEnhancementSynced = { [weak self] result in
            Task {
                await self?.handleSyncedEnhancement(result)
            }
        }

        #if DEBUG
        print("[OfflineSyncHandler] Configured and listening for sync events")
        #endif
    }

    /// Handle a synced enhancement by updating the relevant session
    @MainActor
    private func handleSyncedEnhancement(_ result: SyncResult) async {
        guard let repository = repository else {
            #if DEBUG
            print("[OfflineSyncHandler] No repository configured, skipping enhancement update")
            #endif
            return
        }

        do {
            // Fetch the session
            guard var session = try await repository.getSession(id: result.sessionId) else {
                #if DEBUG
                print("[OfflineSyncHandler] Session not found: \(result.sessionId)")
                #endif
                return
            }

            // Find and update the exchange
            var updated = false
            var updatedExchanges = session.exchanges

            for (index, exchange) in updatedExchanges.enumerated() {
                if exchange.id == result.exchangeId {
                    var updatedExchange = exchange

                    switch result.type {
                    case .clarityMirror:
                        updatedExchange.clarityMirror = result.result
                        updated = true
                        #if DEBUG
                        print("[OfflineSyncHandler] Updated clarity mirror for exchange \(result.exchangeId)")
                        #endif

                    case .socratesReaction:
                        updatedExchange.socratesReaction = result.result
                        updated = true
                        #if DEBUG
                        print("[OfflineSyncHandler] Updated Socrates reaction for exchange \(result.exchangeId)")
                        #endif

                    case .followUpQuestion:
                        // Follow-up questions are typically for the next question, not stored in exchange
                        #if DEBUG
                        print("[OfflineSyncHandler] Follow-up question synced (not stored in exchange)")
                        #endif

                    case .insightCard:
                        updatedExchange.insightCard = result.result
                        updated = true
                        #if DEBUG
                        print("[OfflineSyncHandler] Updated insight card for exchange \(result.exchangeId)")
                        #endif
                    }

                    updatedExchanges[index] = updatedExchange
                    break
                }
            }

            // Save the updated session
            if updated {
                let updatedSession = JournalSession(
                    id: session.id,
                    createdAt: session.createdAt,
                    exchanges: updatedExchanges,
                    clarityScore: session.clarityScore,
                    wisdomQuote: session.wisdomQuote,
                    isComplete: session.isComplete
                )

                try await repository.saveSession(updatedSession)

                #if DEBUG
                print("[OfflineSyncHandler] Saved updated session \(result.sessionId)")
                #endif

                // Notify UI
                onSessionEnhanced?(result.sessionId)
            }

        } catch {
            #if DEBUG
            print("[OfflineSyncHandler] Failed to update session: \(error.localizedDescription)")
            #endif
        }
    }
}
#endif
