//
//  WelcomeViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import Foundation
import CoreLocation

class WelcomeViewModel: ObservableObject {
    var query: String = ""
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
   // private let coreLocationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    var unit: Units = .usCustomary
    init() {
      //  coreLocationManager.delegate = self
    }
    func findLocation() async {
        if query.isEmpty {
            return
        }
        do {
            let placemakers = try await geocoder.geocodeAddressString(query)
            if let location = placemakers.first?.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                print("\(latitude), \(longitude)")
            }
        } catch {
            print("\(error)")
        }
        print("Searching for location...")
    }
    func showDetails() {
        
    }
}
