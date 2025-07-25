//
//  WeatherSummaryViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import Foundation
import NetworkLayer
import SwiftUI
import DynamicColor

class WeatherSummaryViewModel: ObservableObject {
    private(set) var latitude: Double = 0
    private(set) var longitude: Double = 0
    var city: String = ""
    @Published var unit: Units = .usCustomary
    private let serviceManager: ServiceAPI
    private static let secondsInAWeek: TimeInterval = 604800 // 7 days in seconds
    private let gradient = DynamicGradient(colors: [
                                            UIColor(hexString: "#7200ff"),
                                            UIColor(hexString: "#0b7bf4"),
                                            UIColor(hexString: "#ffe400"),
                                            UIColor(hexString: "#ff8600"),
                                            UIColor(hexString: "#d73a00") ])
    @Published private var weatherData = CurrentWeatherResponse()
    private var utcHour: Int = 0
    @MainActor
    init(latitude: Double, longitude: Double, city: String, serviceManager: ServiceAPI) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.serviceManager = serviceManager
        utcHour = getUtcIndex()
        Task {
            weatherData = await fetchCurrentWeatherData()
        }
    }
    func getUtcIndex() -> Int {
        let calendar = Calendar.current
        guard let timeZone = TimeZone(abbreviation: "UTC") else {
            fatalError("Could not find time zone UTC")
        }
        let utcHour = calendar.dateComponents(in: timeZone, from: Date()).hour ?? 0
        return utcHour
    }
    /// converts internal celsius value to preferred unit and appends the correct unit of the following:
    /// °C/°F/K
    func getTemperatureFormatted() -> String {
        return "Current Temperature: \(Int(unit.convertTemperature(fromValue: weatherData.currentTemp).rounded()))"
        + " \(unit.getTemperatureUnit())"
    }
    func getPrecipationFormatted() -> String {
        let val = Int(unit.convertPrecipitation(fromValue: weatherData.lastWeekPrecip))
        return "Last 7 days precipitation: \(val) \(unit.getPrecipationUnit())"
    }
    /// Smog outputs in only one unit for PM10 which is micrograms per cubic meter
    /// I don't think there is a "us customary" equivalent, but I would never support some nonsense
    /// like oz per gallon
    func getSmogFormatted() -> String {
        return "Smog: \(Int(weatherData.currentSmog)) µg/m³"
    }
    func getColorTemperature() -> Color {
        var scale = (weatherData.currentTemp + 8.0) / 50.0
        if scale > 1.0 {
            scale = 1.0
        }
        if scale < 0.0 {
            scale = 0.0
        }
        return Color(gradient.pickColorAt(scale: scale).cgColor)
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
                    startDate: Date().addingTimeInterval(-1.0 * WeatherSummaryViewModel.secondsInAWeek),
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
    
    func shareableLink() -> URL {
        var url = URL(filePath: "")
        do {
            url = try URL("https://www.tempusweather.com/WeatherSummary?lat=\(latitude)&long=\(longitude)", strategy: .url)
        }
        catch {
            print("failed to create URL for (\(latitude), \(longitude))")
            print("Error: \(error)")
        }
        return url
    }
}
