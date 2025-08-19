//
//  Coordinator.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import CoreLocation
import SwiftUI
import NewRelic

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
            NewRelic.recordBreadcrumb("Opened App via Deeplink/Universal Link", attributes: [
                "url": url.absoluteString
            ])
            NewRelic.recordCustomEvent("Opened App via Deeplink/Universal Link")
            print("Received URL on Nav Stack: \(url)")
            if url.pathComponents.count < 1 {
                return
            }
            let path = url.lastPathComponent
            // index 0 of path is just "/"
            let viewName = path
            if viewName == "Welcome" {
                // welcome view is already the default, so no need to adjust path
                NewRelic.recordBreadcrumb("Opened url to Welcome View")
                return
            }
            guard
                let components = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                ), let queryItems = components.queryItems
            else {
                NewRelic.recordBreadcrumb("Malformed URL: No query parameters", attributes: ["url": url.absoluteString])
                return
            }
            NewRelic.recordBreadcrumb("Navigating to \(viewName) from link", attributes: [
                "queryItems": queryItems
            ])
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
                NewRelic.recordBreadcrumb("Appending weather summary to navigation stack", attributes: [
                    latitude: latitude,
                    longitude: longitude,
                    "city": cityAndAdminArea
                ])
                coordinator.showWeatherSummary(
                    latitude: latitude,
                    longitude: longitude,
                    city: cityAndAdminArea,
                    serviceManager: NetworkManager()
                )
                if viewName == "WeatherDetails" {
                    NewRelic.recordBreadcrumb("Appending weather details to navigation stack")
                    coordinator.showWeatherDetails()
                }
            }
        }
    }
}

@main
struct TempusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
//            #if DEBUG
//            HealthView()
//            #else
            ContentView()
//            #endif
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {
        NewRelic.enableFeatures(.NRFeatureFlag_NetworkRequestEvents)
        NewRelic.enableFeatures(.NRFeatureFlag_HttpResponseBodyCapture)
        NewRelic.enableFeatures(.NRFeatureFlag_AppStartMetrics)
        if let token = Bundle.main.infoDictionary?["NR_TOKEN"] as? String {
            NewRelic.start(withApplicationToken: token)
        } else {
            fatalError("NR_TOKEN is missing from Info.plist")
        }
        return true
    }
}
