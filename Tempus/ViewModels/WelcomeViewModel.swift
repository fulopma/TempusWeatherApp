//
//  WelcomeViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import Foundation
import CoreLocation
import SwiftUI
import NetworkLayer

class WelcomeViewModel: ObservableObject {
    @Published var query: String = ""
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var city: String = ""
   // private let coreLocationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    var unit: Units = .usCustomary
    func findLocation() async {
        if query.isEmpty {
            return
        }
        do {
            let placemakers = try await geocoder.geocodeAddressString(query)
            if let location = placemakers.first?.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                city = placemakers.first?.locality ?? "No city found"
                print("\(latitude), \(longitude)")
            }
        } catch {
            print("\(error)")
        }
        print("Searching for location...")
    }
    func returnWeatherSummary() -> WeatherSummaryView {
        return WeatherSummaryView(latitude: latitude,
                                  longitude: longitude,
                                  city: city,
                                  serviceManager: ServiceManager())
    }
}
