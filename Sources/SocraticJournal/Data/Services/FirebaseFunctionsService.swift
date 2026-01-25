// FirebaseFunctionsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseFunctions

/// Firebase Functions implementation of FirebaseFunctionsServiceProtocol
/// Handles all cloud function invocations for AI features
public final class FirebaseFunctionsService: FirebaseFunctionsServiceProtocol, @unchecked Sendable {
    /// Shared instance for Firebase Functions operations
    public static let shared = FirebaseFunctionsService()

    /// The Firebase Functions instance
    private let functions: Functions

    /// Default timeout in seconds for function calls
    private let defaultTimeout: TimeInterval = 30

    /// Extended timeout for complex operations like personality analysis
    private let extendedTimeout: TimeInterval = 60

    private init() {
        self.functions = Functions.functions()
        #if DEBUG
        print("[FirebaseFunctions] Service initialized")
        #endif
    }

    // MARK: - FirebaseFunctionsServiceProtocol

    public func generateClarityMirror(request: ClarityMirrorRequest) async throws -> String {
        #if DEBUG
        print("[FirebaseFunctions] Calling generateClarityMirror")
        print("[FirebaseFunctions] Question: \(request.question.prefix(50))...")
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "generateClarityMirror",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let mirror = responseDict["mirror"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing 'mirror' field in response"])
            )
        }

        #if DEBUG
        print("[FirebaseFunctions] generateClarityMirror success: \(mirror.prefix(50))...")
        #endif

        return mirror
    }

    public func generateFollowUpQuestion(request: FollowUpQuestionRequest) async throws -> String {
        #if DEBUG
        print("[FirebaseFunctions] Calling generateFollowUpQuestion")
        print("[FirebaseFunctions] Question index: \(request.questionIndex)")
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "generateFollowUpQuestion",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let question = responseDict["question"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing 'question' field in response"])
            )
        }

        #if DEBUG
        print("[FirebaseFunctions] generateFollowUpQuestion success: \(question.prefix(50))...")
        #endif

        return question
    }

    public func generateSocratesReaction(request: SocratesReactionRequest) async throws -> String {
        #if DEBUG
        print("[FirebaseFunctions] Calling generateSocratesReaction")
        print("[FirebaseFunctions] Question: \(request.question.prefix(50))...")
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "generateSocratesReaction",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let reaction = responseDict["reaction"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing 'reaction' field in response"])
            )
        }

        #if DEBUG
        print("[FirebaseFunctions] generateSocratesReaction success: \(reaction.prefix(50))...")
        #endif

        return reaction
    }

    public func analyzePersonality(request: PersonalityAnalysisRequest) async throws -> BigFiveProfile {
        #if DEBUG
        print("[FirebaseFunctions] Calling analyzePersonality")
        print("[FirebaseFunctions] Journal entries count: \(request.journalEntries.count)")
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "analyzePersonality",
            data: requestData,
            timeout: extendedTimeout
        )

        guard let responseDict = result as? [String: Any],
              let profileDict = responseDict["profile"] as? [String: Any] else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing 'profile' field in response"])
            )
        }

        let profile = try decodeProfile(from: profileDict)

        #if DEBUG
        print("[FirebaseFunctions] analyzePersonality success")
        print("[FirebaseFunctions] Summary: \(profile.summary.prefix(50))...")
        #endif

        return profile
    }

    public func healthCheck() async throws -> HealthCheckResponse {
        #if DEBUG
        print("[FirebaseFunctions] Calling healthCheck")
        #endif

        let result = try await callFunction(
            name: "healthCheck",
            data: [:],
            timeout: 10 // Short timeout for health checks
        )

        guard let responseDict = result as? [String: Any],
              let status = responseDict["status"] as? String,
              let timestamp = responseDict["timestamp"] as? String,
              let version = responseDict["version"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid health check response format"])
            )
        }

        let response = HealthCheckResponse(status: status, timestamp: timestamp, version: version)

        #if DEBUG
        print("[FirebaseFunctions] healthCheck success: \(status), version: \(version)")
        #endif

        return response
    }

    public func generateWisdomQuote(request: WisdomQuoteRequest) async throws -> AIWisdomQuote {
        #if DEBUG
        print("[FirebaseFunctions] Calling generateWisdomQuoteNightprep")
        print("[FirebaseFunctions] Themes: \(request.recentThemes)")
        if let mood = request.mood {
            print("[FirebaseFunctions] Mood: \(mood)")
        }
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "generateWisdomQuoteNightprep",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let quoteDict = responseDict["quote"] as? [String: Any],
              let text = quoteDict["text"] as? String,
              let author = quoteDict["author"] as? String,
              let relevance = quoteDict["relevance"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required fields in wisdom quote response"])
            )
        }

        let source = quoteDict["source"] as? String

        let quote = AIWisdomQuote(
            text: text,
            author: author,
            source: source,
            relevance: relevance
        )

        #if DEBUG
        print("[FirebaseFunctions] generateWisdomQuote success: \"\(text.prefix(50))...\" - \(author)")
        #endif

        return quote
    }

    public func generateSessionSummary(request: SessionSummaryRequest) async throws -> String {
        #if DEBUG
        print("[FirebaseFunctions] Calling generateSessionSummaryNightprep")
        print("[FirebaseFunctions] Exchanges count: \(request.exchanges.count)")
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "generateSessionSummaryNightprep",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let summary = responseDict["summary"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing 'summary' field in response"])
            )
        }

        #if DEBUG
        print("[FirebaseFunctions] generateSessionSummary success: \(summary.prefix(50))...")
        #endif

        return summary
    }

    public func enhanceFutureLetter(request: LetterEnhancementRequest) async throws -> LetterEnhancementResponse {
        #if DEBUG
        print("[FirebaseFunctions] Calling enhanceFutureLetterNightprep")
        print("[FirebaseFunctions] Letter content length: \(request.letterContent.count)")
        if let theme = request.letterTheme {
            print("[FirebaseFunctions] Theme: \(theme)")
        }
        #endif

        let requestData = try encodeRequest(request)
        let result = try await callFunction(
            name: "enhanceFutureLetterNightprep",
            data: requestData,
            timeout: defaultTimeout
        )

        guard let responseDict = result as? [String: Any],
              let prompts = responseDict["prompts"] as? [String],
              let encouragement = responseDict["encouragement"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required fields in letter enhancement response"])
            )
        }

        let response = LetterEnhancementResponse(
            prompts: prompts,
            encouragement: encouragement
        )

        #if DEBUG
        print("[FirebaseFunctions] enhanceFutureLetter success: \(prompts.count) prompts generated")
        #endif

        return response
    }

    // MARK: - Private Helpers

    /// Encode a Codable request to a dictionary for Firebase Functions
    private func encodeRequest<T: Encodable>(_ request: T) throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirebaseFunctionsError.invalidArgument("Failed to encode request")
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
        print("[FirebaseFunctions] Starting call to '\(name)' with timeout: \(timeout)s")
        #endif

        do {
            let result = try await callable.call(data)

            #if DEBUG
            let duration = Date().timeIntervalSince(startTime)
            print("[FirebaseFunctions] '\(name)' completed in \(String(format: "%.2f", duration))s")
            #endif

            return result.data
        } catch {
            #if DEBUG
            print("[FirebaseFunctions] '\(name)' failed: \(error.localizedDescription)")
            #endif

            throw mapFirebaseError(error)
        }
    }

    /// Map Firebase Functions errors to our domain error type
    private func mapFirebaseError(_ error: Error) -> FirebaseFunctionsError {
        let nsError = error as NSError

        // Check for Firebase Functions specific error codes
        if nsError.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: nsError.code)

            switch code {
            case .OK:
                return .unknown("Unexpected OK error code")
            case .cancelled:
                return .timeout
            case .unknown:
                return .unknown(nsError.localizedDescription)
            case .invalidArgument:
                return .invalidArgument(nsError.localizedDescription)
            case .deadlineExceeded:
                return .timeout
            case .notFound:
                return .serviceUnavailable
            case .alreadyExists:
                return .internalError("Resource already exists")
            case .permissionDenied:
                return .unauthenticated
            case .resourceExhausted:
                return .resourceExhausted
            case .failedPrecondition:
                return .invalidArgument(nsError.localizedDescription)
            case .aborted:
                return .internalError("Operation aborted")
            case .outOfRange:
                return .invalidArgument("Argument out of range")
            case .unimplemented:
                return .serviceUnavailable
            case .internal:
                return .internalError(nsError.localizedDescription)
            case .unavailable:
                return .serviceUnavailable
            case .dataLoss:
                return .internalError("Data loss occurred")
            case .unauthenticated:
                return .unauthenticated
            @unknown default:
                return .unknown(nsError.localizedDescription)
            }
        }

        // Check for network errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .networkError(error)
            default:
                return .networkError(error)
            }
        }

        return .unknown(error.localizedDescription)
    }

    /// Decode a BigFiveProfile from a dictionary response
    private func decodeProfile(from dict: [String: Any]) throws -> BigFiveProfile {
        // Helper to decode a trait from dictionary
        func decodeTrait(from dict: [String: Any]?, type: TraitType) throws -> PersonalityTrait {
            guard let dict = dict else {
                throw FirebaseFunctionsError.decodingError(
                    NSError(domain: "FirebaseFunctionsService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Missing trait: \(type.rawValue)"])
                )
            }

            guard let score = dict["score"] as? Int,
                  let label = dict["label"] as? String,
                  let description = dict["description"] as? String,
                  let evidence = dict["evidence"] as? [String] else {
                throw FirebaseFunctionsError.decodingError(
                    NSError(domain: "FirebaseFunctionsService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid trait data for: \(type.rawValue)"])
                )
            }

            return PersonalityTrait(
                type: type,
                score: score,
                label: label,
                description: description,
                evidence: evidence
            )
        }

        // Decode each trait
        let openness = try decodeTrait(from: dict["openness"] as? [String: Any], type: .openness)
        let conscientiousness = try decodeTrait(from: dict["conscientiousness"] as? [String: Any], type: .conscientiousness)
        let extraversion = try decodeTrait(from: dict["extraversion"] as? [String: Any], type: .extraversion)
        let agreeableness = try decodeTrait(from: dict["agreeableness"] as? [String: Any], type: .agreeableness)
        let neuroticism = try decodeTrait(from: dict["neuroticism"] as? [String: Any], type: .neuroticism)

        // Get summary and timestamp
        guard let summary = dict["summary"] as? String else {
            throw FirebaseFunctionsError.decodingError(
                NSError(domain: "FirebaseFunctionsService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing summary in profile"])
            )
        }

        // Parse analyzedAt timestamp
        let analyzedAt: Date
        if let timestampString = dict["analyzedAt"] as? String {
            let formatter = ISO8601DateFormatter()
            analyzedAt = formatter.date(from: timestampString) ?? Date()
        } else {
            analyzedAt = Date()
        }

        return BigFiveProfile(
            openness: openness,
            conscientiousness: conscientiousness,
            extraversion: extraversion,
            agreeableness: agreeableness,
            neuroticism: neuroticism,
            summary: summary,
            analyzedAt: analyzedAt
        )
    }
}
#endif
