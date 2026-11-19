import XCTest

/// Shared helpers for driving the installed Quote Droplet app.
let quoteDropletBundleID = "com.Daggerpov.Quote-Droplet"

/// Screenshots go to $OUT_DIR (pass TEST_RUNNER_OUT_DIR=... to xcodebuild), else /tmp/store-media.
let outputDirectory: String = {
    let dir = ProcessInfo.processInfo.environment["OUT_DIR"] ?? "/tmp/store-media"
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    return dir
}()

extension XCTestCase {
    var app: XCUIApplication { XCUIApplication(bundleIdentifier: quoteDropletBundleID) }
    var springboard: XCUIApplication { XCUIApplication(bundleIdentifier: "com.apple.springboard") }

    func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: outputDirectory).appendingPathComponent("\(name).png")
        try? png.write(to: url)
    }

    /// Dismisses the notification permission prompt if it is showing.
    func allowNotificationsIfAsked(timeout: TimeInterval = 2) {
        for label in ["Allow", "Allow Notifications"] {
            let button = springboard.alerts.buttons[label]
            if button.waitForExistence(timeout: timeout) {
                button.tap()
                return
            }
        }
    }

    func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    func openTab(_ name: String) {
        let button = app.tabBars.buttons[name]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "tab \(name)")
        button.tap()
    }

    /// Settings > Appearance > the named palette tile.
    func selectPalette(_ name: String) {
        openTab("Settings")
        let appearance = app.buttons["Appearance"]
        if appearance.waitForExistence(timeout: 3) { appearance.tap() }
        let tile = app.buttons["\(name) palette"]
        if !tile.waitForExistence(timeout: 3) {
            app.swipeUp()
        }
        tile.tap()
    }

    func launchApp() {
        app.terminate()
        app.launch()
        allowNotificationsIfAsked()
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 10)
    }
}
