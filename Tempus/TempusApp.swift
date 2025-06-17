//
//  Coordinator.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import SwiftUI
//
// enum Screen: View {
//    case welcome = WelcomeView()
//    case
// }

struct ContentView: View {
    @StateObject var coordinator = Coordinator()
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WelcomeView()
                .environmentObject(coordinator)
                .navigationDestination(for: String.self) { value in
                    coordinator.destination(for: value)
                }
        }
    }
}

@main
struct TempusApp: App {
    var body: some Scene {
        WindowGroup {
//            #if DEBUG
//            WeatherSummaryView(latitude: 37.77, longitude: -122.419, city: "San Francisco")
//            #else
            ContentView()
//            #endif
        }
    }
}
