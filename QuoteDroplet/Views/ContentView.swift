import SwiftUI

@available(iOS 16, *)
struct ContentView: View {
    @StateObject var sharedVars = SharedVarsBetweenTabs()
    
    var body: some View {
        TabView {
            DropletsView()
                .tabItem {
                    Label("Droplets", systemImage: "drop.circle.fill")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass.circle.fill")
                }
            TopView()
                .tabItem {
                    Label("Top", systemImage: "trophy.fill")
                }
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "house.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(sharedVars)
    }
}

class SharedVarsBetweenTabs: ObservableObject {
    @Published var colorPaletteIndex = 0
}

@available(iOS 16, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
