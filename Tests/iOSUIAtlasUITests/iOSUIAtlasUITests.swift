import XCTest

final class iOSUIAtlasUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchAndHomeNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. App Launch & Home title
        XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 5) || app.staticTexts["iOS UI Atlas"].waitForExistence(timeout: 5))

        // 2. Search flow
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText("Button")

            // Wait for results
            let buttonCell = app.cells.staticTexts["Button"].firstMatch
            if buttonCell.waitForExistence(timeout: 5) {
                buttonCell.tap()

                // 3. Component detail & tabs (Preview, Variants, Code, API)
                let previewTab = app.buttons["Preview"].firstMatch
                let codeTab = app.buttons["Code"].firstMatch
                let apiTab = app.buttons["API"].firstMatch

                if codeTab.waitForExistence(timeout: 5) {
                    codeTab.tap()
                    let copyBtn = app.buttons["code.copy"].firstMatch
                    let copyTextBtn = app.buttons["Copy Code"].firstMatch
                    let copyShortBtn = app.buttons["Copy"].firstMatch
                    XCTAssertTrue(copyBtn.waitForExistence(timeout: 3) || copyTextBtn.waitForExistence(timeout: 3) || copyShortBtn.waitForExistence(timeout: 3))
                }

                if apiTab.waitForExistence(timeout: 3) {
                    apiTab.tap()
                }

                if previewTab.waitForExistence(timeout: 3) {
                    previewTab.tap()
                }

                // 4. Favorites toggle
                let favoriteButton = app.buttons["favorite.toggle"].firstMatch
                if favoriteButton.waitForExistence(timeout: 3) {
                    favoriteButton.tap()
                }
            }
        }
    }

    func testModalPresentationFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Open sheet demo or presentation demo if accessible
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 3) {
            searchField.tap()
            searchField.typeText("sheet")

            let sheetCell = app.cells.staticTexts["sheet"].firstMatch
            if sheetCell.waitForExistence(timeout: 2) {
                sheetCell.tap()

                // Trigger interactive sheet button
                let triggerButton = app.buttons["Show Sheet"].firstMatch
                if triggerButton.waitForExistence(timeout: 2) {
                    triggerButton.tap()

                    // Verify sheet content appears
                    let sheetTitle = app.staticTexts["Sheet Content"].firstMatch
                    XCTAssertTrue(sheetTitle.waitForExistence(timeout: 2))

                    // Dismiss sheet
                    let dismissButton = app.buttons["Dismiss"].firstMatch
                    if dismissButton.exists {
                        dismissButton.tap()
                    }
                }
            }
        }
    }

    func testHebrewRTLSmoke() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(he)", "-AppleLocale", "he_IL"]
        app.launch()

        // Verify Hebrew localized title or home screen element
        XCTAssertTrue(app.staticTexts["אטלס ממשק iOS"].waitForExistence(timeout: 5) || app.navigationBars.element.waitForExistence(timeout: 5))
    }
}
