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
        // Wait for navigation
        let summaryTitle = app.staticTexts["San Francisco"]
        let exists = summaryTitle.waitForExistence(timeout: 5)
        XCTAssertTrue(exists)
    }

    func testAcknowledgementsModal() {
        app.buttons["Acknowledgements"].tap()
        let ackText = app.staticTexts["Acknowledgements"]
        let exists = ackText.waitForExistence(timeout: 2)
        XCTAssertTrue(exists)
    }
}
