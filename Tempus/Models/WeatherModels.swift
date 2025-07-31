//
//  WeatherModels.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

/// Smog is PM10.
struct SmogHistoryResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: SmogHourlyUnits
    let hourly: SmogHourly
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
struct SmogHourly: Decodable {
    let time: [String]
    let pm10: [Double]
}
struct SmogHourlyUnits: Decodable {
    let time: String
    let pm10: String
}

struct TemperaturePrecipitationHistoryResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let utcOffsetSeconds: Int
    let daily: PrecipitationDailyData
    let hourly: TempHourlyUnitsData
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case utcOffsetSeconds = "utc_offset_seconds"
        case daily
        case hourly
    }
}

struct PrecipitationHistoryResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let dailyUnits: DailyUnits
    let daily: PrecipitationDailyData
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

struct PrecipitationDailyData: Decodable {
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
    let hourlyUnits: TempHourlyUnits
    let hourly: TempHourlyUnitsData
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
    let hourlyUnits: TempHourlyUnits
    let hourly: TempHourlyUnitsData
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

struct TempHourlyUnitsData: Decodable {
    let time: [String]
    let temperature2m: [Double]
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case temperature2m = "temperature_2m"
    }
}

struct TempHourlyUnits: Decodable {
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
    func convertPrecipitation(fromValue: Double) -> Double {
        switch self {
        case .usCustomary:
            return fromValue * 0.0393701
        case .metric:
            return fromValue
        case .scientific:
            return fromValue * 0.001
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
