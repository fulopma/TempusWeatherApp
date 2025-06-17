import DGCharts
import NetworkLayer
import SwiftUI
//
//  WeatherDetailsViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

class WeatherDetailsViewModel: ObservableObject {
    private(set) var units: Units = .usCustomary
    /// temperature stores array of date, temperature as of now the same time (x, y) coordinates
    /// ex: (5/1, 16)
    /// Dates can not be presumed to be in order
    @Published private(set) var temperatureData: [(Date, Double)] = []
    private static let secondsBefore1960: TimeInterval = -315_532_800
    private(set) lazy var typicalTemperature = {
        // find the average temperature for the 1950s
        return self.temperatureData.filter({$0.0.timeIntervalSince1970 <
            WeatherDetailsViewModel.secondsBefore1960}).map { $0.1 }
            .reduce(0, +) / 10.0
    }()
    /// temperature stores array of date, daily rainful (x, y) coordinates
    /// ex: (5/1, 10)
    @Published private(set) var precipitationData: [(Date, Double)] = []
    private(set) lazy var typicalPrecipitation = {
        return self.precipitationData.filter({$0.0.timeIntervalSince1970 <
            WeatherDetailsViewModel.secondsBefore1960}).map { $0.1 }.reduce(0, +) / 10.0
    }()
    /// temperature stores array of date, daily pm10 (x, y) coordinates
    /// ex: (5/1, 10)
    @Published private var smogData: [(Date, Double)] = []
    private var serviceManager: ServiceAPI
    private var latitude: Double = 0
    private var longitude: Double = 0
    private(set) var city: String = ""
    static var count = 0
    private let utcHour: Int
    @Published private(set) var isDone = false
    static private let secondsInADay: TimeInterval = 86400
    init(
        serviceManager: ServiceAPI,
        latitude: Double,
        longitude: Double,
        city: String,
        units: Units
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.units = units
        let calendar = Calendar.current
        guard let timeZone = TimeZone(abbreviation: "UTC") else {
            fatalError("Could not find time zone UTC")
        }
        self.utcHour = calendar.dateComponents(in: timeZone, from: Date()).hour ?? 0
        self.serviceManager = serviceManager
    }
    @MainActor
    func fetchWeatherData() {
        if isDone {  return  }
        print("Fetching weather data")
        let currentDate = Date()
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        // number of years since 1950
        let years = calendar.component(.year, from: currentDate) - 1950
        Task {
            var tempData: [(Date, Double)] = []
            tempData.reserveCapacity(80)
            var precipData: [(Date, Double)] = []
            precipData.reserveCapacity(80)
            var smogTempData: [(Date, Double)] = []
            smogTempData.reserveCapacity(30)
            let currWeather = await fetchCurrentWeatherData()
            guard let currentDateCalendar = calendar.date(from: components) else {
                fatalError("Could not convert something about calendar and dates")
            }
            tempData.append((currentDateCalendar, currWeather.currentTemp))
            precipData.append((currentDateCalendar, currWeather.lastWeekPrecip))
            smogTempData.append((currentDateCalendar, currWeather.currentSmog))
            for _ in 0..<years {
                components.year? -= 1
                guard let pastDate = calendar.date(from: components) else {
                    print("Could not convert to Date from \(components)")
                    continue
                }
                tempData.append((pastDate, await fetchTemperatureData(date: pastDate)))
                precipData.append((pastDate, await fetchPrecipitationData(date: pastDate)))
                // API has access to data only back to 2013 optimistically
                if components.year ?? 0 > 2013 {
                    do {
                        smogTempData.append((pastDate, try await fetchSmogData(date: pastDate)))
                    } catch {
                        continue
                    }
                }
            }
            await MainActor.run {
                self.temperatureData = tempData
                self.precipitationData = precipData
                self.smogData = smogTempData
                self.isDone = true
            }
        }
    }
    func fetchCurrentWeatherData() async -> CurrentWeatherResponse {
        var toReturn = CurrentWeatherResponse()
        do {
            let tempNowResponse = try await serviceManager.execute(
                request: TemperatureNowRequest.createRequest(latitude: latitude, longitude: longitude),
                modelName: TemperatureTodayResponse.self
            )
            toReturn.currentTemp = tempNowResponse.hourly.temperature2m[utcHour]
        } catch {
            print("Failed to get current temperature \(error)")
        }
        do {
            let lastWeekPrecip = try await serviceManager.execute(request:
                PrecipitationNowRequest.createRequest(
                    startDate: Date().addingTimeInterval(-7.0 * WeatherDetailsViewModel.secondsInADay),
                    endDate: Date(),
                    latitude: latitude,
                    longitude: longitude),
                modelName: PrecipitationHistoryResponse.self)
            toReturn.lastWeekPrecip = lastWeekPrecip.daily.precipationSum.reduce(0, +)
        } catch {
            print("Failed to get last week precipitation \(error)")
        }
        do {
            let smogNowResponse = try await serviceManager.execute(
                request: SmogNowRequest.createRequest(latitude: latitude, longitude: longitude),
                modelName: SmogHistoryResponse.self
            )
            toReturn.currentSmog = smogNowResponse.hourly.pm10[utcHour]
        } catch {
            print("Failed to get current PM10 levels \(error)")
        }
        return toReturn
    }
    private func fetchSmogData(date: Date) async throws -> Double {
        do {
            let smogHistoricalDayData = try await serviceManager.execute(
                request: SmogHistoryRequest.createRequest(
                    startDate: date,
                    endDate: date.addingTimeInterval(WeatherDetailsViewModel.secondsInADay),
                    latitude: latitude,
                    longitude: longitude
                ),
                modelName: SmogHistoryResponse.self)
            return smogHistoricalDayData.hourly.pm10[utcHour]
        } catch {
            throw NSError(domain: "No data for \(date.formatted())", code: 404, userInfo: nil)
        }
    }
    /// Fetches the total precipation from the last week as rain is a more "cumalative" effect
    /// as raining at any one point in day is very volatile
    private func fetchPrecipitationData(date: Date) async -> Double {
        do {
            let precipitationHistoricalDayData =
                try await serviceManager.execute(
                    request: PrecipitationHistoryRequest.createRequest(
                       startDate:
                            date.addingTimeInterval(-WeatherDetailsViewModel.secondsInADay * 7),
                       endDate: date,
                       latitude: latitude,
                       longitude: longitude),
                    modelName: PrecipitationHistoryResponse.self
                )
            return precipitationHistoricalDayData.daily.precipationSum.reduce(0, +)
        } catch {
            print(
                "Error fetching preciptation data for date: \(date.ISO8601Format())"
            )
            return 0
        }
    }
    private func fetchTemperatureData(date: Date) async -> Double {
        do {
            let temperatureHistoricalDayData = try await serviceManager.execute(
                request: TemperatureHistoryRequest.createRequest(
                    startDate: date,
                    endDate: date.addingTimeInterval(WeatherDetailsViewModel.secondsInADay),
                    latitude: latitude,
                    longitude: longitude
                ),
                modelName: TemperatureHistoryResponse.self
            )
            return temperatureHistoricalDayData.hourly.temperature2m[
                utcHour
            ]
        } catch {
            print(
                "Error fetching temperature data for date: \(date.ISO8601Format())"
            )
            return 0
        }
    }
    func getSmogChartEntries() -> [ChartDataEntry] {
        return smogData.map(
            {
                ChartDataEntry(
                    x:
                        Double(Calendar.current.component(.year, from: $0.0)),
                    y: $0.1
                )
            })
    }
    func getPrecipitationChartEntries() -> [ChartDataEntry] {
        return precipitationData.map(
            {
                ChartDataEntry(
                    x:
                        Double(Calendar.current.component(.year, from: $0.0)),
                    y: units.convertPrecipitation(fromValue: $0.1)
                )
            })
    }
    func getTemperatureChartEntries() -> [ChartDataEntry] {
        return temperatureData.map(
            {
                ChartDataEntry(
                    x:
                        Double(Calendar.current.component(.year, from: $0.0)),
                    y: units.convertTemperature(fromValue: $0.1)
                )
            })
    }
}
