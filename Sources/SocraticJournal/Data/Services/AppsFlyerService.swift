// AppsFlyerService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import UIKit

/// AppsFlyer SDK service for attribution and marketing analytics
public final class AppsFlyerService: NSObject, @unchecked Sendable {
    /// Shared instance for AppsFlyer operations
    public static let shared = AppsFlyerService()

    // MARK: - Configuration
    private let devKey = "vhgDWSEpy6YYpyn9CVZeAE"
    private let appleAppID = "6757699511"

    private override init() {
        super.init()
    }

    // MARK: - Setup

    /// Configure AppsFlyer SDK - call this in app init before start()
    public func configure() {
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = self

        // Enable debug logging for development
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        print("[AppsFlyer] Configured with debug mode enabled")
        #endif

        // Wait for ATT authorization (iOS 14.5+)
        // This gives the user 60 seconds to respond to the ATT prompt
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

        // Subscribe to app lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    /// Start AppsFlyer SDK - called automatically when app becomes active
    @objc private func applicationDidBecomeActive() {
        AppsFlyerLib.shared().start()
        #if DEBUG
        print("[AppsFlyer] SDK started")
        #endif
    }

    // MARK: - Event Tracking

    /// Log a custom event to AppsFlyer
    /// - Parameters:
    ///   - eventName: The name of the event
    ///   - eventValues: Optional dictionary of event parameters
    public func logEvent(_ eventName: String, eventValues: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: eventValues)
        #if DEBUG
        print("[AppsFlyer] Event: \(eventName), values: \(eventValues ?? [:])")
        #endif
    }

    // MARK: - Predefined Events

    /// Log app install/first open (automatically tracked, but can be called manually)
    public func logFirstOpen() {
        logEvent("af_first_open", eventValues: nil)
    }

    /// Log session started
    public func logSessionStarted(sessionId: String) {
        logEvent("af_session_started", eventValues: [
            "session_id": sessionId
        ])
    }

    /// Log session completed with clarity score
    public func logSessionCompleted(sessionId: String, clarityScore: Int, exchangeCount: Int) {
        logEvent("af_session_completed", eventValues: [
            "session_id": sessionId,
            "clarity_score": clarityScore,
            "exchange_count": exchangeCount
        ])
    }

    /// Log letter composed
    public func logLetterComposed(letterId: String, durationDays: Int) {
        logEvent("af_letter_composed", eventValues: [
            "letter_id": letterId,
            "duration_days": durationDays
        ])
    }

    /// Log onboarding completed
    public func logOnboardingCompleted() {
        logEvent("af_tutorial_completion", eventValues: nil)
    }

    /// Log subscription or purchase event
    public func logPurchase(productId: String, price: Double, currency: String) {
        logEvent("af_purchase", eventValues: [
            "af_content_id": productId,
            "af_price": price,
            "af_currency": currency
        ])
    }

    // MARK: - App Tracking Transparency

    /// Request ATT authorization from the user
    /// Call this after a slight delay when app becomes active (iOS 14.5+)
    public func requestTrackingAuthorization() {
        // Only request on iOS 14.5+
        if #available(iOS 14.5, *) {
            // Small delay to ensure the app is fully active
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("[AppsFlyer] ATT authorized - IDFA available")
                    case .denied:
                        print("[AppsFlyer] ATT denied - IDFA not available")
                    case .notDetermined:
                        print("[AppsFlyer] ATT not determined")
                    case .restricted:
                        print("[AppsFlyer] ATT restricted")
                    @unknown default:
                        print("[AppsFlyer] ATT unknown status")
                    }
                }
            }
        }
    }

    // MARK: - User Properties

    /// Set customer user ID (for cross-platform attribution)
    public func setCustomerUserId(_ userId: String) {
        AppsFlyerLib.shared().customerUserID = userId
        #if DEBUG
        print("[AppsFlyer] Customer User ID set: \(userId)")
        #endif
    }

    /// Set additional custom data
    public func setAdditionalData(_ data: [AnyHashable: Any]) {
        AppsFlyerLib.shared().customData = data
    }
}

// MARK: - AppsFlyerLibDelegate

extension AppsFlyerService: AppsFlyerLibDelegate {
    /// Called when conversion data is received
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        #if DEBUG
        print("[AppsFlyer] Conversion data received:")
        for (key, value) in conversionInfo {
            print("  \(key): \(value)")
        }
        #endif

        // Handle deep linking or attribution data here
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                // User came from a marketing campaign
                if let mediaSource = conversionInfo["media_source"] as? String,
                   let campaign = conversionInfo["campaign"] as? String {
                    print("[AppsFlyer] Organic install from: \(mediaSource), campaign: \(campaign)")
                }
            } else {
                // Organic install
                print("[AppsFlyer] Organic install")
            }
        }
    }

    /// Called when conversion data request fails
    public func onConversionDataFail(_ error: Error) {
        #if DEBUG
        print("[AppsFlyer] Conversion data failed: \(error.localizedDescription)")
        #endif
    }

    /// Called when app is opened via deep link
    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        #if DEBUG
        print("[AppsFlyer] App opened via deep link:")
        for (key, value) in attributionData {
            print("  \(key): \(value)")
        }
        #endif
    }

    /// Called when deep link attribution fails
    public func onAppOpenAttributionFailure(_ error: Error) {
        #if DEBUG
        print("[AppsFlyer] Deep link attribution failed: \(error.localizedDescription)")
        #endif
    }
}
#endif
