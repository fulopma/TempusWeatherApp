import DGCharts
import NetworkLayer
//
//  WeatherDetailsViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import SwiftUI

class WeatherDetailsViewModel: ObservableObject {
    private var units: Units = .usCustomary
    /// temperature stores array of date, temperature as of now the same time (x, y) coordinates
    /// ex: (5/1, 16)
    private var temperatureData: [(Date, Double)] = []
    /// temperature stores array of date, daily rainful (x, y) coordinates
    /// ex: (5/1, 10)
    var rainData: [(Date, Double)] = []
    /// temperature stores array of date, daily rainful (x, y) coordinates
    /// ex: (5/1, 10)
    var smogData: [(Date, Double)] = []
    private var serviceManager: ServiceAPI
    private var latitude: Double = 0
    private var longitude: Double = 0
    private(set) var city: String = ""
    private let utcIndexOffset: Int
    @Published private(set) var isDone = false
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
        self.utcIndexOffset = calendar.component(.hour, from: Date())
        self.serviceManager = serviceManager
    }
    @MainActor
    func fetchWeatherData() {
        print("Fetching Temperature")
        let currentDate = Date()
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        // number of years since 1950
        let years = calendar.component(.year, from: currentDate) - 1950
        Task {
            for _ in 0..<years {
                components.year? -= 1
                guard let pastDate = calendar.date(from: components) else {
                    print("Could not convert to Date from \(components)")
                    continue
                }
                temperatureData.append(
                    (pastDate, await fetchTemperatureData(date: pastDate))
                )
            }
            isDone = true
            print("is done: \(isDone) \(temperatureData.count)")
        }
    }
    private func fetchTemperatureData(date: Date) async -> Double {
        let secondsInADay: TimeInterval = 86400
        do {
            let temperatureHistoricalDayData = try await serviceManager.execute(
                request: TemperatureHistoryRequest.createRequest(
                    startDate: date,
                    endDate: date.addingTimeInterval(secondsInADay),
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
