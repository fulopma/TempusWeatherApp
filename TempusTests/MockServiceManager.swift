//
//  MockServiceManager.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/16/25.
//
import XCTest
@testable import NetworkLayer
@testable import Tempus

final class MockServiceManager: ServiceAPI {
    func execute<T>(request: any NetworkLayer.Request, modelName: T.Type) async throws -> T where T:Decodable {
        let smhu = SmogHourlyUnits(time: "", pm10: "microgram/m3")
        let smogHourly = SmogHourly(time: [""], pm10: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        switch request {
        case is SmogNowRequest:
            return SmogHistoryResponse(latitude: 0,
                                       longitude: 0,
                                       generationtimeMs: 0,
                                       utcOffsetSeconds: 0,
                                       timezone: "none",
                                       timezoneAbbreviation: "n/a",
                                       elevation: 0, hourlyUnits: smhu, hourly: smogHourly)
            as! T  // swiftlint:disable:this force_cast
        case is SmogHistoryRequest:
            return SmogHistoryResponse(latitude: 0,
                                       longitude: 0,
                                       generationtimeMs: 0,
                                       utcOffsetSeconds: 0,
                                       timezone: "none",
                                       timezoneAbbreviation: "n/a",
                                       elevation: 0, hourlyUnits: smhu, hourly: smogHourly)
            as! T  // swiftlint:disable:this force_cast
        default:
            fatalError("TODO finish switch cases")
        }
    }
}
