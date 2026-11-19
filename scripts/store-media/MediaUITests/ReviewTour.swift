import XCTest

/// Visits every screen and saves a screenshot of each (for reviewing the design, not for the store).
final class ReviewTour: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    func testReviewTour() {
        let palette = ProcessInfo.processInfo.environment["PALETTE"] ?? "Espresso"
        launchApp()
        selectPalette(palette)
        pause(1)
        shot("\(palette)-settings-appearance")
        app.swipeUp()
        pause(0.5)
        shot("\(palette)-settings-appearance-2")
        app.buttons["Quotes"].firstMatch.tap()
        pause(2)
        shot("\(palette)-settings-quotes")
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Daily quote notification'")).firstMatch.tap()
        pause(1.5)
        shot("\(palette)-notification-sheet")
        app.buttons["Done"].tap()
        pause(1)

        openTab("Droplets")
        pause(3)
        shot("\(palette)-droplets")
        app.buttons["Saved"].tap()
        pause(1)
        shot("\(palette)-saved")
        app.buttons["Feed"].tap()

        openTab("Search")
        pause(1)
        shot("\(palette)-search-empty")
        app.buttons["Seneca"].tap()
        pause(3)
        shot("\(palette)-search-results")

        openTab("Top")
        pause(3)
        shot("\(palette)-top")

        openTab("Community")
        pause(3)
        shot("\(palette)-community")
        app.buttons["Submit a Quote"].tap()
        pause(1.5)
        shot("\(palette)-submit-sheet")
        app.buttons["Cancel"].tap()
        pause(1)
        app.buttons["My Submissions"].tap()
        pause(3)
        shot("\(palette)-submissions")
        app.navigationBars.buttons.firstMatch.tap()

        openTab("Droplets")
        pause(1)
        app.buttons["App info"].firstMatch.tap()
        pause(1.5)
        shot("\(palette)-info")
        app.navigationBars.buttons.firstMatch.tap()
        pause(1)
        let author = app.buttons.matching(NSPredicate(format: "label BEGINSWITH '— '")).firstMatch
        if author.waitForExistence(timeout: 3) {
            author.tap()
            pause(3)
            shot("\(palette)-author")
        }
    }
}
