//
//  WeatherRequest.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//

/// All Weather Requests and Responses are UTC-0 and NOT adjusted for local time.

import NetworkLayer
import Foundation

struct SmogHistoryRequest: Request {
    var baseURL: String = "https://air-quality-api.open-meteo.com"
    var path: String = "/v1/air-quality"
    var httpMethod: HttpMethod = .get
    var params: [String: String]
    var header: [String: String] = [:]
    static private var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    static func createRequest(
        startDate: Date,
        endDate: Date,
        latitude: Double,
        longitude: Double)
    -> SmogHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": formatter.string(from: startDate),
            "end_date": formatter.string(from: endDate),
            "hourly": "pm10"
            ]
        return SmogHistoryRequest(params: params)
    }
}

struct TemperatureHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    var httpMethod: HttpMethod = .get
    var params: [String: String]
    var header: [String: String] = [:]
    static private var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    static func createRequest(
        startDate: Date,
        endDate: Date,
        latitude: Double,
        longitude: Double)
    -> TemperatureHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": formatter.string(from: startDate),
            "end_date": formatter.string(from: endDate),
            "hourly": "temperature_2m"
        ]
        return TemperatureHistoryRequest(params: params)
    }
}

struct PrecipitationHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    var httpMethod: HttpMethod = .get
    var params: [String: String]
    var header: [String: String] = [:]
    static private var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    static func createRequest(startDate: Date,
                              endDate: Date,
                              latitude: Double,
                              longitude: Double)
    -> PrecipitationHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": formatter.string(from: startDate),
            "end_date": formatter.string(from: endDate),
            "daily": "precipitation_sum"
        ]
        return PrecipitationHistoryRequest(params: params)
    }
}

// https://api.open-meteo.com/v1/forecast?latitude=37.77&longitude=122.42&hourly=temperature_2m&forecast_days=1
struct TemperatureNowRequest: Request {
    var baseURL: String = "https://api.open-meteo.com"
    var path: String = "/v1/forecast"
    var httpMethod: HttpMethod = .get
    var params: [String: String]
    var header: [String: String] = [:]
    static func createRequest(latitude: Double, longitude: Double)
    -> TemperatureNowRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "hourly": "temperature_2m",
            "forecast_days": "1"
        ]
        return TemperatureNowRequest(params: params)
    }
}
