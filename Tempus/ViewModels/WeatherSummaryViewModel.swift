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
    private var latitude: Double = 0
    private var longitude: Double = 0
    var city: String = ""
    @Published private var temperature = 0.0
    var unit: Units = .usCustomary
    private let serviceManager: ServiceAPI
    private let gradient = DynamicGradient(colors: [
                                            UIColor(hexString: "#7200ff"),
                                            UIColor(hexString: "#0b7bf4"),
                                            UIColor(hexString: "#ffe400"),
                                            UIColor(hexString: "#ff8600"),
                                            UIColor(hexString: "#d73a00") ])
    @MainActor
    init(latitude: Double, longitude: Double, city: String, serviceManager: ServiceAPI) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.serviceManager = serviceManager
        Task {
            do {
                let temperatureResponse = try await serviceManager.execute(
                    request: TemperatureNowRequest.createRequest(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    modelName: TemperatureTodayResponse.self
                )
                self.temperature = temperatureResponse.hourly.temperature2m[self.getUtcIndex()]
            } catch {
                print("\(error)")
            }
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
        return "\(Int(unit.convertTemperature(fromValue: temperature).rounded())) \(unit.getTemperatureUnit())"
    }
    func getColorTemperature() -> Color {
        var scale = (temperature + 8.0) / 50.0
        if scale > 1.0 {
            scale = 1.0
        }
        if scale < 0.0 {
            scale = 0.0
        }
        return Color(gradient.pickColorAt(scale: scale).cgColor)
    }

}
