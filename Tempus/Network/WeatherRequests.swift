//
//  WeatherRequest.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//

// https://archive-api.open-meteo.com/v1/archive?latitude=33.9091&longitude=-84.479&start_date=2025-01-14&end_date=2025-01-14&hourly=temperature_2m

/// All Weather Requests and Responses are UTC-0 and NOT adjusted for local time.

import NetworkLayer

struct TemperatureHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    var httpMethod: HttpMethod = .get
    var params: [String : String]
    var header: [String : String] = [:]
    
    static func createRequest(date: String, latitude: Double, longitude: Double) -> TemperatureHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": date,
            "end_date": date,
            "hourly": "temperature_2m"
        ]
        return TemperatureHistoryRequest(params: params)
    }
}

// https://archive-api.open-meteo.com/v1/archive?latitude=33.9091&longitude=-84.479&start_date=2025-01-01&end_date=2025-01-14&daily=precipitation_sum
struct PrecipitationHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    var httpMethod: HttpMethod = .get
    var params: [String : String]
    var header: [String : String] = [:]
    
    static func createRequest(date: String, latitude: Double, longitude: Double) -> PrecipitationHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": date,
            "end_date": date,
            "daily": "precipitation_sum",
        ]
        return PrecipitationHistoryRequest(params: params)
    }
}

// https://api.open-meteo.com/v1/forecast?latitude=37.77&longitude=122.42&hourly=temperature_2m&forecast_days=1
struct TemperatureNowRequest: Request {
    var baseURL: String = "https://api.open-meteo.com"
    var path: String = "/v1/forecast"
    var httpMethod: HttpMethod = .get
    var params: [String : String]
    var header: [String : String] = [:]
    static func createRequest(latitude: Double, longitude: Double) -> TemperatureNowRequest
    {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "hourly": "temperature_2m",
            "forecast_days": "1"
        ]
        return TemperatureNowRequest(params: params)
    }
    
}
