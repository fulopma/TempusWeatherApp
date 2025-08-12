//
//  TempusUITests.swift
//  TempusUITests
//
//  Created by Marcell Fulop on 6/3/25.
//

import XCTest

final class TempusUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testWelcomeViewElementsExist() {
        // Check for welcome text
        XCTAssertTrue(app.staticTexts["Welcome to Tempus"].exists)
        // Check for city text field
        XCTAssertTrue(app.textFields["Enter your city"].exists)
        // Check for Find Weather button
        XCTAssertTrue(app.buttons["Find Weather"].exists)
        // Check for Use Current Location button
        XCTAssertTrue(app.buttons["Use Current Location"].exists)
        // Check for Acknowledgements button
        XCTAssertTrue(app.buttons["Acknowledgements"].exists)
    }

    func testWeatherSummaryViewAppears() {
        let cityField = app.textFields["Enter your city"]
        cityField.tap()
        cityField.typeText("San Francisco")
        app.buttons["Find Weather"].tap()
       // XCTAssertTrue(app.buttons["Back"].exists)
        XCTAssertTrue(app.buttons["Show Historical Weather"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["San Francisco, CA"].waitForExistence(timeout: 2))
    }

    func testAcknowledgementsModal() {
        XCTAssertTrue(app.buttons["Acknowledgements"].waitForExistence(timeout: 2))
        app.buttons["Acknowledgements"].tap()
        XCTAssertFalse(app.staticTexts["Find Weather"].waitForExistence(timeout: 2))
    }
}
