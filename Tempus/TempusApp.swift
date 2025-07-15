//
//  Coordinator.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import CoreLocation
import NetworkLayer
import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = Coordinator()
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WelcomeView()
                .environmentObject(coordinator)
                .navigationDestination(for: String.self) { value in
                    coordinator.destination(for: value)
                }
        }.onOpenURL { url in
            print("Received URL on Nav Stack: \(url)")
            let scheme = url.scheme ?? "No Scheme"
            if !(scheme == "tempusweather" || scheme == "https") {
                fatalError(
                    "Something has been corrupted where the url scheme is not tempusweather <\(url)>.\nPlease check your Info.plist"
                )
            }
            if url.pathComponents.count < 1 {
                return
            }
            let path = url.lastPathComponent
            // index 0 of path is just "/"
            let viewName = path
            if viewName == "Welcome" {
                // welcome view is already the default, so no need to adjust path
                return
            }
            if !(viewName == "WeatherSummary" || viewName == "WeatherDetails") {
                fatalError(
                    """
                    Invalid view name \(viewName). Valid options are: WeatherSummary, WeatherDetails, or Welcome.
                    Full url <\(url.absoluteString)>
                    """
                )
            }
            guard
                let components = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                ), let queryItems = components.queryItems
            else {
                print("no queries detected")
                return
            }
            print(queryItems)
            print("Navigating to \(viewName)")
            let latitude = Double(queryItems[0].value ?? "0.0") ?? 0.0
            let longitude = Double(queryItems[1].value ?? "0.0") ?? 0.0
            CLGeocoder().reverseGeocodeLocation(
                CLLocation(latitude: latitude, longitude: longitude)
            ) { placemarks, _ in
                guard let firstPlacemark = placemarks?.first else {
                    print(
                        "Couldn't reverse geocode location (\(latitude), \(longitude))"
                    )
                    return
                }
                let cityAndAdminArea = """
                    \(firstPlacemark.locality ?? "No city found"), \(firstPlacemark.administrativeArea ?? "")
                    """
                coordinator.showWeatherSummary(
                    latitude: latitude,
                    longitude: longitude,
                    city: cityAndAdminArea,
                    serviceManager: ServiceManager()
                )
                if viewName == "WeatherDetails" {
                    coordinator.showWeatherDetails()
                }
            }
        }
    }
}

@main
struct TempusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
