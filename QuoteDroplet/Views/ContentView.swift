import SwiftUI

@available(iOS 16, *)
struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()

    var body: some View {
        let palette = sharedVars.palette
        TabView {
            DropletsView()
                .modifier(TabBarStyling())
                .tabItem {
                    Label("Droplets", systemImage: "drop.fill")
                }
            SearchView()
                .modifier(TabBarStyling())
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            TopView()
                .modifier(TabBarStyling())
                .tabItem {
                    Label("Top", systemImage: "trophy.fill")
                }
            CommunityView()
                .modifier(TabBarStyling())
                .tabItem {
                    Label("Community", systemImage: "person.2.fill")
                }
            SettingsView()
                .modifier(TabBarStyling())
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .tint(palette.accent)
        // Light palettes get the light system chrome (status bar, sheets, pickers), dark ones dark
        .preferredColorScheme(palette.colorScheme)
        .environmentObject(sharedVars)
    }
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var colorPaletteIndex: Int

    static let customColorKeys = [
        "widgetCustomColorPaletteFirstIndex",
        "widgetCustomColorPaletteSecondIndex",
        "widgetCustomColorPaletteThirdIndex",
    ]

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.selectedSettings")
    }

    init() {
        Self.loadCustomPalette()
        colorPaletteIndex = Self.sharedDefaults?.integer(forKey: "widgetColorPaletteIndex") ?? 0
    }

    var palette: AppPalette { appPalette(colorPaletteIndex) }

    /// Re-reads the selected palette and custom colors (also written by the widget's settings).
    func reloadFromDefaults() {
        Self.loadCustomPalette()
        let index = Self.sharedDefaults?.integer(forKey: "widgetColorPaletteIndex") ?? 0
        if index != colorPaletteIndex {
            colorPaletteIndex = index
        }
    }

    static func loadCustomPalette() {
        for (i, key) in customColorKeys.enumerated() {
            let hex = sharedDefaults?.string(forKey: key) ?? defaultCustomPaletteHex[i]
            colorPalettes[customPaletteIndex][i] = Color(hex: hex)
        }
    }
}

@available(iOS 16, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
