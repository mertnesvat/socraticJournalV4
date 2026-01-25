// FirebasePersonalityAnalysisService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Firebase-backed personality analysis service with local fallback
/// Calls the `analyzePersonality` Firebase Function to generate Big Five profiles
/// Falls back to MockPersonalityAnalysisService if Firebase is unavailable
public final class FirebasePersonalityAnalysisService: PersonalityAnalysisServiceProtocol, @unchecked Sendable {
    /// Shared instance for Firebase personality analysis operations
    public static let shared = FirebasePersonalityAnalysisService()

    private let firebaseFunctionsService: FirebaseFunctionsServiceProtocol
    private let localService: PersonalityAnalysisServiceProtocol

    /// Minimum number of journal exchanges required for analysis
    private let minimumExchangesRequired = 5

    private init(
        firebaseFunctionsService: FirebaseFunctionsServiceProtocol = FirebaseFunctionsService.shared,
        localService: PersonalityAnalysisServiceProtocol = MockPersonalityAnalysisService()
    ) {
        self.firebaseFunctionsService = firebaseFunctionsService
        self.localService = localService
    }

    // MARK: - PersonalityAnalysisServiceProtocol

    public func analyzePersonality(from sessions: [JournalSession]) async throws -> BigFiveProfile {
        // Extract all exchanges from completed sessions
        let allExchanges = sessions.flatMap { $0.exchanges }

        // Check minimum entries requirement
        guard allExchanges.count >= minimumExchangesRequired else {
            throw PersonalityAnalysisError.insufficientData(
                required: minimumExchangesRequired,
                available: allExchanges.count
            )
        }

        // Convert sessions to JournalEntryData for the Firebase API
        let journalEntries = allExchanges.map { exchange in
            JournalEntryData(
                question: exchange.question,
                answer: exchange.answer,
                clarityMirror: exchange.clarityMirror
            )
        }

        let request = PersonalityAnalysisRequest(journalEntries: journalEntries)

        do {
            #if DEBUG
            print("[FirebasePersonalityAnalysis] Calling Firebase with \(journalEntries.count) journal entries")
            print("[FirebasePersonalityAnalysis] This may take up to 60 seconds...")
            #endif

            let profile = try await firebaseFunctionsService.analyzePersonality(request: request)

            #if DEBUG
            print("[FirebasePersonalityAnalysis] Successfully received personality profile")
            print("[FirebasePersonalityAnalysis] Summary: \(profile.summary.prefix(100))...")
            #endif

            return profile
        } catch {
            #if DEBUG
            print("[FirebasePersonalityAnalysis] Firebase call failed: \(error.localizedDescription)")
            print("[FirebasePersonalityAnalysis] Falling back to local mock service")
            #endif

            // Fall back to local mock service for offline/error cases
            return try await localService.analyzePersonality(from: sessions)
        }
    }

    public func generateSampleProfile() async throws -> BigFiveProfile {
        // Sample profiles are always generated locally
        // No need to call Firebase for preview data
        #if DEBUG
        print("[FirebasePersonalityAnalysis] Generating sample profile locally")
        #endif

        return try await localService.generateSampleProfile()
    }
}
#endif
