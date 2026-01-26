// FirebaseCharacterQuizService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseFunctions

/// Firebase-backed character quiz service with local fallback
/// Calls the `matchFictionalCharacter` Firebase Function to match personality to characters
/// Falls back to MockCharacterQuizService if Firebase is unavailable
public final class FirebaseCharacterQuizService: CharacterQuizServiceProtocol, @unchecked Sendable {
    /// Shared instance for Firebase character quiz operations
    public static let shared = FirebaseCharacterQuizService()

    /// The Firebase Functions instance
    private let functions: Functions

    /// Local mock service for fallback and sample generation
    private let localService: CharacterQuizServiceProtocol

    /// Timeout for character matching (45 seconds - analysis may take time)
    private let characterMatchTimeout: TimeInterval = 45

    /// Minimum number of journal entries required for analysis
    private let minimumEntriesRequired = 3

    private init(
        localService: CharacterQuizServiceProtocol = MockCharacterQuizService()
    ) {
        self.functions = Functions.functions()
        self.localService = localService
        #if DEBUG
        // Use Firebase emulator for local development
        // Run `cd Firebase && npx firebase emulators:start --only functions` to start the emulator
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
        print("[FirebaseCharacterQuiz] Service initialized with EMULATOR at 127.0.0.1:5001")
        #endif
    }

    // MARK: - CharacterQuizServiceProtocol

    public func matchCharacters(request: CharacterMatchRequest) async throws -> CharacterMatchResult {
        // Validate minimum entries
        guard request.journalEntries.count >= minimumEntriesRequired else {
            throw CharacterQuizError.insufficientData(
                required: minimumEntriesRequired,
                available: request.journalEntries.count
            )
        }

        // Validate universe
        guard FictionalUniverse.allUniverses.contains(where: { $0.id == request.universeId }) else {
            throw CharacterQuizError.invalidUniverse(request.universeId)
        }

        #if DEBUG
        print("[FirebaseCharacterQuiz] Calling matchFictionalCharacter")
        print("[FirebaseCharacterQuiz] Universe: \(request.universeId)")
        print("[FirebaseCharacterQuiz] Journal entries: \(request.journalEntries.count)")
        print("[FirebaseCharacterQuiz] Timeout: \(characterMatchTimeout)s")
        #endif

        do {
            let requestData = try encodeRequest(request)
            let result = try await callFunction(
                name: "matchFictionalCharacter",
                data: requestData,
                timeout: characterMatchTimeout
            )

            let matchResult = try decodeMatchResult(from: result)

            #if DEBUG
            print("[FirebaseCharacterQuiz] Successfully received \(matchResult.matches.count) character matches")
            if let topMatch = matchResult.topMatch {
                print("[FirebaseCharacterQuiz] Top match: \(topMatch.characterName) (\(topMatch.confidencePercentage))")
            }
            #endif

            return matchResult
        } catch let error as CharacterQuizError {
            throw error
        } catch {
            #if DEBUG
            print("[FirebaseCharacterQuiz] Firebase call failed: \(error.localizedDescription)")
            print("[FirebaseCharacterQuiz] Falling back to local mock service")
            #endif

            // Fall back to local mock service for offline/error cases
            return try await localService.matchCharacters(request: request)
        }
    }

    public func generateSampleMatch(for universeId: String) async throws -> CharacterMatchResult {
        // Sample matches are always generated locally
        // No need to call Firebase for preview data
        #if DEBUG
        print("[FirebaseCharacterQuiz] Generating sample match locally for universe: \(universeId)")
        #endif

        return try await localService.generateSampleMatch(for: universeId)
    }

    // MARK: - Private Helpers

    /// Encode a Codable request to a dictionary for Firebase Functions
    private func encodeRequest<T: Encodable>(_ request: T) throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CharacterQuizError.invalidResponse
        }

        return dict
    }

    /// Call a Firebase Function with the given name and data
    private func callFunction(
        name: String,
        data: [String: Any],
        timeout: TimeInterval
    ) async throws -> Any {
        let callable = functions.httpsCallable(name)
        callable.timeoutInterval = timeout

        #if DEBUG
        let startTime = Date()
        print("[FirebaseCharacterQuiz] Starting call to '\(name)' with timeout: \(timeout)s")
        #endif

        do {
            let result = try await callable.call(data)

            #if DEBUG
            let duration = Date().timeIntervalSince(startTime)
            print("[FirebaseCharacterQuiz] '\(name)' completed in \(String(format: "%.2f", duration))s")
            #endif

            return result.data
        } catch {
            #if DEBUG
            print("[FirebaseCharacterQuiz] '\(name)' failed: \(error.localizedDescription)")
            #endif

            throw mapFirebaseError(error)
        }
    }

    /// Map Firebase Functions errors to CharacterQuizError
    private func mapFirebaseError(_ error: Error) -> CharacterQuizError {
        let nsError = error as NSError

        // Check for Firebase Functions specific error codes
        if nsError.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: nsError.code)

            switch code {
            case .cancelled, .deadlineExceeded:
                return .timeout
            case .invalidArgument:
                return .invalidResponse
            case .notFound, .unavailable, .unimplemented:
                return .serviceUnavailable
            default:
                return .unknown(nsError.localizedDescription)
            }
        }

        // Check for network errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                return .timeout
            default:
                return .serviceUnavailable
            }
        }

        return .unknown(error.localizedDescription)
    }

    /// Decode a CharacterMatchResult from the Firebase response
    private func decodeMatchResult(from data: Any) throws -> CharacterMatchResult {
        guard let responseDict = data as? [String: Any] else {
            throw CharacterQuizError.invalidResponse
        }

        // Parse matches array
        guard let matchesArray = responseDict["matches"] as? [[String: Any]] else {
            throw CharacterQuizError.invalidResponse
        }

        let matches: [CharacterMatch] = try matchesArray.map { matchDict in
            guard
                let characterId = matchDict["characterId"] as? String,
                let characterName = matchDict["characterName"] as? String,
                let confidence = matchDict["confidence"] as? Double,
                let reasoning = matchDict["reasoning"] as? String
            else {
                throw CharacterQuizError.invalidResponse
            }

            return CharacterMatch(
                characterId: characterId,
                characterName: characterName,
                confidence: confidence,
                reasoning: reasoning
            )
        }

        // Parse universe
        guard let universe = responseDict["universe"] as? String else {
            throw CharacterQuizError.invalidResponse
        }

        // Parse analysis summary (optional, provide default)
        let analysisSummary = responseDict["analysisSummary"] as? String ?? "Analysis based on your journal reflections."

        // Parse analyzedAt timestamp
        let generatedAt: Date
        if let timestampString = responseDict["analyzedAt"] as? String {
            let formatter = ISO8601DateFormatter()
            generatedAt = formatter.date(from: timestampString) ?? Date()
        } else {
            generatedAt = Date()
        }

        return CharacterMatchResult(
            matches: matches,
            universe: universe,
            analysisSummary: analysisSummary,
            generatedAt: generatedAt
        )
    }
}
#endif
