//
//  WeatherModels.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//


// see example
// https://archive-api.open-meteo.com/v1/archive?latitude=33.9091&longitude=-84.479&start_date=2025-01-14&end_date=2025-01-14&hourly=temperature_2m
struct TemperatureHistoryResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: HourlyUnits
    let hourly: [HourlyUnitsData]
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case hourlyUnits = "hourly_units"
        case hourly
    }
}

struct HourlyUnitsData: Decodable {
    let time: [String]
    let temperature2m: [Double]
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case temperature2m = "temperature_2m"
    }
}

struct HourlyUnits: Decodable {
    let time: String
    let temperature2m: String
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case temperature2m = "temperature_2m"
    }
}
