import XCTest

/// Adds Quote Droplet widgets to the simulator's home screen (the store's widget shots need them).
/// SpringBoard's labels change between iOS versions, so each step logs the visible buttons.
final class HomeScreenWidgets: XCTestCase {
    func log(_ step: String, _ element: XCUIElement? = nil) {
        let labels = (element ?? springboard).buttons.allElementsBoundByIndex.prefix(40).map { $0.label }
        print("STEP \(step): buttons=\(labels)")
        shot("home-\(step)")
    }

    /// Long-press an empty spot to enter jiggle mode, then Edit > Add Widget.
    func openWidgetGallery() {
        XCUIDevice.shared.press(.home)
        pause(1)
        let window = springboard.windows.firstMatch
        window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62)).press(forDuration: 1.6)
        pause(1)
        let tip = springboard.buttons["Continue"]
        if tip.exists { tip.tap(); pause(0.5) }
        log("jiggle")
        let edit = springboard.buttons["Edit"]
        if edit.waitForExistence(timeout: 3) {
            edit.tap()
            pause(1)
            log("edit-menu")
            for label in ["Add Widget", "Add Widgets"] {
                let add = springboard.buttons[label]
                if add.exists { add.tap(); break }
            }
        } else {
            let plus = springboard.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'add'")).firstMatch
            if plus.exists { plus.tap() }
        }
        pause(1.5)
        log("gallery")
    }

    func addWidget(sizeIndex: Int) {
        openWidgetGallery()
        let search = springboard.searchFields.firstMatch
        if search.waitForExistence(timeout: 3) {
            search.tap()
            let tip = springboard.buttons["Continue"]
            if tip.waitForExistence(timeout: 1) { tip.tap(); pause(0.5) }
            search.typeText("Quote Droplet")
            pause(1.5)
            log("search")
        }
        let result = springboard.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Quote Droplet'")).firstMatch
        if result.waitForExistence(timeout: 3) {
            result.tap()
        } else {
            springboard.staticTexts["Quote Droplet"].firstMatch.tap()
        }
        pause(1.5)
        log("sizes")
        for _ in 0..<sizeIndex {
            springboard.swipeLeft()
            pause(0.8)
        }
        log("size-\(sizeIndex)")
        let addButton = springboard.buttons.matching(NSPredicate(format: "label CONTAINS 'Add Widget'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
        }
        pause(1.5)
        log("added-\(sizeIndex)")
        let done = springboard.buttons["Done"]
        if done.waitForExistence(timeout: 2) { done.tap() }
        pause(1)
        log("done-\(sizeIndex)")
    }

    func testAddWidgets() {
        // Index into the size carousel. The gallery lists the widget kinds' sizes left to right.
        let sizes = (ProcessInfo.processInfo.environment["WIDGET_SIZES"] ?? "1").split(separator: ",").compactMap { Int($0) }
        for size in sizes {
            addWidget(sizeIndex: size)
        }
    }
}
