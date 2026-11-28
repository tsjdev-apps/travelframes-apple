import XCTest
import UIKit

@MainActor
final class NavigationTests: XCTestCase {
    func testEnglishNavigation() { verifyNavigation(language: "en", title: "New Collage") }
    func testGermanNavigation() { verifyNavigation(language: "de", title: "Neue Collage") }
    func testGermanDarkAccessibilityNavigation() {
        verifyNavigation(language: "de", title: "Neue Collage", largeText: true)
    }

    private func verifyNavigation(language: String, title: String, largeText: Bool = false) {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "de" ? "de_DE" : "en_US"]
        if largeText {
            app.launchArguments += ["--ui-testing-dark", "--ui-testing-large-text"]
        } else {
            app.launchArguments += ["--ui-testing-light"]
        }
        app.launch()
        let create = app.buttons["newCollage"]
        XCTAssertTrue(create.waitForExistence(timeout: 10))
        XCTAssertEqual(create.label, title)
        create.tap()
        let canvas = app.otherElements["canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let identity = canvas.value as? String
        XCTAssertNotNil(identity)
        XCTAssertTrue(app.buttons["tool.photos"].isHittable)
        app.buttons["tool.photos"].tap()
        XCTAssertTrue(app.buttons["tool.photos"].isSelected)
        attachScreenshot(name: "Portrait-\(language)-largeText-\(largeText)")
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertEqual(canvas.value as? String, identity)
        XCTAssertTrue(app.buttons["tool.photos"].isSelected)
        attachScreenshot(name: "Landscape-\(language)-largeText-\(largeText)")
        let inspector = app.buttons["toggleInspector"]
        if UIDevice.current.userInterfaceIdiom == .pad && !largeText {
            XCTAssertTrue(inspector.waitForExistence(timeout: 5))
            inspector.tap()
            XCTAssertFalse(app.buttons["tool.photos"].exists)
            XCTAssertEqual(canvas.value as? String, identity)
            inspector.tap()
            XCTAssertTrue(app.buttons["tool.photos"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.buttons["tool.photos"].isSelected)
        }
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.buttons["tool.photos"].waitForExistence(timeout: 5))
        XCTAssertEqual(canvas.value as? String, identity)
        // Keep the native back button and its platform accessibility behavior.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        XCTAssertTrue(create.isHittable)
    }

    private func attachScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
