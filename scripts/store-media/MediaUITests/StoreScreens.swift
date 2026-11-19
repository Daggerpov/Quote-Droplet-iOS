import XCTest

/// The raw App Store screenshots. Each screen is shown in a different palette, so the set also
/// shows off the themes. `make_store_screens.py` frames them with captions afterwards.
final class StoreScreens: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    func testStoreScreens() {
        launchApp()

        // 1. The feed, in the default palette.
        selectPalette("Espresso")
        pause(1)
        openTab("Droplets")
        pause(3)
        shot("1-droplets")

        // 2. Palettes and the widget preview.
        openTab("Settings")
        pause(1.5)
        shot("2-appearance")

        // 3. Search.
        selectPalette("Midnight")
        openTab("Search")
        pause(1)
        app.buttons["Seneca"].tap()
        pause(3)
        shot("3-search")

        // 4. The most liked quotes.
        selectPalette("Sky")
        openTab("Top")
        pause(3)
        shot("4-top")

        // 5. Community submissions.
        selectPalette("Linen")
        openTab("Community")
        pause(3)
        shot("5-community")

        // 6. The daily notification.
        selectPalette("Ember")
        openTab("Settings")
        app.buttons["Quotes"].firstMatch.tap()
        pause(1.5)
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Daily quote notification'")).firstMatch.tap()
        pause(1.5)
        shot("6-notification")
        app.buttons["Done"].tap()
        pause(1)

        // 7. The home screen widget, back in the default palette.
        selectPalette(ProcessInfo.processInfo.environment["WIDGET_PALETTE"] ?? "Espresso")
        pause(1)
        openTab("Droplets")
        pause(1)
        XCUIDevice.shared.press(.home)
        pause(1.5)
        // A second press goes to the first home screen page, where the medium widget is.
        XCUIDevice.shared.press(.home)
        pause(4)
        shot("7-home")
    }
}
