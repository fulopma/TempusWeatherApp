import DGCharts
import NetworkLayer
import SwiftUI
import Combine
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
    @Published private(set) var temperatureData: [(Date, Double)] = []
    /// temperature stores array of date, daily rainful (x, y) coordinates
    /// ex: (5/1, 10)
    @Published private(set) var precipitationData: [(Date, Double)] = []
    /// temperature stores array of date, daily pm10 (x, y) coordinates
    /// ex: (5/1, 10)
    @Published private var smogData: [(Date, Double)] = []
    private var serviceManager: ServiceAPI
    private var latitude: Double = 0
    private var longitude: Double = 0
    private(set) var city: String = ""
    static var count = 0
    private let utcIndexOffset: Int
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
        self.utcIndexOffset = calendar.dateComponents(in: timeZone, from: Date()).hour ?? 0
        self.serviceManager = serviceManager
    }
    @MainActor
    func fetchWeatherData() {
        if isDone {
            return
        }
        print("Fetching weather data")
        let currentDate = Date()
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        // number of years since 1950
        let years = calendar.component(.year, from: currentDate) - 2010
        Task {
            var tempData: [(Date, Double)] = []
            var precipData: [(Date, Double)] = []
            var smogDataArr: [(Date, Double)] = []
            for _ in 0..<years {
                components.year? -= 1
                guard let pastDate = calendar.date(from: components) else {
                    print("Could not convert to Date from \(components)")
                    continue
                }
                tempData.append(
                    (pastDate, await fetchTemperatureData(date: pastDate))
                )
                precipData.append(
                    (pastDate, await fetchPrecipitationData(date: pastDate))
                )
                // API has access to data only back to 2013
                if components.year ?? 0 > 2013 {
                    smogDataArr.append(
                        (pastDate, await fetchSmogData(date: pastDate))
                    )
                }
            }
            await MainActor.run {
                self.temperatureData = tempData
                self.precipitationData = precipData
                self.smogData = smogDataArr
                self.isDone = true
            }
        }
    }
    private func fetchSmogData(date: Date) async -> Double {
        do {
            let smogHistoricalDayData = try await serviceManager.execute(
                request: SmogHistoryRequest.createRequest(
                    startDate: date,
                    endDate: date.addingTimeInterval(WeatherDetailsViewModel.secondsInADay),
                    latitude: latitude,
                    longitude: longitude
                ),
                modelName: SmogHistoryResponse.self)
            return smogHistoricalDayData.hourly.pm10[utcIndexOffset]
        } catch {
            print(
                "Error fetching smog data for date: \(date.ISO8601Format())"
            )
            return 0
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
                utcIndexOffset
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
