import XCTest

/// The walkthrough recorded for the App Store app preview (record the simulator with
/// `xcrun simctl io <udid> recordVideo` while this runs; `make_preview.sh` trims and encodes it).
/// Paced for a ~25 second video: feed, search, top quotes, then switching palettes.
final class PreviewTour: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    /// A slow, readable scroll instead of a fling.
    func gentleScroll(up: Bool = true, distance: CGFloat = 0.32) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.7 : 0.7 - distance))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.7 - distance : 0.7))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: 450, thenHoldForDuration: 0.1)
    }

    func testPreviewTour() {
        // Set up off camera: Espresso, feed on top.
        launchApp()
        selectPalette("Espresso")
        openTab("Droplets")
        pause(2)
        // Marker for trimming: the recording starts being used from here.
        print("PREVIEW_START \(Date().timeIntervalSince1970)")
        pause(1.5)

        // Feed: read and save one.
        gentleScroll()
        pause(1.2)
        gentleScroll()
        pause(1.2)
        gentleScroll(up: false, distance: 0.64)
        pause(0.8)
        let save = app.buttons["Save"].firstMatch
        if save.exists { save.tap() }
        pause(1.2)

        // Search.
        openTab("Search")
        pause(1)
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("courage")
        pause(0.6)
        let searchKey = app.keyboards.buttons.matching(NSPredicate(format: "label ==[c] 'search'")).firstMatch
        if searchKey.exists { searchKey.tap() }
        pause(2.5)
        gentleScroll()
        pause(1.2)

        // Top quotes.
        openTab("Top")
        pause(2.5)
        gentleScroll()
        pause(1.2)

        // Palettes: the whole app follows the widget's colors.
        openTab("Settings")
        let appearance = app.buttons["Appearance"]
        if appearance.exists { appearance.tap() }
        pause(1.2)
        for name in ["Midnight", "Sky", "Linen", "Sage", "Espresso"] {
            app.buttons["\(name) palette"].tap()
            pause(1.3)
        }

        openTab("Droplets")
        pause(2.5)
        print("PREVIEW_END \(Date().timeIntervalSince1970)")
    }
}
