//
//  WelcomeViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import CoreLocation
import Foundation
import NetworkLayer
import SwiftUI

class WelcomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var query: String = ""
    private(set) var latitude: Double = 0.0
    private(set) var longitude: Double = 0.0
    private(set) var city: String = ""
    private(set) var administrativeArea: String = ""
    private let geocoder = CLGeocoder()
    private var locationManager: CLLocationManager?
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
                administrativeArea = placemakers.first?.administrativeArea ?? ""
                print("\(latitude), \(longitude)")
                print("\(city), \(administrativeArea)")
            }
        } catch {
            print("\(error)")
        }
        print("Searching for location...")
    }
    func useCurrentLocation() async {
        await MainActor.run {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
            self.locationManager?.requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                self.city = placemark.locality ?? "Current Location"
                self.administrativeArea = placemark.administrativeArea ?? ""
                print("State: \(self.administrativeArea)")
            } else {
                self.city = "Current Location"
            }
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Failed to get user location: \(error)")
    }
    
    /// To be used in universal/deep linking, not really in the Welcome view
    func setCoordinates(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

//    func returnWeatherSummary() -> WeatherSummaryView {
//        return WeatherSummaryView(
//            latitude: latitude,
//            longitude: longitude,
//            city: city + (administrativeArea.isEmpty ? "" : ", \(administrativeArea)"),
//            serviceManager: ServiceManager()
//        )
//    }
}
