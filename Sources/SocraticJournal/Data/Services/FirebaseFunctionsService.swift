// FirebaseFunctionsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseFunctions

// MARK: - Types

/// Response from the health check Cloud Function
public struct HealthCheckResponse: Sendable {
    public let status: String
    public let timestamp: String
    public let version: String

    public init(status: String, timestamp: String, version: String) {
        self.status = status
        self.timestamp = timestamp
        self.version = version
    }
}

/// Errors from Firebase Functions calls
public enum FirebaseFunctionsError: Error, LocalizedError, Sendable {
    case networkError(Error)
    case timeout
    case serviceUnavailable
    case unauthenticated
    case invalidArgument(String)
    case resourceExhausted
    case internalError(String)
    case decodingError(Error)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .serviceUnavailable:
            return "Service is currently unavailable"
        case .unauthenticated:
            return "Authentication required"
        case .invalidArgument(let message):
            return "Invalid argument: \(message)"
        case .resourceExhausted:
            return "Too many requests, please try again later"
        case .internalError(let message):
            return "Internal error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Firebase Functions Service

/// Firebase Functions service for calling Cloud Functions.
/// Provides health checks and will support new social voice platform features.
public final class FirebaseFunctionsService: @unchecked Sendable {
    /// Shared instance for Firebase Functions operations
    public static let shared = FirebaseFunctionsService()

    /// The Firebase Functions instance
    private let functions: Functions

    private init() {
        self.functions = Functions.functions()

        // Configure emulator based on build configuration (set via xcconfig)
        if AppEnvironment.Firebase.useEmulator {
            let host = AppEnvironment.Firebase.emulatorHost
            let port = AppEnvironment.Firebase.functionsEmulatorPort
            functions.useEmulator(withHost: host, port: port)
            #if DEBUG
            print("[FirebaseFunctions] Service initialized with EMULATOR at \(host):\(port)")
            #endif
        } else {
            #if DEBUG
            print("[FirebaseFunctions] Service initialized with PRODUCTION Firebase")
            #endif
        }
    }

    // MARK: - Health Check

    /// Performs a health check against the Firebase Functions backend
    public func healthCheck() async throws -> HealthCheckResponse {
        #if DEBUG
        print("[FirebaseFunctions] Calling healthCheck")
        #endif

        let result = try await callFunction(
            name: "healthCheck",
            data: [:],
            timeout: 10
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

    // MARK: - Private Helpers

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
}
#endif
