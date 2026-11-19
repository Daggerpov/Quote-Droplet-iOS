//
//  ColorHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
    var hex: String {
        guard let components = cgColor?.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }

    /// sRGB components (0...1), resolved through UIColor so it works for any Color.
    var rgbComponents: (r: Double, g: Double, b: Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    /// WCAG relative luminance.
    var relativeLuminance: Double {
        func channel(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let (r, g, b) = rgbComponents
        return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }

    /// Linear blend towards `other` (amount 0 = self, 1 = other).
    func mixed(with other: Color, amount: Double) -> Color {
        let a = rgbComponents
        let b = other.rgbComponents
        let t = max(0, min(1, amount))
        return Color(red: a.r + (b.r - a.r) * t, green: a.g + (b.g - a.g) * t, blue: a.b + (b.b - a.b) * t)
    }
}

// Each palette is [background, text, accent]. The selected palette themes the widget and the
// whole app. Index 3 always holds the user's custom colors (persisted as hex strings), so the
// order of the presets must not change: the selected index is stored in the shared defaults.
//
// 6.1: every preset was retuned so quote text clears 7:1 against its background and the accent
// clears 4.5:1. The three palettes that couldn't (light blue + olive, cream + salmon, steel blue)
// were replaced with Sky, Linen and Sage, which keep their mood.
var colorPalettes = [
    [Color(hex: "3A2C24"), Color(hex: "F7EEDD"), Color(hex: "E8B66B")], // Espresso
    [Color(hex: "DCEEF8"), Color(hex: "0F2536"), Color(hex: "1D6696")], // Sky
    [Color(hex: "F6F0E6"), Color(hex: "3A2E27"), Color(hex: "A9492A")], // Linen
    // custom one:
    [Color(hex: defaultCustomPaletteHex[0]), Color(hex: defaultCustomPaletteHex[1]), Color(hex: defaultCustomPaletteHex[2])],
    [Color(hex: "0C1A2E"), Color(hex: "F1E4CE"), Color(hex: "DDA978")], // Midnight
    [Color(hex: "1E1D2A"), Color(hex: "F4F2F8"), Color(hex: "F59A62")], // Ember
    [Color(hex: "E6ECE2"), Color(hex: "1E2B22"), Color(hex: "3F6E4E")], // Sage
    [Color(hex: "2D383E"), Color(hex: "EEF4F2"), Color(hex: "EBAFC3")], // Rosewood
    [Color(hex: "18191E"), Color(hex: "E9EAEE"), Color(hex: "A4AEC2")], // Graphite
]

let paletteNames = ["Espresso", "Sky", "Linen", "Custom", "Midnight", "Ember", "Sage", "Rosewood", "Graphite"]

let customPaletteIndex = 3

// Starting point for the custom palette (forest, cream, blush). Users who already picked custom
// colors keep theirs: these only apply until the colors are first changed.
let defaultCustomPaletteHex = ["17573D", "F4EFE6", "F0BCCD"]

/// The order palettes are shown in Settings: dark presets, light presets, then custom.
let paletteDisplayOrder = [0, 4, 5, 7, 8, 1, 2, 6]

/// A palette plus the colors the UI derives from it (cards, secondary text, hairlines).
struct AppPalette {
    let background: Color
    let text: Color
    let accent: Color

    init(colors: [Color]) {
        background = colors[safe: 0] ?? Color(hex: "3A2C24")
        text = colors[safe: 1] ?? Color(hex: "F7EEDD")
        accent = colors[safe: 2] ?? Color(hex: "E8B66B")
    }

    var isDark: Bool { background.relativeLuminance < 0.3 }

    /// Cards lift off the background: lighter on dark palettes, near-white on light ones.
    var card: Color { isDark ? background.mixed(with: text, amount: 0.08) : background.mixed(with: .white, amount: 0.62) }

    /// A second, slightly stronger surface (selected chips' tracks, text fields).
    var raised: Color { isDark ? background.mixed(with: text, amount: 0.14) : background.mixed(with: text, amount: 0.06) }

    var secondaryText: Color { text.opacity(0.68) }

    var hairline: Color { text.opacity(isDark ? 0.12 : 0.10) }

    /// Text drawn on top of the accent color (filled buttons, selected segments).
    var onAccent: Color { accent.relativeLuminance > 0.4 ? Color(hex: "15151A") : .white }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, background.mixed(with: .black, amount: isDark ? 0.22 : 0.06)],
            startPoint: .top, endPoint: .bottom
        )
    }

    var shadow: Color { Color.black.opacity(isDark ? 0.28 : 0.08) }

    var colorScheme: ColorScheme { isDark ? .dark : .light }
}

func appPalette(_ index: Int) -> AppPalette {
    AppPalette(colors: colorPalettes[safe: index] ?? colorPalettes[0])
}
