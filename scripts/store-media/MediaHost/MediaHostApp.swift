import SwiftUI

// Empty host app: the UI tests in MediaUITests drive the installed Quote Droplet app by bundle ID.
@main
struct MediaHostApp: App {
    var body: some Scene {
        WindowGroup { Text("Store media host") }
    }
}
