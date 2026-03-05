// DarkModeColorTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import UIKit
@testable import SocraticJournal

// MARK: - Helper

/// Resolves a UIColor for the given user interface style
private func resolvedColor(_ color: UIColor, style: UIUserInterfaceStyle) -> UIColor {
    let traits = UITraitCollection(userInterfaceStyle: style)
    return color.resolvedColor(with: traits)
}

/// Extracts RGBA components from a UIColor
private func components(of color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return (r, g, b, a)
}

/// Checks if two colors are approximately equal (within tolerance for floating point)
private func colorsApproximatelyEqual(
    _ c1: UIColor,
    _ c2: UIColor,
    tolerance: CGFloat = 0.02
) -> Bool {
    let (r1, g1, b1, _) = components(of: c1)
    let (r2, g2, b2, _) = components(of: c2)
    return abs(r1 - r2) < tolerance
        && abs(g1 - g2) < tolerance
        && abs(b1 - b2) < tolerance
}

// MARK: - Tests

@Suite("AppColors Dark Mode Adaptiveness")
struct DarkModeColorTests {

    // MARK: - Background Colors

    @Test("Background color adapts between light and dark")
    @MainActor
    func backgroundAdapts() {
        let uiColor = UIColor(AppColors.background)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        // Light should be warm cream (FAF7F2), dark should be near-black (1A1A1A)
        let (lr, lg, lb, _) = components(of: lightResolved)
        let (dr, dg, db, _) = components(of: darkResolved)

        // Light mode: high brightness (cream)
        #expect(lr > 0.9, "Light background red should be > 0.9, got \(lr)")
        #expect(lg > 0.9, "Light background green should be > 0.9, got \(lg)")

        // Dark mode: low brightness (near-black)
        #expect(dr < 0.15, "Dark background red should be < 0.15, got \(dr)")
        #expect(dg < 0.15, "Dark background green should be < 0.15, got \(dg)")
        #expect(db < 0.15, "Dark background blue should be < 0.15, got \(db)")

        // They must be different
        #expect(!colorsApproximatelyEqual(lightResolved, darkResolved),
                "Light and dark background colors must differ")
    }

    @Test("Surface color adapts between light and dark")
    @MainActor
    func surfaceAdapts() {
        let uiColor = UIColor(AppColors.surface)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        #expect(!colorsApproximatelyEqual(lightResolved, darkResolved),
                "Light and dark surface colors must differ")

        // Dark surface (2A2A2A) should be slightly lighter than dark background (1A1A1A)
        let (dr, _, _, _) = components(of: darkResolved)
        #expect(dr > 0.1 && dr < 0.25, "Dark surface should be in the 0.1-0.25 range, got \(dr)")
    }

    // MARK: - Text Colors

    @Test("Text primary adapts between light and dark")
    @MainActor
    func textPrimaryAdapts() {
        let uiColor = UIColor(AppColors.textPrimary)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        let (lr, _, _, _) = components(of: lightResolved)
        let (dr, _, _, _) = components(of: darkResolved)

        // Light: near-black text (1C1710)
        #expect(lr < 0.2, "Light text primary should be dark, got red=\(lr)")

        // Dark: near-white text (F5F5F5)
        #expect(dr > 0.9, "Dark text primary should be bright, got red=\(dr)")
    }

    @Test("Text secondary adapts between light and dark")
    @MainActor
    func textSecondaryAdapts() {
        let uiColor = UIColor(AppColors.textSecondary)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        #expect(!colorsApproximatelyEqual(lightResolved, darkResolved),
                "Light and dark text secondary colors must differ")
    }

    // MARK: - Accent Colors

    @Test("Accent color is brighter in dark mode for contrast")
    @MainActor
    func accentBrighterInDark() {
        let uiColor = UIColor(AppColors.accent)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        let (lr, lg, lb, _) = components(of: lightResolved)
        let (dr, dg, db, _) = components(of: darkResolved)

        // Dark mode accent (3D8B87) should have higher brightness than light (2D5F5D)
        let lightBrightness = (lr + lg + lb) / 3.0
        let darkBrightness = (dr + dg + db) / 3.0

        #expect(darkBrightness > lightBrightness,
                "Dark accent should be brighter (\(darkBrightness)) than light (\(lightBrightness))")
    }

    // MARK: - Border Colors

    @Test("Border color adapts between light and dark")
    @MainActor
    func borderAdapts() {
        let uiColor = UIColor(AppColors.border)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        let (lr, _, _, _) = components(of: lightResolved)
        let (dr, _, _, _) = components(of: darkResolved)

        // Light border (D8D0C4): warm, mid-high brightness
        #expect(lr > 0.7, "Light border should be bright, got red=\(lr)")

        // Dark border (3A3A3A): subtle dark
        #expect(dr < 0.3, "Dark border should be dark, got red=\(dr)")
    }

    // MARK: - Static Colors (should NOT change)

    @Test("Coral accent2 stays the same in both modes")
    @MainActor
    func accent2Static() {
        let uiColor = UIColor(AppColors.accent2)
        let lightResolved = resolvedColor(uiColor, style: .light)
        let darkResolved = resolvedColor(uiColor, style: .dark)

        #expect(colorsApproximatelyEqual(lightResolved, darkResolved),
                "Coral accent2 should be identical in both modes")
    }

    @Test("Tag colors stay the same in both modes")
    @MainActor
    func tagColorsStatic() {
        let tagColors = [
            ("tagSleep", UIColor(AppColors.tagSleep)),
            ("tagCO2", UIColor(AppColors.tagCO2)),
            ("tagNature", UIColor(AppColors.tagNature)),
            ("tagHold", UIColor(AppColors.tagHold))
        ]

        for (name, uiColor) in tagColors {
            let light = resolvedColor(uiColor, style: .light)
            let dark = resolvedColor(uiColor, style: .dark)
            #expect(colorsApproximatelyEqual(light, dark),
                    "\(name) should be identical in both modes")
        }
    }
}
#endif
