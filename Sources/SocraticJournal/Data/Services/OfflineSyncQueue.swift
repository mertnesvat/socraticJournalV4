// OfflineSyncQueue.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

// MARK: - Types

/// Types of AI enhancement requests that can be queued for offline sync
public enum AIEnhancementType: String, Codable, Sendable {
    case clarityMirror
    case socratesReaction
    case followUpQuestion
    case insightCard
}

/// Represents a pending AI enhancement request stored for offline sync
public struct PendingAIRequest: Codable, Identifiable, Sendable {
    /// Unique identifier for this request
    public let id: String

    /// Type of AI enhancement requested
    public let type: AIEnhancementType

    /// ID of the journal session this request belongs to
    public let sessionId: String

    /// ID of the exchange within the session
    public let exchangeId: String

    /// The Socratic question that was asked
    public let question: String

    /// The user's answer to the question
    public let answer: String

    /// Previous exchanges in the session for context
    public let previousExchanges: [ExchangeData]?

    /// Timestamp when the request was created
    public let createdAt: Date

    /// Number of times this request has been retried
    public var retryCount: Int

    public init(
        id: String = UUID().uuidString,
        type: AIEnhancementType,
        sessionId: String,
        exchangeId: String,
        question: String,
        answer: String,
        previousExchanges: [ExchangeData]? = nil,
        createdAt: Date = Date(),
        retryCount: Int = 0
    ) {
        self.id = id
        self.type = type
        self.sessionId = sessionId
        self.exchangeId = exchangeId
        self.question = question
        self.answer = answer
        self.previousExchanges = previousExchanges
        self.createdAt = createdAt
        self.retryCount = retryCount
    }
}

// MARK: - Sync Result

/// Result of processing a pending AI request
public struct SyncResult: Sendable {
    public let sessionId: String
    public let exchangeId: String
    public let type: AIEnhancementType
    public let result: String

    public init(sessionId: String, exchangeId: String, type: AIEnhancementType, result: String) {
        self.sessionId = sessionId
        self.exchangeId = exchangeId
        self.type = type
        self.result = result
    }
}

// MARK: - Offline Sync Queue

/// Manages offline queue for Firebase function calls
/// Automatically syncs pending requests when connectivity is restored
public final class OfflineSyncQueue: @unchecked Sendable {
    /// Shared instance for offline sync operations
    public static let shared = OfflineSyncQueue()

    /// UserDefaults instance for persistence
    private let userDefaults: UserDefaults

    /// Key for storing the queue in UserDefaults
    private let queueKey = "com.socraticjournal.offlineQueue"

    /// Maximum number of retries before giving up on a request
    private let maxRetries = 3

    /// Lock for thread-safe queue access
    private let lock = NSLock()

    /// Flag to prevent concurrent queue processing
    private var isProcessing = false

    /// Callback when an enhancement is successfully synced
    /// Parameters: (sessionId, exchangeId, type, result)
    public var onEnhancementSynced: ((SyncResult) -> Void)?

    /// Callback when queue processing starts
    public var onSyncStarted: (() -> Void)?

    /// Callback when queue processing completes
    /// Parameter: number of successfully processed requests
    public var onSyncCompleted: ((Int) -> Void)?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Configure the queue and start listening for connectivity changes
    /// Should be called once at app launch after NetworkMonitor.startMonitoring()
    public func configure() {
        NetworkMonitor.shared.onConnectivityChanged = { [weak self] isConnected in
            if isConnected {
                Task { @MainActor in
                    await self?.processQueue()
                }
            }
        }

        #if DEBUG
        let pendingCount = loadQueue().count
        print("[OfflineSyncQueue] Configured with \(pendingCount) pending requests")
        #endif
    }

    // MARK: - Queue Management

    /// Add a request to the offline queue
    /// - Parameter request: The pending AI request to queue
    public func enqueue(_ request: PendingAIRequest) {
        lock.lock()
        var queue = loadQueueUnsafe()
        queue.append(request)
        saveQueueUnsafe(queue)
        lock.unlock()

        #if DEBUG
        print("[OfflineSyncQueue] Enqueued \(request.type.rawValue) for exchange \(request.exchangeId)")
        print("[OfflineSyncQueue] Queue size: \(queue.count)")
        #endif

        // Post notification for UI updates
        NotificationCenter.default.post(name: .offlineQueueUpdated, object: nil)
    }

    /// Get all pending requests
    /// - Returns: Array of pending AI requests
    public func getPendingRequests() -> [PendingAIRequest] {
        lock.lock()
        defer { lock.unlock() }
        return loadQueueUnsafe()
    }

    /// Check if there are pending requests
    public var hasPendingRequests: Bool {
        !getPendingRequests().isEmpty
    }

    /// Get count of pending requests
    public var pendingCount: Int {
        getPendingRequests().count
    }

    /// Remove a specific request from the queue
    /// - Parameter id: The ID of the request to remove
    public func removeRequest(id: String) {
        lock.lock()
        var queue = loadQueueUnsafe()
        queue.removeAll { $0.id == id }
        saveQueueUnsafe(queue)
        lock.unlock()

        NotificationCenter.default.post(name: .offlineQueueUpdated, object: nil)
    }

    /// Clear all pending requests
    public func clearQueue() {
        lock.lock()
        saveQueueUnsafe([])
        lock.unlock()

        #if DEBUG
        print("[OfflineSyncQueue] Queue cleared")
        #endif

        NotificationCenter.default.post(name: .offlineQueueUpdated, object: nil)
    }

    // MARK: - Queue Processing

    /// Process the queue when online
    /// Attempts to sync all pending requests with Firebase
    @MainActor
    public func processQueue() async {
        // Prevent concurrent processing
        guard !isProcessing else {
            #if DEBUG
            print("[OfflineSyncQueue] Already processing, skipping")
            #endif
            return
        }

        // Check connectivity
        guard NetworkMonitor.shared.isConnected else {
            #if DEBUG
            print("[OfflineSyncQueue] Not connected, skipping queue processing")
            #endif
            return
        }

        lock.lock()
        var queue = loadQueueUnsafe()
        lock.unlock()

        guard !queue.isEmpty else {
            #if DEBUG
            print("[OfflineSyncQueue] No pending requests to process")
            #endif
            return
        }

        isProcessing = true
        onSyncStarted?()

        #if DEBUG
        print("[OfflineSyncQueue] Processing \(queue.count) pending requests")
        #endif

        let firebaseFunctions = FirebaseFunctionsService.shared
        var processedIds: Set<String> = []
        var successCount = 0

        for request in queue {
            // Check if still connected before each request
            guard NetworkMonitor.shared.isConnected else {
                #if DEBUG
                print("[OfflineSyncQueue] Lost connection during processing, stopping")
                #endif
                break
            }

            do {
                let result: String

                switch request.type {
                case .clarityMirror:
                    let apiRequest = ClarityMirrorRequest(
                        question: request.question,
                        answer: request.answer,
                        previousExchanges: request.previousExchanges
                    )
                    result = try await firebaseFunctions.generateClarityMirror(request: apiRequest)

                case .socratesReaction:
                    let apiRequest = SocratesReactionRequest(
                        question: request.question,
                        answer: request.answer
                    )
                    result = try await firebaseFunctions.generateSocratesReaction(request: apiRequest)

                case .followUpQuestion:
                    let apiRequest = FollowUpQuestionRequest(
                        currentQuestion: request.question,
                        currentAnswer: request.answer,
                        previousExchanges: request.previousExchanges,
                        questionIndex: (request.previousExchanges?.count ?? 0) + 1
                    )
                    result = try await firebaseFunctions.generateFollowUpQuestion(request: apiRequest)

                case .insightCard:
                    // Insight cards are generated locally, skip processing
                    processedIds.insert(request.id)
                    continue
                }

                processedIds.insert(request.id)
                successCount += 1

                let syncResult = SyncResult(
                    sessionId: request.sessionId,
                    exchangeId: request.exchangeId,
                    type: request.type,
                    result: result
                )
                onEnhancementSynced?(syncResult)

                #if DEBUG
                print("[OfflineSyncQueue] Successfully processed \(request.type.rawValue) for exchange \(request.exchangeId)")
                #endif

            } catch {
                #if DEBUG
                print("[OfflineSyncQueue] Failed to process \(request.type.rawValue): \(error.localizedDescription)")
                #endif

                // Update retry count in local copy
                lock.lock()
                var currentQueue = loadQueueUnsafe()
                if let idx = currentQueue.firstIndex(where: { $0.id == request.id }) {
                    currentQueue[idx].retryCount += 1

                    if currentQueue[idx].retryCount >= maxRetries {
                        processedIds.insert(request.id)
                        #if DEBUG
                        print("[OfflineSyncQueue] Max retries reached for \(request.id), removing from queue")
                        #endif
                    }
                }
                saveQueueUnsafe(currentQueue)
                lock.unlock()
            }
        }

        // Remove processed requests from persistent storage
        lock.lock()
        var finalQueue = loadQueueUnsafe()
        finalQueue.removeAll { processedIds.contains($0.id) }
        saveQueueUnsafe(finalQueue)
        lock.unlock()

        isProcessing = false

        #if DEBUG
        print("[OfflineSyncQueue] Processing complete. Success: \(successCount), Remaining: \(finalQueue.count)")
        #endif

        onSyncCompleted?(successCount)
        NotificationCenter.default.post(name: .offlineQueueUpdated, object: nil)

        // Post notification if items were synced (for user notification)
        if successCount > 0 {
            NotificationCenter.default.post(
                name: .offlineSyncCompleted,
                object: nil,
                userInfo: ["count": successCount]
            )
        }
    }

    // MARK: - Persistence (Unsafe - requires lock to be held)

    private func loadQueueUnsafe() -> [PendingAIRequest] {
        guard let data = userDefaults.data(forKey: queueKey) else { return [] }
        return (try? JSONDecoder().decode([PendingAIRequest].self, from: data)) ?? []
    }

    private func saveQueueUnsafe(_ queue: [PendingAIRequest]) {
        guard let data = try? JSONEncoder().encode(queue) else { return }
        userDefaults.set(data, forKey: queueKey)
    }

    // MARK: - Thread-Safe Persistence (Public)

    private func loadQueue() -> [PendingAIRequest] {
        lock.lock()
        defer { lock.unlock() }
        return loadQueueUnsafe()
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// Posted when the offline queue is updated (items added/removed)
    static let offlineQueueUpdated = Notification.Name("com.socraticjournal.offlineQueueUpdated")

    /// Posted when offline sync completes successfully
    /// userInfo contains "count" key with number of synced items
    static let offlineSyncCompleted = Notification.Name("com.socraticjournal.offlineSyncCompleted")
}
#endif
