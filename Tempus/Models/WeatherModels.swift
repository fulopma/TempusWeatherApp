//
//  WeatherModels.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

struct PrecipitationHistoryResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let dailyUnits: DailyUnits
    let daily: Daily
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case dailyUnits = "daily_units"
        case daily
    }
}

struct Daily: Decodable {
    let time: [String]
    let precipationSum: [Double]
    enum CodingKeys: String, CodingKey {
        case time
        case precipationSum = "precipitation_sum"
    }
}

struct DailyUnits: Decodable {
    let time: String
    let precipationSum: String
    enum CodingKeys: String, CodingKey {
        case time
        case precipationSum = "precipitation_sum"
    }
}

struct TemperatureHistoryResponse:
    Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: HourlyUnits
    let hourly: HourlyUnitsData
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

struct TemperatureTodayResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: HourlyUnits
    let hourly: HourlyUnitsData
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

enum Units: String {
    case usCustomary
    case metric
    // like metric but uses base SI units
    // see: https://en.wikipedia.org/wiki/International_System_of_Units
    case scientific
    func getTemperatureUnit() -> String {
        switch self {
        case .usCustomary:
            return "°F"
        case .metric:
            return "°C"
        case .scientific:
            return "K"
        }
    }
    func getPrecipationUnit() -> String {
        switch self {
        case .usCustomary:
            return "in"
        case .metric:
            return "mm"
        case .scientific:
            return "m"
        }
    }
    func convertTemperature(fromValue: Double) -> Double {
        switch self {
        case .usCustomary:
            return (fromValue * 9.0 / 5.0) + 32.0
        case .metric:
            return fromValue
        case .scientific:
            return fromValue + 273.15
        }
    }
}
