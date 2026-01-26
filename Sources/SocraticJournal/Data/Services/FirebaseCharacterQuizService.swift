// FirebaseCharacterQuizService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseFunctions

/// Firebase-backed character quiz service
/// Calls the `analyzeCharacterMatch` Firebase Function to match users with fictional characters
/// Falls back to MockCharacterQuizService if Firebase is unavailable
public final class FirebaseCharacterQuizService: CharacterQuizServiceProtocol, @unchecked Sendable {
    /// Shared instance for Firebase character quiz operations
    public static let shared = FirebaseCharacterQuizService()

    private let functions: Functions
    private let localService: CharacterQuizServiceProtocol
    private let defaults: UserDefaults

    /// UserDefaults key for quiz history storage
    private let historyKey = "characterQuizHistory"

    /// Maximum number of results to keep in history
    private let maxHistoryCount = 20

    /// Timeout for character analysis (extended for complex AI analysis)
    private let analysisTimeout: TimeInterval = 60

    /// Minimum number of journal exchanges required for analysis
    public let minimumEntriesRequired: Int = 5

    private init(
        localService: CharacterQuizServiceProtocol = MockCharacterQuizService(),
        defaults: UserDefaults = .standard
    ) {
        self.functions = Functions.functions()
        self.localService = localService
        self.defaults = defaults

        #if DEBUG
        print("[FirebaseCharacterQuiz] Service initialized")
        #endif
    }

    // MARK: - CharacterQuizServiceProtocol

    public func analyzeCharacterMatch(
        entries: [Exchange],
        franchise: Franchise
    ) async throws -> CharacterQuizResult {
        // Check minimum entries requirement
        guard entries.count >= minimumEntriesRequired else {
            throw CharacterQuizError.insufficientEntries(
                required: minimumEntriesRequired,
                available: entries.count
            )
        }

        // Convert exchanges to the format expected by Firebase
        let journalEntries = entries.map { exchange in
            [
                "question": exchange.question,
                "answer": exchange.answer
            ]
        }

        let requestData: [String: Any] = [
            "entries": journalEntries,
            "franchise": franchise.rawValue
        ]

        do {
            #if DEBUG
            print("[FirebaseCharacterQuiz] Calling analyzeCharacterMatch")
            print("[FirebaseCharacterQuiz] Entries count: \(entries.count)")
            print("[FirebaseCharacterQuiz] Franchise: \(franchise.displayName)")
            print("[FirebaseCharacterQuiz] This may take up to 60 seconds...")
            #endif

            let callable = functions.httpsCallable("analyzeCharacterMatch")
            callable.timeoutInterval = analysisTimeout

            #if DEBUG
            let startTime = Date()
            #endif

            let result = try await callable.call(requestData)

            #if DEBUG
            let duration = Date().timeIntervalSince(startTime)
            print("[FirebaseCharacterQuiz] Call completed in \(String(format: "%.2f", duration))s")
            #endif

            let quizResult = try decodeCharacterQuizResult(
                from: result.data,
                franchise: franchise,
                entriesUsed: entries.count
            )

            #if DEBUG
            print("[FirebaseCharacterQuiz] Successfully decoded result")
            if let topMatch = quizResult.topMatch {
                print("[FirebaseCharacterQuiz] Top match: \(topMatch.character.name) (\(topMatch.confidencePercentage)%)")
            }
            #endif

            return quizResult

        } catch let error as CharacterQuizError {
            throw error
        } catch {
            #if DEBUG
            print("[FirebaseCharacterQuiz] Firebase call failed: \(error.localizedDescription)")
            print("[FirebaseCharacterQuiz] Falling back to local mock service")
            #endif

            // Map Firebase errors to domain errors
            let mappedError = mapFirebaseError(error)

            // For network/timeout errors, throw them directly
            // For other errors, fall back to mock service
            switch mappedError {
            case .networkError, .analysisTimeout:
                throw mappedError
            default:
                return try await localService.analyzeCharacterMatch(entries: entries, franchise: franchise)
            }
        }
    }

    public func generateSampleResult(for franchise: Franchise) async throws -> CharacterQuizResult {
        // Sample results are always generated locally
        // No need to call Firebase for preview data
        #if DEBUG
        print("[FirebaseCharacterQuiz] Generating sample result locally for \(franchise.displayName)")
        #endif

        return try await localService.generateSampleResult(for: franchise)
    }

    // MARK: - Quiz History

    public func saveQuizResult(_ result: CharacterQuizResult) async throws {
        var history = try await getQuizHistory()

        // Add new result at the beginning (newest first)
        history.insert(result, at: 0)

        // Limit history to maxHistoryCount results
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        // Persist to UserDefaults
        let data = try JSONEncoder().encode(history)
        defaults.set(data, forKey: historyKey)

        #if DEBUG
        print("[FirebaseCharacterQuiz] Saved quiz result. History count: \(history.count)")
        #endif
    }

    public func getQuizHistory() async throws -> [CharacterQuizResult] {
        guard let data = defaults.data(forKey: historyKey) else {
            return []
        }

        do {
            let history = try JSONDecoder().decode([CharacterQuizResult].self, from: data)
            // Ensure history is sorted by date (newest first)
            return history.sorted { $0.analyzedAt > $1.analyzedAt }
        } catch {
            #if DEBUG
            print("[FirebaseCharacterQuiz] Failed to decode quiz history: \(error)")
            #endif
            return []
        }
    }

    public func getLatestResult() async throws -> CharacterQuizResult? {
        let history = try await getQuizHistory()
        return history.first
    }

    public func getLatestResult(for franchise: Franchise) async throws -> CharacterQuizResult? {
        let history = try await getQuizHistory()
        return history.first { $0.franchise == franchise }
    }

    // MARK: - Private Helpers

    /// Decode the Firebase response into a CharacterQuizResult
    private func decodeCharacterQuizResult(
        from data: Any,
        franchise: Franchise,
        entriesUsed: Int
    ) throws -> CharacterQuizResult {
        guard let responseDict = data as? [String: Any] else {
            throw CharacterQuizError.invalidResponse
        }

        // Extract matches array from response
        guard let matchesArray = responseDict["matches"] as? [[String: Any]] else {
            throw CharacterQuizError.invalidResponse
        }

        // Decode each match
        var matches: [CharacterMatchEntry] = []
        let availableCharacters = FictionalCharacter.characters(for: franchise)

        for matchDict in matchesArray {
            guard let characterId = matchDict["characterId"] as? String,
                  let confidence = matchDict["confidence"] as? Int,
                  let explanation = matchDict["explanation"] as? String else {
                #if DEBUG
                print("[FirebaseCharacterQuiz] Skipping invalid match entry: \(matchDict)")
                #endif
                continue
            }

            // Find the character by ID
            guard let character = availableCharacters.first(where: { $0.id == characterId }) else {
                #if DEBUG
                print("[FirebaseCharacterQuiz] Character not found: \(characterId)")
                #endif
                continue
            }

            let matchEntry = CharacterMatchEntry(
                character: character,
                confidencePercentage: confidence,
                explanation: explanation
            )
            matches.append(matchEntry)
        }

        // Ensure we have at least one match
        guard !matches.isEmpty else {
            throw CharacterQuizError.invalidResponse
        }

        // Parse analyzedAt timestamp if provided
        let analyzedAt: Date
        if let timestampString = responseDict["analyzedAt"] as? String {
            let formatter = ISO8601DateFormatter()
            analyzedAt = formatter.date(from: timestampString) ?? Date()
        } else {
            analyzedAt = Date()
        }

        // Extract result ID if provided, otherwise generate one
        let resultId = responseDict["id"] as? String ?? UUID().uuidString

        return CharacterQuizResult(
            id: resultId,
            franchise: franchise,
            matches: matches,
            analyzedAt: analyzedAt,
            journalEntriesUsed: entriesUsed
        )
    }

    /// Map Firebase errors to CharacterQuizError
    private func mapFirebaseError(_ error: Error) -> CharacterQuizError {
        let nsError = error as NSError

        // Check for Firebase Functions specific error codes
        if nsError.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: nsError.code)

            switch code {
            case .cancelled, .deadlineExceeded:
                return .analysisTimeout
            case .unavailable, .notFound, .unimplemented:
                return .serviceUnavailable
            case .invalidArgument, .failedPrecondition:
                return .invalidResponse
            default:
                return .networkError(underlying: error)
            }
        }

        // Check for network errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                return .analysisTimeout
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .networkError(underlying: error)
            default:
                return .networkError(underlying: error)
            }
        }

        return .networkError(underlying: error)
    }
}
#endif
