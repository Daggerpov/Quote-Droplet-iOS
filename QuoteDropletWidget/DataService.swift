//
//  DataService.swift
//  QuoteDropletWidgetExtension
//
//  Created by Daniel Agapov on 2023-08-31.
//

import Foundation
import SwiftUI

struct DataService {
    // Add a safety check for UserDefaults access
    private let userDefaults: UserDefaults?
    
    init() {
        // Attempt to create a UserDefaults with the suite name, but handle failure gracefully
        if let defaults = UserDefaults(suiteName: "group.selectedSettings") {
            userDefaults = defaults
        } else {
            // Fall back to standard UserDefaults if app group is not configured properly
            print("⚠️ Warning: Could not access shared UserDefaults, falling back to standard defaults")
            userDefaults = UserDefaults.standard
        }
    }
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    func getColorPalette() -> [Color] {
        // Safely get color values with fallbacks
        let firstColor = userDefaults?.string(forKey: "widgetCustomColorPaletteFirstIndex") ?? widgetCustomColorPaletteFirstIndex
        let secondColor = userDefaults?.string(forKey: "widgetCustomColorPaletteSecondIndex") ?? widgetCustomColorPaletteSecondIndex
        let thirdColor = userDefaults?.string(forKey: "widgetCustomColorPaletteThirdIndex") ?? widgetCustomColorPaletteThirdIndex
        
        return [
            firstColor,
            secondColor,
            thirdColor
        ].map { Color(hex: $0) }
    }
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetColorPaletteIndex = 0
    
    func getIndex() -> Int {
        return userDefaults?.integer(forKey: "widgetColorPaletteIndex") ?? widgetColorPaletteIndex
    }
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteCategory = QuoteCategory.all
    
    func getQuoteCategory() -> QuoteCategory {
        if let rawValue = userDefaults?.string(forKey: "quoteCategory"),
           let category = QuoteCategory(rawValue: rawValue) {
            return category
        }
        return quoteCategory
    }
    
    @AppStorage("quoteFrequencySelected", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteFrequencySelected = QuoteFrequency.oneDay
    
    func getQuoteFrequencySelected() -> QuoteFrequency {
        if let rawValue = userDefaults?.string(forKey: "quoteFrequencySelected") {
            // First try with the raw value (e.g., "1 day")
            if let frequency = QuoteFrequency(rawValue: rawValue) {
                return frequency
            }
            
            // If that fails, try checking for case names directly
            switch rawValue {
            case "oneDay":
                return .oneDay
            case "eightHours":
                return .eightHours
            case "twelveHours":
                return .twelveHours
            case "twoDays":
                return .twoDays
            case "fourDays":
                return .fourDays
            case "oneWeek":
                return .oneWeek
            default:
                return quoteFrequencySelected
            }
        }
        return quoteFrequencySelected
    }
    
    // Add @AppStorage property for selectedFontIndex
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    func getSelectedFontIndex() -> Int {
        return userDefaults?.integer(forKey: "selectedFontIndex") ?? selectedFontIndex
    }
}
