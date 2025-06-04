//
//  WeatherRequest.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//

// https://archive-api.open-meteo.com/v1/archive?latitude=33.9091&longitude=-84.479&start_date=2025-01-14&end_date=2025-01-14&hourly=temperature_2m&timezone=America%2FNew_York
struct TemperatureHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    var httpMethod: HttpMethod = .get
    var params: [String : String]
    var header: [String : String] = [:]
    
    static func createRequest(date: String, latitude: Double, longitude: Double, timeZone: String) -> TemperatureHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": date,
            "end_date": date,
            "hourly": "temperature_2m",
            "timezone": timeZone
        ]
        return TemperatureHistoryRequest(params: params)
    }
}

// https://archive-api.open-meteo.com/v1/archive?latitude=33.9091&longitude=-84.479&start_date=2025-01-01&end_date=2025-01-14&daily=precipitation_sum&timezone=America%2FNew_York
struct PrecipitationHistoryRequest: Request {
    var baseURL: String = "https://archive-api.open-meteo.com"
    var path: String = "/v1/archive"
    
    var httpMethod: HttpMethod = .get
    
    var params: [String : String]
    
    var header: [String : String] = [:]
    
    static func createRequest(date: String, latitude: Double, longitude: Double, timeZone: String) -> PrecipitationHistoryRequest {
        let params: [String: String] = [
            "latitude": String(latitude),
            "longitude": String(longitude),
            "start_date": date,
            "end_date": date,
            "daily": "precipitation_sum",
            "timezone": timeZone
        ]
        return PrecipitationHistoryRequest(params: params)
    }
}
