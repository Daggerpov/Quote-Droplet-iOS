//
//  SettingsPage.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 4/25/25.
//


import SwiftUI
import WidgetKit
import Foundation

enum SettingsPage {
    case appearance
    case quotes
}

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject var quotesViewModel = QuotesViewModel(localQuotesService: LocalQuotesService(), apiService: APIService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @Environment(\.colorScheme) var colorScheme
    @State private var selected: SettingsPage = .appearance
    
    // Appearance variables
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    // Quotes variables
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    topNavBar
                    Spacer()
                    
                    if selected == .appearance {
                        AppearanceSubview()
                    } else {
                        QuotesSubview(viewModel: quotesViewModel)
                    }
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
                
                quotesViewModel.fetchNotificationScheduledTimeInfo()
                quotesViewModel.initializeCounts()
            }
        }
    }
}

@available(iOS 16.0, *)
extension SettingsView {
    private var topNavBar: some View {
        Picker(selection: $selected, label: Text("Picker"), content: {
            Text("Appearance").tag(SettingsPage.appearance)
            Text("Quotes").tag(SettingsPage.quotes)
        })
        .pickerStyle(SegmentedPickerStyle())
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 
