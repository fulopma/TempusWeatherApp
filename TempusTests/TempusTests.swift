//
//  TempusTests.swift
//  TempusTests
//
//  Created by Marcell Fulop on 6/3/25.
//

import XCTest
@testable import Tempus

final class TempusTests: XCTestCase {
    func testGetTemperatureUnit() {
        XCTAssertEqual(Units.usCustomary.getTemperatureUnit(), "°F")
        XCTAssertEqual(Units.metric.getTemperatureUnit(), "°C")
        XCTAssertEqual(Units.scientific.getTemperatureUnit(), "K")
    }
    func testGetPrecipationUnit() {
        XCTAssertEqual(Units.usCustomary.getPrecipationUnit(), "in")
        XCTAssertEqual(Units.metric.getPrecipationUnit(), "mm")
        XCTAssertEqual(Units.scientific.getPrecipationUnit(), "m")
    }
    func testConvertPrecipitation() {
        // 10 mm to in
        XCTAssertEqual(Units.usCustomary.convertPrecipitation(fromValue: 10), 0.393701, accuracy: 0.0001)
        // 10 mm to mm
        XCTAssertEqual(Units.metric.convertPrecipitation(fromValue: 10), 10, accuracy: 0.0001)
        // 10 mm to m
        XCTAssertEqual(Units.scientific.convertPrecipitation(fromValue: 10), 0.01, accuracy: 0.0001)
    }
    /// All temperature is internally stored as celsius but can displayed in whatever unit system
    func testConvertTemperature() {
        // XCTAssertTrue(false)
        // 0°C to °F
        XCTAssertEqual(Units.usCustomary.convertTemperature(fromValue: 0), 32, accuracy: 0.0001)
        // 100°C to °F
        XCTAssertEqual(Units.usCustomary.convertTemperature(fromValue: 100), 212, accuracy: 0.0001)
        // 0°C to °C
        XCTAssertEqual(Units.metric.convertTemperature(fromValue: 0), 0, accuracy: 0.0001)
        // 100°C to °C
        XCTAssertEqual(Units.metric.convertTemperature(fromValue: 100), 100, accuracy: 0.0001)
        // 0°C to K
        XCTAssertEqual(Units.scientific.convertTemperature(fromValue: 0), 273.15, accuracy: 0.0001)
        // 100°C to K
        XCTAssertEqual(Units.scientific.convertTemperature(fromValue: 100), 373.15, accuracy: 0.0001)
    }
}
