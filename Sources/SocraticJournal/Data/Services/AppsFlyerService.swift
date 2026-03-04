// AppsFlyerService.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import UIKit

public final class AppsFlyerService: NSObject, @unchecked Sendable {
    public static let shared = AppsFlyerService()

    private let devKey = "vhgDWSEpy6YYpyn9CVZeAE"
    private let appleAppID = "6757699511"

    private override init() {
        super.init()
    }

    public func configure() {
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = self

        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif

        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func applicationDidBecomeActive() {
        AppsFlyerLib.shared().start()
    }

    public func logEvent(_ eventName: String, eventValues: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: eventValues)
    }

    public func requestTrackingAuthorization() {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }
    }

    public func setCustomerUserId(_ userId: String) {
        AppsFlyerLib.shared().customerUserID = userId
    }
}

extension AppsFlyerService: AppsFlyerLibDelegate {
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        #if DEBUG
        if let status = conversionInfo["af_status"] as? String {
            print("[AppsFlyer] Install type: \(status)")
        }
        #endif
    }

    public func onConversionDataFail(_ error: Error) {
        #if DEBUG
        print("[AppsFlyer] Conversion data failed: \(error.localizedDescription)")
        #endif
    }

    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {}
    public func onAppOpenAttributionFailure(_ error: Error) {}
}
#endif
