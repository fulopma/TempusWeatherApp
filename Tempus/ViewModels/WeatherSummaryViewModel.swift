//
//  WeatherSummaryViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import Foundation
import NetworkLayer

@MainActor
class WeatherSummaryViewModel: ObservableObject {
    private var latitude: Double = 0
    private var longitude: Double = 0
    var city: String = ""
    @Published private var temperature = 0.0
    var unit: Units = .usCustomary
    private let serviceManager = ServiceManager()
    init(latitude: Double, longitude: Double, city: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        Task {
            do {
             
                let temperatureResponse = try await serviceManager.execute(
                    request: TemperatureNowRequest.createRequest(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    modelName: TemperatureTodayResponse.self
                )
                // TODO: find temperature by time
                
                self.temperature = temperatureResponse.hourly.temperature2m[self.getUtcIndex()]
                
                
            } catch {
                print("\(error)")
            }
            
        }
    }
    
    func getUtcIndex() -> Int {
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: Date())
        return hours
    }
    
    /// converts internal celsius value to preferred unit and appends the correct unit of the following:
    /// °C/°F/K
    func getTemperatureFormatted() -> String {
        return "\(Int(unit.convertTemperature(fromValue: temperature).rounded())) \(unit.getTemperatureUnit())"
    }

}
